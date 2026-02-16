global without sharing class TDTM_aos_UserUpdateRelatedLocationVol extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert {
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
            List<aos_Location_Volunteer__c> locationVolunteers = [
                    SELECT Id, aos_Volunteer__c, aos_User__c
                    FROM aos_Location_Volunteer__c
                    WHERE aos_Volunteer__c IN :contactIds
            ];

            for (aos_Location_Volunteer__c locationVolunteer : locationVolunteers) {
                locationVolunteer.aos_User__c = (Id) usersByContactIds.get(locationVolunteer.aos_Volunteer__c)?.get('Id');
            }

            update locationVolunteers;
        }
    }
}