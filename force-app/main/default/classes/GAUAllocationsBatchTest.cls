@IsTest
private class GAUAllocationsBatchTest {
    static testMethod void testBehavior() {
        Account acc = new Account(Name='test');
        insert acc;
        Contact cnt = new Contact(FirstName = 'Test', LastName='test', Email='test@test.test', AccountId = acc.Id);
        insert cnt;
        Campaign campaignVar = new Campaign(Name='test');
        insert campaignVar;
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name = 'Test');
        insert gau;

        Opportunity oppVar = new Opportunity(StageName = 'Closed Won', Amount = 100, CloseDate = Date.today(), Name = 'Test', AccountId = acc.Id, CampaignId = campaignVar.Id);
        insert oppVar;

        npsp__Allocation__c allocation = new npsp__Allocation__c(npsp__Campaign__c = campaignVar.Id, npsp__General_Accounting_Unit__c = gau.Id, npsp__Percent__c = 100);
        insert allocation;

        System.assertEquals(0, [SELECT COUNT() FROM npsp__Allocation__c WHERE npsp__Opportunity__c = :oppVar.Id]);

        Test.startTest();
        Database.executeBatch(new GAUAllocationsBatch(), 200);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM npsp__Allocation__c WHERE npsp__Opportunity__c = :oppVar.Id]);
    }
}