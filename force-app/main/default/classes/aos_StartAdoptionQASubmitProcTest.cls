@IsTest
private class aos_StartAdoptionQASubmitProcTest {
    @IsTest
    static void testBehavior() {
        Contact contactVar = new Contact(
                LastName = 'StartAdoptionQASubmitProc',
                Email = 'SurrenderApplicationSubmitProcTest@mail.com'
        );
        Contact alternateContactVar = new Contact(
                FirstName = 'Alternate',
                LastName = 'StartAdoptionQASubmitProcAlternate',
                Email = 'StartAdoptionQASubmitProcAlternate@test.com'
        );
        insert new List<Contact>{contactVar, alternateContactVar};

        animalos__Breed__c animalBreed = new animalos__Breed__c(
                animalos__Type__c = 'Dog',
                Name = 'Test Breed'
        );
        insert animalBreed;

        animalos__Animal__c animalVar = new animalos__Animal__c(
                animalos__Animal_Name__c = 'Test',
                animalos__Date_of_Birth__c = Date.today(),
                animalos__Class__c = 'Domestic',
                animalos__Type__c = 'Dog',
                animalos__Age_Group__c = 'Young Adult 6 mths - 1 yr',
                animalos__Stage__c = 'Under Care',
                animalos__Status__c = 'Hold Isolation',
                aos_Is_New__c = false,
                animalos__Primary_Breed__c = animalBreed.Id
        );
        insert animalVar;


        aos_Request request = new aos_Request(new Map<String, Object>{
                'contact' => contactVar,
                'alternateContact' => alternateContactVar,
                'recordId' => animalVar.Id
        });
        request.getMapper().mapFromSObject('contact', contactVar);
        request.getMapper().mapFromSObject('alternateContact', alternateContactVar);


        aos_Response response = new aos_StartAdoptionQASubmitProc().process(request);
        System.assertEquals(response.isValid, true);

    }
}