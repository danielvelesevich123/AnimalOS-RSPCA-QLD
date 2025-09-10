global class TDTM_LocationVolunteerReshareRecords extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert, animalos.TDTM.AfterUpdate, animalos.TDTM.BeforeDelete {
    public void onAfterInsert(List<SObject> records) {
        this.reshareRecords(records, null);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.reshareRecords(records, (Map<Id, Location_Volunteer__c>) oldMap);
    }

    public void onBeforeDelete(List<SObject> records) {
        this.reshareRecords(records, null);
    }

    public void reshareRecords(List<Location_Volunteer__c> locationVolunteers, Map<Id, Location_Volunteer__c> existingRecords) {
        Set<Id> userIds = new Set<Id>();

        if (Trigger.isInsert || Trigger.isDelete) {
            userIds = vertic_Utils.sObjects.getIdFieldValues(locationVolunteers, Location_Volunteer__c.User__c);
        }

        if (Trigger.isUpdate && existingRecords != null) {
            for (Location_Volunteer__c locationVolunteer : (List<Location_Volunteer__c>) locationVolunteers) {
                if (existingRecords.containsKey(locationVolunteer.Id) &&
                        vertic_Utils.sObjects.isSomeFieldChanged(
                                locationVolunteer,
                                existingRecords.get(locationVolunteer.Id), new List<SObjectField>{
                                        Location_Volunteer__c.Location__c,
                                        Location_Volunteer__c.Volunteer__c,
                                        Location_Volunteer__c.Status__c
                                })) {
                    userIds.add(locationVolunteer.User__c);
                    userIds.add(existingRecords.get(locationVolunteer.Id)?.User__c);
                }
            }
        }

        if (!userIds.isEmpty()) {
            PartnersPortalReshareRecordsProc.submitVAPsByUserIds(userIds);
        }
    }
}