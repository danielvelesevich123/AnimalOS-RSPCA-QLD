global class TDTM_UserDisableRelatedVolunteer extends animalos.TDTM.Handler implements animalos.TDTM.AfterUpdate {
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
                    SELECT Id, Volunteer__c
                    FROM Location_Volunteer__c
                    WHERE Volunteer__c IN :contactIds
            ], Location_Volunteer__c.Volunteer__c);

            List<Location_Volunteer__c> locationVolunteersForUpdate = new List<Location_Volunteer__c>();

            for (User userVar : users) {
                List<Location_Volunteer__c> locationVolunteers = (List<Location_Volunteer__c>) locationVolunteersByContactIds.get(userVar.ContactId);

                if (locationVolunteers != null && !locationVolunteers.isEmpty()) {
                    for (Location_Volunteer__c locationVolunteer : locationVolunteers) {
                        logs.add(
                                new animalos.Logging()
                                        .setProcess('TDTM_UserDisableRelatedVolunteer.DisableLocationVolunteerProc')
                                        .addPayload('recordId', locationVolunteer.Id)
                                        .build()
                        );
                    }
                }
            }

            System.enqueueJob(new AOS_ProcessLogQueueable(logs));
        }
    }

    public without sharing class DisableLocationVolunteerProc extends vertic_AbstractProcessor {
        public override vertic_Response process(vertic_Request request) {
            this.request = request;

            String recordId = this.request.getString('recordId');

            Location_Volunteer__c locationVolunteer = (Location_Volunteer__c) vertic_Utils.arrays.firstOrException([
                    SELECT Id, Status__c
                    FROM Location_Volunteer__c
                    WHERE Id = :recordId
            ], 'No Location Volunteer with Id: ' + recordId);

            locationVolunteer.Status__c = 'Inactive';

            update locationVolunteer;

            return this.response;
        }
    }

}