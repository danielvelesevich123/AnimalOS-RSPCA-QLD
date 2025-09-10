@isTest
public without sharing class OpportunityRollup_TDTMTest {

    @isTest
    static void testUpdate() {
        TDTM_Manager.init();
        Account acc = new Account(Name='test');
        insert acc;
        Contact cnt = new Contact(FirstName = 'test', LastName='test', Email='test@test.test', AccountId = acc.Id);
        insert cnt;
        Campaign campaignVar = new Campaign(Name='test');
        insert campaignVar;
        CampaignMember campaignMemberVar = new CampaignMember(
            ContactId = cnt.Id,
            CampaignId = campaignVar.Id,
            Status = 'Responded'
        );
        Opportunity opp = new Opportunity(
            Name = 'Opp1',
            npsp__Primary_Contact__c = cnt.Id,
            CloseDate = System.today(),
            StageName = 'Closed Won',
            CampaignId = campaignVar.Id,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId()
        );

        Test.startTest();
        insert opp;
        Test.stopTest();
        cnt = [SELECT Acquisition_Campaign__c FROM Contact LIMIT 1];

        System.assertEquals(cnt.Acquisition_Campaign__c, campaignVar.Name, 'Acquisition_Campaign__c should be populated');
    }
}