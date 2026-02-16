@IsTest
private class aos_JobContactsAddIntCautionMetaTest {
    @IsTest
    static void testBehavior() {
        Contact contactVar = new Contact(
                LastName = 'Test'
        );
        insert contactVar;

        animalos__Job__c job = new animalos__Job__c();
        insert job;

        animalos__Job_Contact__c jobContact = new animalos__Job_Contact__c(
                animalos__Contact__c = contactVar.Id,
                animalos__Job__c = job.Id,
                animalos__Contact_Type__c = 'Person Of Interest'
        );
        insert jobContact;

        vertic_Response response = new JobContactsAddInteractionCautionMetaProc().process(new Map<String, Object>{
                'jobContactId' => jobContact.Id
        });

        System.assert(response.isValid);
    }
}