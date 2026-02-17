public without sharing class aos_AnimalWelfareLOISearchProc extends aos_AbstractProcessor implements aos_Structs.IRollbackable {

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.search();

        return this.response;
    }

    private void search() {
        aos_DTO locationOfInterestDTO = this.request.getDTO('locationOfInterest');
        String searchBy = this.request.getRequiredString('searchBy');
        animalos__Location_Of_Interest__c locationVar;
        String condition;
        Map<String, Object> binds = new Map<String, Object>();
        Decimal latitude = locationOfInterestDTO.getDecimal('animalos__Address__Latitude__s');
        Decimal longitude = locationOfInterestDTO.getDecimal('animalos__Address__Longitude__s');
        String street = locationOfInterestDTO.getString('animalos__Address__Street__s');
        String city = locationOfInterestDTO.getString('animalos__Address__City__s');
        String stateCode = locationOfInterestDTO.getString('animalos__Address__StateCode__s');
        String postalCode = locationOfInterestDTO.getString('animalos__Address__PostalCode__s');
        String countryCode = locationOfInterestDTO.getString('animalos__Address__CountryCode__s');

        if ('Id'.equalsIgnoreCase(searchBy)) {
            String locationOfInterestId = this.request.getRequiredString('locationOfInterest.Id');
            condition = 'Id = :locationOfInterestId';
            binds.put('locationOfInterestId', locationOfInterestId);
        }

        if ('Coordinates'.equalsIgnoreCase(searchBy)) {
            if (latitude == null || longitude == null) {
                throw new aos_Structs.MissingDataException('Please, provide both latitude and longitude for the search.');
            }

            condition = 'animalos__Address__Latitude__s = :latitude AND animalos__Address__Longitude__s = :longitude';
            binds.put('latitude', latitude);
            binds.put('longitude', longitude);
        }

        if ('Address'.equalsIgnoreCase(searchBy)) {
            List<String> conditions = new List<String>();
            if (!String.isBlank(street)) {
                street = '' + street.remove('Street').remove('St ').remove('St.').trim() + '';
                conditions.add('animalos__Address__Street__s LIKE :street');
                binds.put('street', street);
            } else {
                throw new aos_Structs.MissingDataException('Please, provide the street for the search.');
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
            throw new aos_Structs.MissingDataException('Please, provide a valid search criteria.');
        }

        String query = new aos_QueryFactory(animalos__Location_Of_Interest__c.SObjectType)
                .selectFields(new Set<String>{
                        'Id', 'Name', 'animalos__Address__Latitude__s',
                        'animalos__Address__Longitude__s', 'animalos__Address__Street__s',
                        'animalos__Address__City__s', 'animalos__Address__CountryCode__s',
                        'animalos__Address__PostalCode__s', 'animalos__Address__StateCode__s',
                        'aos_POI_Time_at_Location__c', 'aos_Number_of_Residents__c', 'aos_Children_at_Location__c', 'aos_Children_Details__c', 'aos_Location_Safety_Concerns__c'
                })
                .setCondition(condition)
                .setLimit(1)
                .toSOQL();

        locationVar = (animalos__Location_Of_Interest__c) aos_Utils.arrays.firstOrNull(Database.queryWithBinds(
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

        if (String.isBlank(locationOfInterestDTO.getString('Name')) && String.isNotBlank(street)) {
            this.response.put('locationOfInterest.Name', String.format(
                    '{0}, {1}, {2} {3} {4}',
                    new List<String>{
                            aos_Utils.objects.defaultIfNull(locationOfInterestDTO.getString('animalos__Address__Street__s'), ''),
                            aos_Utils.objects.defaultIfNull(locationOfInterestDTO.getString('animalos__Address__City__s'), ''),
                            aos_Utils.objects.defaultIfNull(locationOfInterestDTO.getString('animalos__Address__StateCode__s'), ''),
                            aos_Utils.objects.defaultIfNull(locationOfInterestDTO.getString('animalos__Address__PostalCode__s'), ''),
                            aos_Utils.objects.defaultIfNull(locationOfInterestDTO.getString('animalos__Address__CountryCode__s'), '')
                    }
            ));
        }
    }
}