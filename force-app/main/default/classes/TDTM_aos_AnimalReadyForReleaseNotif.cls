global class TDTM_aos_AnimalReadyForReleaseNotif extends animalos.TDTM.Handler implements animalos.TDTM.AfterUpdate {

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        sendReadyForReleaseNotification(records, oldMap);
    }

    private void sendReadyForReleaseNotification(List<SObject> records, Map<Id, SObject> existingRecords) {

        List<animalos__Animal__c> animalsReadyForRelease = new List<animalos__Animal__c>();

        for (animalos__Animal__c animal : (List<animalos__Animal__c>) records) {
            animalos__Animal__c existingAnimal = (animalos__Animal__c) existingRecords.get(animal.Id);
            if (animal.animalos__Current_Site__c != null && animal.aos_Animal_Released__c && vertic_Utils.sObjects.isSomeFieldChanged(
                animal, existingAnimal, new List<SObjectField>{
                    animalos__Animal__c.aos_Animal_Released__c
                }
            )) {
                animalsReadyForRelease.add(animal);
            }
        }

        if (!animalsReadyForRelease.isEmpty()) {

            EmailTemplate animalReadyForReleaseEmailTemplate = (EmailTemplate) vertic_Utils.arrays.firstOrNull([
                SELECT Id, DeveloperName, Name
                FROM EmailTemplate
                WHERE DeveloperName = 'Animal_Released_Notification_1677242995294'
            ]);

            if (animalReadyForReleaseEmailTemplate == null) {
                return;
            }

            Set<Id> shelterIds = vertic_Utils.sObjects.getIdFieldValues(animalsReadyForRelease, animalos__Animal__c.animalos__Current_Site__c);

            Map<Id, animalos__Location__c> siteLocationsById = new Map<Id, animalos__Location__c>([
                SELECT Id, aos_Shelter_Email__c
                FROM animalos__Location__c
                WHERE Id IN :shelterIds
            ]);

            if (UserInfo.getUserId() != null) {
                vertic_AsyncProcess asyncProcess = new vertic_AsyncProcess();

                for (animalos__Animal__c animal : animalsReadyForRelease) {
                    Messaging.SingleEmailMessage emailMessage = Messaging.renderStoredEmailTemplate(
                        animalReadyForReleaseEmailTemplate.Id,
                        UserInfo.getUserId(),
                        animal.Id
                    );

                    animalos__Location__c siteLocation = siteLocationsById.get(animal.animalos__Current_Site__c);

                    if (!String.isBlank(siteLocation.aos_Shelter_Email__c)) {
                        asyncProcess.add(
                            new vertic_SendEmailProc.EmailAsyncProcess(
                                emailMessage.htmlBody,
                                new List<String>{
                                    siteLocation.aos_Shelter_Email__c
                                })
                                .setSaveAsActivity(false)
                                .setOrgWideEmail('events@rspcansw.org.au')
                                .setSubject(emailMessage.getSubject())
                                .toAsyncProcess());
                    }
                }

                asyncProcess.enqueue();
            }
        }
    }
}
