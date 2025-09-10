public without sharing class ContactCampaignMemberRollupHandler {

    private final static SObjectType TARGET_OBJECT_TYPE = Contact.SObjectType;
    private final static List<SObjectField> TARGET_FIELDS = new List<SObjectField>{
        Contact.Engagement_Campaign__c, Contact.Last_Event_Attended_Date__c
    };

    private final static SObjectField REFERENCE_FIELD = CampaignMember.ContactId;
    private final static List<SObjectField> SOURCE_FIELDS = new List<SObjectField>{
        CampaignMember.Status
    };

    public static Boolean IS_ENABLED = true;

    public static void recalculateOnly(List<Contact> contacts) {

        if(IS_ENABLED != true){
            return;
        }

        /*
        Retrieve the Campaign Name of the most recent Campaign that the Contact attended.  The logic is:
        Campaign.RecordType = Event
        The Contact has a Campaign Member record WHERE HasResponded = TRUE
        Populate Contact.Last_Event_Attended_Date with the Campaign.StartDate
         */
        Map<Id, Contact> contactsLastEventAttendedMap = new Map<Id, Contact>([
            SELECT Id,
                (
                    SELECT Id, CampaignId, Campaign.Name, Campaign.StartDate, HasResponded
                    FROM CampaignMembers
                    WHERE Campaign.RecordType.DeveloperName = 'Event'
                    AND Status = 'Attended'
                    ORDER BY Campaign.StartDate DESC NULLS LAST
                    LIMIT 1
                )
            FROM Contact
            WHERE Id IN :contacts
        ]);

        /*
        Retrieve the Campaign Name of the first Campaign that the Contact responded to
        This can be taken from the first Campaign Member record WHERE HasResponded = TRUE
        Set Contact.Engagement_Campaign__c with the Campaign Name
         */
        Map<Id, Contact> contactsEngagementCampaignMap = new Map<Id, Contact>([
            SELECT Id,
            (
                SELECT Id, CampaignId, Campaign.Name, HasResponded
                FROM CampaignMembers
                WHERE Status = 'Responded'
                ORDER BY FirstRespondedDate ASC, Id ASC
                LIMIT 1
            )
            FROM Contact
            WHERE Id IN :contacts
        ]);

        for (Contact contactVar : contacts) {
            Contact contactLastEventAttended = contactsLastEventAttendedMap.get(contactVar.Id);
            contactVar.Last_Event_Attended_Date__c = contactLastEventAttended.CampaignMembers.isEmpty() ? null : contactLastEventAttended.CampaignMembers.get(0).Campaign.StartDate;

            Contact contactEngagementCampaign = contactsEngagementCampaignMap.get(contactVar.Id);
            contactVar.Engagement_Campaign__c = contactEngagementCampaign.CampaignMembers.isEmpty() ? null : contactEngagementCampaign.CampaignMembers.get(0).Campaign.Name;
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