global without sharing class RDConsecutiveClosedLostOpps_TDTM extends npsp.TDTM_Runnable implements TDTM_Manager.InitHandler {

    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        calculateConsecutiveClosedLostOpportunities(newlist, oldlist == null ? null : new Map<Id, SObject>(oldlist), triggerAction);
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        return dmlWrapper;
    }

    global static void calculateConsecutiveClosedLostOpportunities(List<SObject> recurringDonations, Map<Id, SObject> existingRecordsMap, npsp.TDTM_Runnable.Action triggerAction) {
        Set<Id> recurringDonationIds = npsp_plus.vertic_Utils.sObjects.getIdFieldValues(recurringDonations, npe03__Recurring_Donation__c.Id);
        List<Opportunity> closedOpportunities = [
            SELECT npe03__Recurring_Donation__c, CloseDate, StageName, IsWon, Name, CreatedDate
            FROM Opportunity
            WHERE  (StageName = 'Closed Won' OR StageName = 'Closed Lost')
            AND CloseDate <=: Date.today()
            AND npe03__Recurring_Donation__c IN :recurringDonationIds
            ORDER BY  npe03__Recurring_Donation__c DESC, CloseDate ASC, CreatedDate ASC
        ];
        Map<String, List<SObject>> oppsByRDIDs = npsp_plus.vertic_Utils.sObjects.getSObjectsListByAnyFieldMap(closedOpportunities, Opportunity.npe03__Recurring_Donation__c);

        for(npe03__Recurring_Donation__c recurringDonationVar : (List<npe03__Recurring_Donation__c>)recurringDonations){
            recurringDonationVar.Consecutive_Declines__c = 0;
            List<Opportunity> oppsListVar = oppsByRDIDs?.get(recurringDonationVar.Id);
            if(oppsListVar != null){
                for(Opportunity oppVar : oppsListVar){
                    if(oppVar.IsWon == true){
                        recurringDonationVar.Consecutive_Declines__c = 0;
                    } else if('Closed Lost'.equalsIgnoreCase(oppVar.StageName)){
                        recurringDonationVar.Consecutive_Declines__c++;
                    }
                }
            }
        }
    }

    public npsp__Trigger_Handler__c initHandler() {
        return new npsp__Trigger_Handler__c(
            npsp__Object__c = '' + npe03__Recurring_Donation__c.SObjectType,
            npsp__Class__c = '' + RDConsecutiveClosedLostOpps_TDTM.class,
            npsp__Trigger_Action__c = 'BeforeUpdate',
            npsp__Active__c = true,
            npsp__User_Managed__c = true
        );
    }
}