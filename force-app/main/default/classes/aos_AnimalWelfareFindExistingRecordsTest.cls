@IsTest
private class aos_AnimalWelfareFindExistingRecordsTest {
    @IsTest
    static void testBehavior() {
        animalos__Location_Of_Interest__c location = new animalos__Location_Of_Interest__c(
                animalos__Address__CountryCode__s = 'AU',
                animalos__Address__StateCode__s = 'NSW',
                animalos__Address__Street__s = '201 Rookwood Road'
        );
        insert location;

        animalos__Job__c job = new animalos__Job__c(
                animalos__Address__CountryCode__s = 'AU',
                animalos__Address__StateCode__s = 'NSW',
                animalos__Address__Street__s = '201 Rookwood Road',
                animalos__Location_Of_Interest__c = location.Id
        );
        insert job;

        Contact contactVar = new Contact(
                LastName = 'Test',
                MailingCountry = 'Australia',
                MailingState = 'NSW',
                MailingStreet = '201 Rookwood Road'
        );

        aos_Request request = new aos_Request();
        request.getMapper().mapFromSObject('jobContact', new animalos__Job_Contact__c(
                animalos__Contact__r = contactVar,
                animalos__Job__c = job.Id,
                animalos__Contact_Type__c = 'Informant'
        ));
        request.getMapper().mapFromSObject('job', job);

        aos_Response response = new aos_AnimalWelfareFindExistingRecords().process(request);

        System.assert(response.isValid);
    }
}