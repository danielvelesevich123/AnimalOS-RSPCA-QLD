@IsTest
private class vertic_DMLBatchTest {

    static testMethod void testBehavior1() {

        Contact contactVar = new Contact(
            FirstName = 'test',
            LastName = 'test',
            Email = 'test@test.com'
        );
        insert contactVar;

        List<Opportunity> opportunitiesVar = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunitiesVar.add(new Opportunity(
                Name = i + ' - test',
                StageName = i + ' - test',
                CloseDate = System.now().date()
            ));
        }
        insert opportunitiesVar;

        List<Opportunity> opportunities = new List<Opportunity>([SELECT Id FROM Opportunity WHERE Name = '3 - test']);
        System.assertEquals(1, opportunities.size());

        Test.startTest();

        Database.executeBatch(new vertic_DMLBatch(
            Opportunity.SObjectType,
            'Name = \'3 - test\''
        ).setDeleteOperation());

        Test.stopTest();

        opportunities = new List<Opportunity>([SELECT Id FROM Opportunity WHERE Name = '3 - test']);
        System.assertEquals(0, opportunities.size());
    }

    static testMethod void testBehavior2() {
        Contact contactVar = new Contact(
            FirstName = 'test',
            LastName = 'test',
            Email = 'test@test.com'
        );
        insert contactVar;

        List<Opportunity> opportunitiesVar = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunitiesVar.add(new Opportunity(
                Name = i + ' - test',
                StageName = i + ' - test',
                CloseDate = System.now().date()
            ));
        }
        insert opportunitiesVar;

        Test.startTest();

        Database.executeBatch(new vertic_DMLBatch(
            Opportunity.SObjectType,
            'Name = \'4 - test\''
        ));

        Test.stopTest();

        List<Opportunity> opportunities = new List<Opportunity>([SELECT Id FROM Opportunity WHERE Name = '4 - test']);
        System.assertEquals(1, opportunities.size());
    }


    static testMethod void testBehavior3() {

        Contact contactVar = new Contact(
            FirstName = 'test',
            LastName = 'test',
            Email = 'test@test.com'
        );
        insert contactVar;

        List<Opportunity> opportunitiesVar = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunitiesVar.add(new Opportunity(
                Name = i + ' - test',
                StageName = i + ' - test',
                CloseDate = System.now().date()
            ));
        }
        insert opportunitiesVar;


        Test.startTest();

        Database.executeBatch(new vertic_DMLBatch(
            Opportunity.SObjectType
        ).setDeleteOperation());

        Test.stopTest();


        List<Opportunity> opportunities = new List<Opportunity>([SELECT Id FROM Opportunity]);
        System.assertEquals(0, opportunities.size());

    }
}