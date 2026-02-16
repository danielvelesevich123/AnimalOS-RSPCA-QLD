global class TDTM_aos_VetConsultSetAnimalAttendingVet extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert, animalos.TDTM.AfterUpdate {
    public void onAfterInsert(List<SObject> records) {
        this.setAnimalAttendingVet(records, null);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> existingRecords) {
        this.setAnimalAttendingVet(records, existingRecords);
    }

    private void setAnimalAttendingVet(List<SObject> records, Map<Id, SObject> existingRecords) {
        List<animalos__Vet_Consult__c> vetConsults = new List<animalos__Vet_Consult__c>();

        for (animalos__Vet_Consult__c vetConsult : (List<animalos__Vet_Consult__c>) records) {
            Boolean isCreated = Trigger.isInsert && existingRecords == null;
            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingRecords.get(vetConsult.Id) != null &&
                    aos_Utils.sObjects.isSomeFieldChanged(
                            vetConsult,
                            existingRecords.get(vetConsult.Id),
                            new List<sObjectField>{
                                    animalos__Vet_Consult__c.OwnerId
                            }
                    );

            if ((isCreated || isUpdated) && vetConsult.animalos__Animal__c != null && String.isNotBlank(vetConsult.animalos__Consult_Type__c) && vetConsult.animalos__Consult_Type__c.containsIgnoreCase('Intake')) {
                vetConsults.add(vetConsult);
            }
        }

        if (!vetConsults.isEmpty()) {
            Set<Id> userIds = aos_Utils.sObjects.getIdFieldValues(vetConsults, animalos__Vet_Consult__c.OwnerId);

            Map<Id, User> usersByIds = new Map<Id, User>([
                    SELECT Id, Profile.Name
                    FROM User
                    WHERE Id IN :userIds
            ]);

            List<animalos__Animal__c> animalsToUpdate = new List<animalos__Animal__c>();
            Set<Id> animalIds = new Set<Id>();


            for (animalos__Vet_Consult__c vetConsult : vetConsults) {
                User userVar = usersByIds.get(vetConsult.OwnerId);

                if (userVar == null) {
                    continue;
                }

                if (userVar.Profile.Name.containsIgnoreCase('Clinic') && !animalIds.contains(vetConsult.animalos__Animal__c)) {
                    animalsToUpdate.add(new animalos__Animal__c(
                            Id = vetConsult.animalos__Animal__c,
                            aos_Attending_Vet__c = vetConsult.OwnerId
                    ));
                    animalIds.add(vetConsult.animalos__Animal__c);
                }
            }

            update animalsToUpdate;
        }
    }
}