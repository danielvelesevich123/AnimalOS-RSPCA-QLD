global without sharing class OpportunityCallRDUpdate_TDTM extends npsp.TDTM_Runnable implements TDTM_Manager.InitHandler {

    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        updateRecurringDonations(newlist, oldlist == null ? null : new Map<Id, SObject>(oldlist), triggerAction);

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        return dmlWrapper;
    }

    global static void updateRecurringDonations(List<SObject> opportunities, Map<Id, SObject> existingRecordsMap, npsp.TDTM_Runnable.Action triggerAction) {
        Boolean isDeleted = triggerAction == npsp.TDTM_Runnable.Action.AfterDelete;
        Boolean isNew = triggerAction == npsp.TDTM_Runnable.Action.AfterInsert;
        if (isDeleted == true) {
            opportunities = existingRecordsMap.values();
        }

        List<Opportunity> oppsToProcess = new List<Opportunity>();

        for (Opportunity oppVar : (List<Opportunity>) opportunities) {

            Opportunity existingOppVar = (Opportunity) existingRecordsMap?.get(oppVar.Id);
            Boolean isUpdated = existingOppVar != null && npsp_plus.vertic_Utils.sObjects.isSomeFieldChanged(oppVar, existingOppVar,
                new List<SObjectField>{
                    Opportunity.StageName,
                    Opportunity.npe03__Recurring_Donation__c
                }
            );

            if (isDeleted == true || isNew == true) {
                oppsToProcess.add(oppVar);
            }
            if (isUpdated == true) {
                oppsToProcess.add(oppVar); oppsToProcess.add(existingOppVar);
            }
        }

        Set<Id> recurringDonationIds = npsp_plus.vertic_Utils.sObjects.getIdFieldValues(oppsToProcess, Opportunity.npe03__Recurring_Donation__c);
        List<SObject> recurringDonations = npsp_plus.vertic_Utils.sObjects.getSobjectsFromIds(npe03__Recurring_Donation__c.SObjectType, recurringDonationIds);
        update recurringDonations;

    }

    public npsp__Trigger_Handler__c initHandler() {
        return new npsp__Trigger_Handler__c(
            npsp__Object__c = '' + Opportunity.SObjectType,
            npsp__Class__c = '' + OpportunityCallRDUpdate_TDTM.class,
            npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete',
            npsp__Active__c = true,
            npsp__User_Managed__c = true
        );
    }
}