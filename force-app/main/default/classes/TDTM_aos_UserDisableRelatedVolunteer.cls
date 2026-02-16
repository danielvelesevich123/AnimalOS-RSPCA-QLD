global class TDTM_aos_UserDisableRelatedVolunteer extends animalos.TDTM.Handler implements animalos.TDTM.AfterUpdate {
    public void onAfterUpdate(List<SObject> record, Map<Id, SObject> existingRecords) {
        this.disableRelatedVolunteer(record, existingRecords);
    }

    private void disableRelatedVolunteer(List<SObject> records, Map<Id, SObject> existingRecords) {
        List<User> users = new List<User>();

        for (User userVar : (List<User>) records) {
            User existingUser = (User) existingRecords.get(userVar.Id);

            Boolean isDisabled = !userVar.IsActive && existingUser.IsActive;
            Boolean hasContact = userVar.ContactId != null;

            if (isDisabled && hasContact) {
                users.add(userVar);
            }
        }

        if (!users.isEmpty()) {
            Set<Id> contactIds = vertic_Utils.sObjects.getIdFieldValues(users, User.ContactId);
            List<animalos__Log__c> logs = new List<animalos__Log__c>();

            Map<String, Object> locationVolunteersByContactIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                    SELECT Id, aos_Volunteer__c
                    FROM aos_Location_Volunteer__c
                    WHERE aos_Volunteer__c IN :contactIds
            ], aos_Location_Volunteer__c.aos_Volunteer__c);

            List<aos_Location_Volunteer__c> locationVolunteersForUpdate = new List<aos_Location_Volunteer__c>();

            for (User userVar : users) {
                List<aos_Location_Volunteer__c> locationVolunteers = (List<aos_Location_Volunteer__c>) locationVolunteersByContactIds.get(userVar.ContactId);

                if (locationVolunteers != null && !locationVolunteers.isEmpty()) {
                    for (aos_Location_Volunteer__c locationVolunteer : locationVolunteers) {
                        logs.add(
                                new animalos.Logging()
                                        .setProcess('TDTM_aos_UserDisableRelatedVolunteer.DisableLocationVolunteerProc')
                                        .addPayload('recordId', locationVolunteer.Id)
                                        .build()
                        );
                    }
                }
            }

            System.enqueueJob(new aos_ProcessLogQueueable(logs));
        }
    }

    public without sharing class DisableLocationVolunteerProc extends vertic_AbstractProcessor {
        public override vertic_Response process(vertic_Request request) {
            this.request = request;

            String recordId = this.request.getString('recordId');

            aos_Location_Volunteer__c locationVolunteer = (aos_Location_Volunteer__c) vertic_Utils.arrays.firstOrException([
                    SELECT Id, aos_Status__c
                    FROM aos_Location_Volunteer__c
                    WHERE Id = :recordId
            ], 'No Location Volunteer with Id: ' + recordId);

            locationVolunteer.aos_Status__c = 'Inactive';

            update locationVolunteer;

            return this.response;
        }
    }

}