public without sharing class ContactOpportunityRollupHandler {

    private final static SObjectType TARGET_OBJECT_TYPE = Contact.SObjectType;
    private final static List<SObjectField> TARGET_FIELDS = new List<SObjectField>{
        Contact.Acquisition_Campaign__c
    };

    private final static SObjectField REFERENCE_FIELD = Opportunity.npsp__Primary_Contact__c;
    private final static List<SObjectField> SOURCE_FIELDS = new List<SObjectField>{
        Opportunity.StageName, Opportunity.CloseDate, Opportunity.CampaignId
    };

    public static Boolean IS_ENABLED = true;

    public static void recalculateOnly(List<Contact> contacts) {

        if(IS_ENABLED != true){
            return;
        }

        /*
        This is the Campaign Name of the Contacts first Donation record
        Opportunity.CampaignId
        We don’t need this field to be a lookup, this can just be a text field for now
        This maps to Contact.Acquisition_Campaign__c
         */
        Map<Id, Contact> contactOpportunitiesMap = new Map<Id, Contact>([
            SELECT Id,
                (
                    SELECT Id, CampaignId, Campaign.Name
                    FROM npsp__Opportunities__r
                    WHERE IsWon = TRUE
                    AND CampaignId != NULL
                    AND RecordType.DeveloperName = 'Donation'
                    ORDER BY CloseDate ASC NULLS LAST
                    LIMIT 1
                )
            FROM Contact
            WHERE Id IN :contacts
        ]);

        for (Contact contactVar : contacts) {
            Contact contactWithOpp = contactOpportunitiesMap.get(contactVar.Id);

            System.debug('Opp');
//            System.debug(JSON.serializePretty(contactWithOpp.npsp__Opportunities__r.isEmpty() ? null : contactVar.npsp__Opportunities__r.get(0)));

            contactVar.Acquisition_Campaign__c = contactWithOpp.npsp__Opportunities__r.isEmpty() ? null : contactWithOpp.npsp__Opportunities__r.get(0)?.Campaign?.Name;
        }
    }

    public static void recalculateAndUpdate(List<SObject> sourceRecords, Map<Id, SObject> existingSourceRecordsMap, Boolean isForceRecalculate) {

        if(IS_ENABLED != true){
            return;
        }

        Set<Id> recordIds = new Set<Id>();

        for (SObject sourceVar : sourceRecords) {
            SObject existingSourceVar = existingSourceRecordsMap?.get(sourceVar.Id);

            Boolean isNew = existingSourceVar == null;
            Boolean isChanged = isNew == true || vertic_Utils.sObjects.isSomeFieldChanged(sourceVar, existingSourceVar, SOURCE_FIELDS);

            if ((isForceRecalculate == true || isNew == true || isChanged == true) && sourceVar.get(REFERENCE_FIELD) != null) {
                recordIds.add((Id)sourceVar.get(REFERENCE_FIELD));
            }
        }

        if(recordIds.isEmpty()){
            return;
        }

        fflib_QueryFactory query = new fflib_QueryFactory(TARGET_OBJECT_TYPE);
        query.selectFields(TARGET_FIELDS);
        query.setCondition('Id IN :recordIds');

        List<SObject> records = Database.query(query.toSOQL());

        Map<Id, SObject> sourceRecordsMap = new Map<Id, SObject>(records).deepClone();

        recalculateOnly(records);

        List<SObject> recordsToUpdate = new List<SObject>();

        for (SObject recordVar : records) {
            SObject sourceRecordVar = sourceRecordsMap.get(recordVar.Id);

            Boolean isUpdated = vertic_Utils.sObjects.isSomeFieldChanged(
                recordVar,
                sourceRecordVar,
                TARGET_FIELDS
            );

            if(isUpdated == true){
                recordsToUpdate.add(recordVar);
            }
        }

        IS_ENABLED = false;
        update recordsToUpdate;
        IS_ENABLED = true;
    }
}