global without sharing class OpportunityRollup_TDTM extends npsp.TDTM_Runnable implements TDTM_Manager.InitHandler {
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        Boolean isDelete = triggerAction == Action.AfterDelete;

        ContactOpportunityRollupHandler.recalculateAndUpdate(
            isDelete ? oldlist : newlist,
            oldlist == null ? null : new Map<Id, SObject>(oldlist),
            isDelete
        );

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        return dmlWrapper;
    }

    public npsp__Trigger_Handler__c initHandler() {
        return new npsp__Trigger_Handler__c(
            npsp__Active__c = true,
            npsp__Class__c = '' + OpportunityRollup_TDTM.class,
            npsp__Object__c = '' + Opportunity.SObjectType,
            npsp__Trigger_Action__c = 'AfterInsert,AfterUpdate;AfterDelete',
            npsp__User_Managed__c = true
        );
    }
}