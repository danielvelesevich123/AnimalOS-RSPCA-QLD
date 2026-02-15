global class TDTM_LocationVolunteerPopulateUserId extends animalos.TDTM.Handler implements animalos.TDTM.BeforeInsert, animalos.TDTM.BeforeUpdate {
    public void onBeforeInsert(List<SObject> records) {
        this.populateUserId(records, null);
    }

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> existingRecordsMap) {
        this.populateUserId(records, existingRecordsMap);
    }

    public void populateUserId(List<SObject> records, Map<Id, SObject> existingRecordsMap) {
        Set<Id> contactIds = new Set<Id>();
        for (aos_Location_Volunteer__c locationVolunteer : (List<aos_Location_Volunteer__c>) records) {
            Boolean isInsert = Trigger.isInsert;
            Boolean isUpdate = Trigger.isUpdate && existingRecordsMap != null &&
                    existingRecordsMap.containsKey(locationVolunteer.Id) &&
                    vertic_Utils.sObjects.isSomeFieldChanged(locationVolunteer, existingRecordsMap.get(locationVolunteer.Id), new List<SObjectField>{
                            aos_Location_Volunteer__c.aos_Volunteer__c
                    });
            if ((isInsert || isUpdate) && String.isNotBlank(locationVolunteer.aos_Volunteer__c)) {
                contactIds.add(locationVolunteer.aos_Volunteer__c);
            }
        }

        if (!contactIds.isEmpty()) {
            Map<String, SObject> usersByContactIds = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                    SELECT Id, Name, ContactId
                    FROM User
                    WHERE ContactId IN :contactIds
                    AND Profile.Name IN :PartnersPortalReshareRecordsProc.PARTNERS_PORTAL_PROFILE_NAMES
                    AND IsActive = TRUE
            ], User.ContactId);

            for (aos_Location_Volunteer__c locationVolunteer : (List<aos_Location_Volunteer__c>) records) {
                if (usersByContactIds.containsKey(locationVolunteer.aos_Volunteer__c)) {
                    locationVolunteer.aos_User__c = (Id) usersByContactIds.get(locationVolunteer.aos_Volunteer__c)?.get('Id');
                }
            }
        }
    }
}