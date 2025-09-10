public with sharing class CalculateOpportunityBasedRollupsProc extends vertic_LookupRollupSequentialProc.AbstractBatchableProcessor {
    public override void processScope(List<SObject> records) {
        Set<Id> contactIds = vertic_Utils.sObjects.getIdFieldValues(records, 'npsp__Primary_Contact__c');
        Map<Id, Contact> contacts = new Map<Id, Contact>([
                SELECT Id, First_Donation__c
                FROM Contact
                WHERE Id IN : contactIds
        ]);

        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([
                SELECT Id, npsp__Primary_Contact__c, CloseDate
                FROM Opportunity
                WHERE npsp__Primary_Contact__c IN : contacts.keySet() AND StageName = 'Closed Won'
        ]);

        Map<Id, List<Opportunity>> contactToOpportunities = new Map<Id, List<Opportunity>>();

        for(Opportunity opportunityVar : opportunities.values()){
            if(contactToOpportunities.keySet().contains(opportunityVar.npsp__Primary_Contact__c)){
                contactToOpportunities.get(opportunityVar.npsp__Primary_Contact__c).add(opportunityVar);
            } else {
                contactToOpportunities.put(opportunityVar.npsp__Primary_Contact__c, new List<Opportunity>{opportunityVar});
            }
        }

        List<Contact> contactsForUpdate = new List<Contact>();

        for(Contact contactVar : contacts.values()){
            Contact contactForUpdate = contactVar.clone(true, true, false, false);

            Date minCloseDate;
            for(Opportunity opportunityVar : contactToOpportunities.get(contactVar.Id)){
                if(minCloseDate == null || opportunityVar.CloseDate < minCloseDate){
                    minCloseDate = opportunityVar.CloseDate;
                }
            }
            contactForUpdate.First_Donation__c = minCloseDate;

            if (vertic_Utils.sObjects.isSomeFieldChanged(contactForUpdate, contactVar, new List<String>{'First_Donation__c'})){
                contactsForUpdate.add(contactForUpdate);
            }
        }

        update contactsForUpdate;
    }

    public override Database.QueryLocator getLocator() {
        Datetime lastProcessedDate = Datetime.valueOf(vertic_SettingService.getValue('LAST_TOTALS_UPDATE'));

        fflib_QueryFactory queryFactory = new fflib_QueryFactory(Opportunity.SObjectType);
        queryFactory.selectFields(new Set<String>{'Id', 'npsp__Primary_Contact__c', 'CloseDate'});
        queryFactory.setCondition('LastModifiedDate > ' + lastProcessedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' AND StageName = \'Closed Won\'');
        return Database.getQueryLocator(queryFactory.toSOQL());
    }
}