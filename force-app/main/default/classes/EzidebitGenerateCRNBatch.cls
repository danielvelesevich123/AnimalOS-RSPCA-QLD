public class EzidebitGenerateCRNBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{

    private String campaignId;

    public EzidebitGenerateCRNBatch(String campaignId){
        this.campaignId = campaignId;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT ContactId' +
                                        ' FROM CampaignMember' +
                                        ' WHERE Contact.BPAY_CRN__c = NULL' +
                                        ' AND Contact.BPAY_Contract_Reference__c != NULL' +
                                        ' AND CampaignId = \'' + this.campaignId + '\'');
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {

        try {
            new ContactGenerateCRNActionSubmitProc().process(new vertic_Request(new Map<String, Object>{
                'recordId' => scope[0].get('ContactId')
            }));
        } catch (Exception e){
            System.debug(scope[0].get('ContactId'));
            System.debug(e.getMessage());
        }

    }

    public void finish(Database.BatchableContext context) {
        System.debug('EzidebitGenerateCRNBatch finished!');
    }
}