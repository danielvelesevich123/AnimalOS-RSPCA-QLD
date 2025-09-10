@isTest
public without sharing class CampaignMemberRollup_TDTMTest {

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

        Test.startTest();
        insert campaignMemberVar;
        Test.stopTest();
        cnt = [SELECT Engagement_Campaign__c FROM Contact LIMIT 1];

        System.assertEquals(cnt.Engagement_Campaign__c, campaignVar.Name, 'Engagement_Campaign__c should be populated');
    }
}