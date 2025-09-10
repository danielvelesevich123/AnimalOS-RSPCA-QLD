public without sharing class GAUAllocationsBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator('SELECT Id, CampaignId, Amount FROM Opportunity WHERE Amount > 0 AND CampaignId IN (SELECT npsp__Campaign__c FROM npsp__Allocation__c WHERE npsp__Opportunity__c = null AND npsp__Campaign__c != null) AND Id NOT IN (SELECT npsp__Opportunity__c FROM npsp__Allocation__c WHERE npsp__Opportunity__c != null)');
    }

    public void execute(Database.BatchableContext param1, List<Opportunity> opportunities) {
        Set<Id> campaignIds = vertic_Utils.sObjects.getIdFieldValues(opportunities, Opportunity.CampaignId);
        Map<String, List<SObject>> allocationsByCampaignId = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
            SELECT Id, npsp__General_Accounting_Unit__c, npsp__Amount__c, npsp__Percent__c, npsp__Campaign__c, npsp__Recurring_Donation__c
            FROM npsp__Allocation__c
            WHERE npsp__Campaign__c IN :campaignIds AND npsp__Opportunity__c = null
        ], npsp__Allocation__c.npsp__Campaign__c);

        List<npsp__Allocation__c> opportunityAllocations = new List<npsp__Allocation__c>();
        for (Opportunity opportunityVar : opportunities) {
            List<SObject> allocations = allocationsByCampaignId.get(opportunityVar.CampaignId);
            for (npsp__Allocation__c allocationVar : (List<npsp__Allocation__c>) allocations) {
                npsp__Allocation__c oppAllocation = allocationVar.clone();
                oppAllocation.Id = null;
                oppAllocation.npsp__Campaign__c = null;
                oppAllocation.npsp__Opportunity__c = opportunityVar.Id;
                if (oppAllocation.npsp__Percent__c != null && oppAllocation.npsp__Amount__c == null) {
                    oppAllocation.npsp__Amount__c = opportunityVar.Amount * oppAllocation.npsp__Percent__c / 100;
                }
                opportunityAllocations.add(oppAllocation);
            }
        }
        insert opportunityAllocations;
    }

    public void finish(Database.BatchableContext param1) {
    }

}