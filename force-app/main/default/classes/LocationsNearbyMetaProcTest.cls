@IsTest
private class LocationsNearbyMetaProcTest {

    @TestSetup static void testSetup() {
        animalos__Location_Of_Interest__c location = new animalos__Location_Of_Interest__c(
                animalos__Address__CountryCode__s = 'AU',
                animalos__Address__StateCode__s = 'NSW',
                animalos__Address__City__s = 'Sydney',
                animalos__Address__Street__s = '17 Phillip Street',
                animalos__Address__PostalCode__s = '2000',
                animalos__Address__Latitude__s = -33.85608,
                animalos__Address__Longitude__s = 151.17963
        );
        insert location;

        animalos__Job__c job = new animalos__Job__c(
                animalos__Location_Of_Interest__c = location.Id,
                animalos__Address__CountryCode__s = 'AU',
                animalos__Address__StateCode__s = 'NSW',
                animalos__Address__City__s = 'Sydney',
                animalos__Address__Street__s = '17 Phillip Street',
                animalos__Address__PostalCode__s = '2000',
                animalos__Address__Latitude__s = -33.85608,
                animalos__Address__Longitude__s = 151.17963
        );
        insert job;
    }

    @IsTest
    static void testJobId() {
        vertic_Response response = new LocationsNearbyMetaProc().process(new Map<String, Object>{
                'recordId' => [
                        SELECT Id
                        FROM animalos__Job__c
                ].Id
        });
    }

    @IsTest
    static void testLocationId() {
        vertic_Response response = new LocationsNearbyMetaProc().process(new Map<String, Object>{
                'recordId' => [
                        SELECT Id
                        FROM animalos__Location_Of_Interest__c
                ].Id
        });
    }
}