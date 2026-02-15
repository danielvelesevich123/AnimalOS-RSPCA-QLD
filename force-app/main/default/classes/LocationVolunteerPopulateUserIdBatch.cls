global class LocationVolunteerPopulateUserIdBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, aos_Volunteer__c FROM aos_Location_Volunteer__c');
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Set<Id> contactIds = vertic_Utils.sObjects.getIdFieldValues(scope, aos_Location_Volunteer__c.aos_Volunteer__c);
        Map<String, SObject> usersByContactIds = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, ContactId
                FROM User
                WHERE ContactId IN :contactIds
                AND Profile.Name IN :PartnersPortalReshareRecordsProc.PARTNERS_PORTAL_PROFILE_NAMES
                AND IsActive = TRUE
        ], User.ContactId);

        for (aos_Location_Volunteer__c locationVolunteer : (List<aos_Location_Volunteer__c>) scope) {
            if (usersByContactIds.containsKey(locationVolunteer.aos_Volunteer__c)) {
                locationVolunteer.aos_User__c = (Id) usersByContactIds.get(locationVolunteer.aos_Volunteer__c)?.get('Id');
            }
        }

        update scope;
    }

    global void finish(Database.BatchableContext BC) {
    }

}