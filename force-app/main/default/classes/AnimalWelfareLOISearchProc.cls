public without sharing class AnimalWelfareLOISearchProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.search();

        return this.response;
    }

    private void search() {
        vertic_DTO locationOfInterestDTO = this.request.getDTO('locationOfInterest');
        String searchBy = this.request.getRequiredString('searchBy');
        animalos__Location_Of_Interest__c locationVar;
        String condition;
        Map<String, Object> binds = new Map<String, Object>();

        if ('Id'.equalsIgnoreCase(searchBy)) {
            String locationOfInterestId = this.request.getRequiredString('locationOfInterest.Id');
            condition = 'Id = :locationOfInterestId';
            binds.put('locationOfInterestId', locationOfInterestId);
        }

        if ('Coordinates'.equalsIgnoreCase(searchBy)) {
            Decimal latitude = locationOfInterestDTO.getDecimal('animalos__Address__Latitude__s');
            Decimal longitude = locationOfInterestDTO.getDecimal('animalos__Address__Longitude__s');

            if (latitude == null || longitude == null) {
                throw new vertic_Structs.MissingDataException('Please, provide both latitude and longitude for the search.');
            }

            condition = 'animalos__Address__Latitude__s = :latitude AND animalos__Address__Longitude__s = :longitude';
            binds.put('latitude', latitude);
            binds.put('longitude', longitude);
        }

        if ('Address'.equalsIgnoreCase(searchBy)) {
            String street = locationOfInterestDTO.getRequiredString('animalos__Address__Street__s');
            String city = locationOfInterestDTO.getString('animalos__Address__City__s');
            String stateCode = locationOfInterestDTO.getString('animalos__Address__StateCode__s');
            String postalCode = locationOfInterestDTO.getString('animalos__Address__PostalCode__s');
            String countryCode = locationOfInterestDTO.getString('animalos__Address__CountryCode__s');

            if (String.isBlank(city) && String.isBlank(stateCode) && String.isBlank(postalCode) && String.isBlank(countryCode)) {
                throw new vertic_Structs.MissingDataException('Please, provide at least one address field for the search.');
            }

            List<String> conditions = new List<String>();
            if (!String.isBlank(street)) {
                street = '' + street.remove('Street').remove('St ').remove('St.').trim() + '';
                conditions.add('animalos__Address__Street__s LIKE :street');
                binds.put('street', street);
            }
            if (!String.isBlank(city)) {
                conditions.add('animalos__Address__City__s LIKE :city');
                binds.put('city', '%' + city + '%');
            }
            if (!String.isBlank(stateCode)) {
                conditions.add('animalos__Address__StateCode__s = :stateCode');
                binds.put('stateCode', stateCode);
            }
            if (!String.isBlank(postalCode)) {
                conditions.add('animalos__Address__PostalCode__s = :postalCode');
                binds.put('postalCode', postalCode);
            }
            if (!String.isBlank(countryCode)) {
                conditions.add('animalos__Address__CountryCode__s = :countryCode');
                binds.put('countryCode', countryCode);
            }

            condition = String.join(conditions, ' AND ');
        }

        if (String.isBlank(condition)) {
            throw new vertic_Structs.MissingDataException('Please, provide a valid search criteria.');
        }

        String query = new fflib_QueryFactory(animalos__Location_Of_Interest__c.SObjectType)
                .selectFields(new Set<String>{
                        'Id', 'Name', 'animalos__Address__Latitude__s',
                        'animalos__Address__Longitude__s', 'animalos__Address__Street__s',
                        'animalos__Address__City__s', 'animalos__Address__CountryCode__s',
                        'animalos__Address__PostalCode__s', 'animalos__Address__StateCode__s',
                        'POI_Time_at_Location__c', 'Number_of_Residents__c', 'Children_at_Location__c', 'Children_Details__c', 'Location_Safety_Concerns__c'
                })
                .setCondition(condition)
                .setLimit(1)
                .toSOQL();

        locationVar = (animalos__Location_Of_Interest__c) vertic_Utils.arrays.firstOrNull(Database.queryWithBinds(
                query,
                binds,
                AccessLevel.SYSTEM_MODE
        ));

        if (locationVar != null) {
            this.response.getMapper().mapFromSObject('locationOfInterest', locationVar);
            return;
        }

        locationOfInterestDTO.getMap().remove('Id');
        this.response.put('locationOfInterest', locationOfInterestDTO.getMap());

        if (String.isBlank(locationOfInterestDTO.getString('Name'))) {
            this.response.put('locationOfInterest.Name', String.format(
                    '{0}, {1}, {2} {3} {4}',
                    new List<String>{
                            vertic_Utils.objects.defaultIfNull(locationOfInterestDTO.getString('animalos__Address__Street__s'), ''),
                            vertic_Utils.objects.defaultIfNull(locationOfInterestDTO.getString('animalos__Address__City__s'), ''),
                            vertic_Utils.objects.defaultIfNull(locationOfInterestDTO.getString('animalos__Address__StateCode__s'), ''),
                            vertic_Utils.objects.defaultIfNull(locationOfInterestDTO.getString('animalos__Address__PostalCode__s'), ''),
                            vertic_Utils.objects.defaultIfNull(locationOfInterestDTO.getString('animalos__Address__CountryCode__s'), '')
                    }
            ));
        }
    }
}