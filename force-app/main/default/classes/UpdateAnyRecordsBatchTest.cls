@IsTest
private class UpdateAnyRecordsBatchTest {
    static testMethod void testBehavior() {
        Contact contactVar = new Contact(
            FirstName = 'test',
            LastName = 'test',
            Email = 'test@test.com'
        );
        insert contactVar;
        contactVar.FirstName = 'Test1';

        Test.startTest();

        Database.executeBatch(new UpdateAnyRecordsBatch(
            'SELECT Id FROM Contact',
            true,
            new Map<SObjectField, Object>{
                Contact.FirstName => 'Test1'
            }
        ));

        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE FirstName = 'Test1'], 'Proc did not update record');
    }
}