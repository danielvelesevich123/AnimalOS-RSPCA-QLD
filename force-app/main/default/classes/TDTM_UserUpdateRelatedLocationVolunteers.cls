global without sharing class TDTM_UserUpdateRelatedLocationVolunteers extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert {
    public void onAfterInsert(List<SObject> records) {
        System.debug('TDTM_UserUpdateRelatedLocationVolunteers.onAfterInsert() - records: ' + records);
        this.updateRelatedLocationVolunteers(records);
    }

    public void updateRelatedLocationVolunteers(List<SObject> records) {
        Set<Id> contactIds = new Set<Id>();
        for (User userVar : (List<User>) records) {
            if (Trigger.isInsert && String.isNotBlank(userVar.ContactId) && PartnersPortalReshareRecordsProc.PARTNERS_PORTAL_PROFILE_IDS.contains(userVar.ProfileId)) {
                contactIds.add(userVar.ContactId);
            }
        }

        if (!contactIds.isEmpty()) {
            Map<String, SObject> usersByContactIds = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(records, Schema.User.ContactId);
            List<Location_Volunteer__c> locationVolunteers = [
                    SELECT Id, Volunteer__c, User__c
                    FROM Location_Volunteer__c
                    WHERE Volunteer__c IN :contactIds
            ];

            for (Location_Volunteer__c locationVolunteer : locationVolunteers) {
                locationVolunteer.User__c = (Id) usersByContactIds.get(locationVolunteer.Volunteer__c)?.get('Id');
            }

            update locationVolunteers;
        }
    }
}