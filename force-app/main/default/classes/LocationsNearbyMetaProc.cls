public class LocationsNearbyMetaProc extends vertic_MetadataProcessor implements Database.AllowsCallouts {
    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        super.process(this.request);

        this.doInit();

        return this.response;
    }

    private void doInit() {
        String recordId = this.request.getString('recordId');
        Decimal distance = this.request.getDecimal('distance') == null ? 1 : this.request.getDecimal('distance');
        animalos__Job__c jobVar = new animalos__Job__c();
        this.request.getMapper().mapToSObject('job', jobVar);
        //recalculate formulas method doesn't work for Address field. So, we need to calculate it manually
        String fullAddress = this.getFullAddress(jobVar);

        System.Location currentLocation;
        List<animalos__Location_Of_Interest__c> locationsNearby = new List<animalos__Location_Of_Interest__c>();
        String existingLocationId;

        if (String.isNotBlank(recordId)) {
            SObjectType sObjectType = ((Id) recordId).getSobjectType();
            if (sObjectType == animalos__Location_Of_Interest__c.getSObjectType()) {
                animalos__Location_Of_Interest__c locationVar = (animalos__Location_Of_Interest__c) vertic_Utils.arrays.firstOrException([
                        SELECT Id, animalos__Address__Latitude__s, animalos__Address__Longitude__s
                        FROM animalos__Location_Of_Interest__c
                        WHERE Id = :recordId
                ], 'Location not found with Id:' + recordId);

                if (locationVar.animalos__Address__Latitude__s != null && locationVar.animalos__Address__Longitude__s != null) {
                    currentLocation = System.Location.newInstance(locationVar.animalos__Address__Latitude__s, locationVar.animalos__Address__Longitude__s);
                    existingLocationId = locationVar.Id;
                }
            }

            if (sObjectType == animalos__Job__c.getSObjectType()) {
                animalos__Job__c existingJob = (animalos__Job__c) vertic_Utils.arrays.firstOrException([
                        SELECT Id, animalos__Location_Of_Interest__r.animalos__Address__Latitude__s, animalos__Location_Of_Interest__r.animalos__Address__Longitude__s, animalos__Location_Of_Interest__r.Id
                        FROM animalos__Job__c
                        WHERE Id = :recordId
                ], 'Job not found with Id:' + recordId);

                if (existingJob.animalos__Location_Of_Interest__r?.animalos__Address__Latitude__s != null && existingJob.animalos__Location_Of_Interest__r?.animalos__Address__Longitude__s != null) {
                    currentLocation = System.Location.newInstance(existingJob.animalos__Location_Of_Interest__r.animalos__Address__Latitude__s, existingJob.animalos__Location_Of_Interest__r.animalos__Address__Longitude__s);
                    existingLocationId = existingJob.animalos__Location_Of_Interest__r.Id;
                }
            }
        }

        if (currentLocation == null && String.isNotBlank(fullAddress.remove(',').remove('null').trim())) {
            Map<String, Object> fullAddressDetails = animalos.PolygonUtils.getFullAddressDetailsByAddress(fullAddress);
            vertic_DTO fullAddressDetailsDTO = new vertic_DTO(fullAddressDetails);

            if (fullAddressDetailsDTO.getBoolean('success') == true) {
                currentLocation = System.Location.newInstance(fullAddressDetailsDTO.getDecimal('data.position.lat'), fullAddressDetailsDTO.getDecimal('data.position.lng'));
            }
        }

        //animalWelfare specific case. Try to find an existing location by job.
        vertic_Request requestVar = new vertic_Request();
        requestVar.getMapper().mapFromSObject('job', jobVar);
        vertic_Response existingLocationResponse = new AnimalWelfareFindExistingRecords().process(requestVar);

        if(existingLocationResponse.has('jobLocationId')) {
            existingLocationId = existingLocationResponse.getString('jobLocationId');
        }

        if (currentLocation != null) {
            locationsNearby = [
                    SELECT Id, Name, animalos__Address__Longitude__s, animalos__Address__Latitude__s, animalos__Address__City__s, animalos__Address__CountryCode__s,
                            animalos__Address__PostalCode__s, animalos__Address__StateCode__s, animalos__Address__Street__s
                    FROM animalos__Location_Of_Interest__c
                    WHERE DISTANCE(animalos__Address__c, :currentLocation, 'km') < :distance
                    AND Id != :existingLocationId
            ];
        }

        this.response.getMapper().mapFromListSObjects('locationsNearby', locationsNearby);
    }

    private String getFullAddress(animalos__Job__c jobVar) {
        return String.format('{0}, {1}, {2} {3} {4}', new List<String>{
                jobVar.animalos__Address__Street__s,
                jobVar.animalos__Address__City__s,
                jobVar.animalos__Address__StateCode__s,
                jobVar.animalos__Address__PostalCode__s,
                jobVar.animalos__Address__CountryCode__s
        });
    }
}