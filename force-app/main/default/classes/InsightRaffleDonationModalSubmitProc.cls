public class InsightRaffleDonationModalSubmitProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        this.response.put('petSupporterCampaignId', findExistingCampaignOrCreateNew(this.request.getString('insightRaffleCampaignName')));
    }

    private Id findExistingCampaignOrCreateNew(String campaignName){
        Campaign campaignVar = (Campaign) vertic_Utils.arrays.firstOrNull(
        [SELECT Id FROM Campaign WHERE Name =: campaignName]
        );

        if (campaignVar == null) {
            campaignVar = new Campaign(
                RecordTypeId = vertic_Utils.sObjects.recordTypeIdByName(Campaign.getSObjectType(), 'Fundraising'),
                Name = campaignName,
                Program__c = 'Individual Giving',
                Type = 'Fundraiser',
                Purpose__c = 'Acquisition',
                npsp_plus__Channel__c = 'Third Party',
                Status = 'Completed',
                IsActive = false
            );

            insert campaignVar;
        }

        return campaignVar.Id;
    }

}