global class TDTM_aos_LocationVolunteerReshareRecords extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert, animalos.TDTM.AfterUpdate, animalos.TDTM.BeforeDelete {
    public void onAfterInsert(List<SObject> records) {
        this.reshareRecords(records, null);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.reshareRecords(records, (Map<Id, aos_Location_Volunteer__c>) oldMap);
    }

    public void onBeforeDelete(List<SObject> records) {
        this.reshareRecords(records, null);
    }

    public void reshareRecords(List<aos_Location_Volunteer__c> locationVolunteers, Map<Id, aos_Location_Volunteer__c> existingRecords) {
        Set<Id> userIds = new Set<Id>();

        if (Trigger.isInsert || Trigger.isDelete) {
            userIds = aos_Utils.sObjects.getIdFieldValues(locationVolunteers,aos_Location_Volunteer__c.aos_User__c);
        }

        if (Trigger.isUpdate && existingRecords != null) {
            for (aos_Location_Volunteer__c locationVolunteer : (List<aos_Location_Volunteer__c>) locationVolunteers) {
                if (existingRecords.containsKey(locationVolunteer.Id) &&
                        aos_Utils.sObjects.isSomeFieldChanged(
                                locationVolunteer,
                                existingRecords.get(locationVolunteer.Id), new List<SObjectField>{
                                        aos_Location_Volunteer__c.aos_Location__c,
                                        aos_Location_Volunteer__c.aos_Volunteer__c,
                                        aos_Location_Volunteer__c.aos_Status__c
                                })) {
                    userIds.add(locationVolunteer.aos_User__c);
                    userIds.add(existingRecords.get(locationVolunteer.Id)?.aos_User__c);
                }
            }
        }

        if (!userIds.isEmpty()) {
            aos_PartnersPortalReshareRecordsProc.submitVAPsByUserIds(userIds);
        }
    }
}