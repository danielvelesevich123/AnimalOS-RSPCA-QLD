@IsTest
private class rspcaqldCampaignTest {
    @IsTest
    static void rspcaqldCampaignTest() {
        Campaign eventOne = new Campaign(
            Name = 'Test Campaign',
            StartDate = Date.today(),
            EndDate = Date.today().addDays(2),
            Show_on_Website__c = TRUE,
            RecordTypeId = Campaign.SObjectType.getDescribe().getRecordTypeInfosByName().get('Event').getRecordTypeId()
        );
        insert eventOne;

        Campaign eventTwo = new Campaign(
            Name = 'Test Campaign 2',
            StartDate = Date.today(),
            EndDate = Date.today().addDays(2),
            Show_on_Website__c = TRUE,
            RecordTypeId = Campaign.SObjectType.getDescribe().getRecordTypeInfosByName().get('Event').getRecordTypeId()
        );
        insert eventTwo;

        Test.startTest();
        List<rspcaqldCampaignService.CampaignWrapper> campaignList = rspcaqldCampaignService.getPortalActiveCampaigns();
        System.assertEquals(2, campaignList.size());

        List<rspcaqldCampaignService.CampaignWrapper> campaignIdsList = rspcaqldCampaignService.getPortalCampaignsByIdsString(String.format('{0},{1}', new List<String>{eventOne.Id, eventTwo.Id}));
        System.assertEquals(2, campaignIdsList.size());

        rspcaqldCampaignService.CampaignWrapper cmpgn = rspcaqldCampaignService.getCampaignById(eventOne.Id);
        System.assertEquals(eventOne.Id, cmpgn.record.Id);

        Test.stopTest();
    }
}