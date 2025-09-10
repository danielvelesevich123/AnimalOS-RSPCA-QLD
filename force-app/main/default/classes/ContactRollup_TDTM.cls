global without sharing class ContactRollup_TDTM extends npsp.TDTM_Runnable implements TDTM_Manager.InitHandler {
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            ContactCampaignMemberRollupHandler.recalculateOnly(newlist);
            ContactOpportunityRollupHandler.recalculateOnly(newlist);
        }

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        return dmlWrapper;
    }

    public npsp__Trigger_Handler__c initHandler() {
        return new npsp__Trigger_Handler__c(
                npsp__Active__c = true,
                npsp__Class__c = '' + ContactRollup_TDTM.class,
                npsp__Object__c = '' + Contact.SObjectType,
                npsp__Trigger_Action__c = 'BeforeUpdate',
                npsp__User_Managed__c = true
        );
    }
}