global class TDTM_aos_MovementAssignToIncomingAnimals extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert {

    public void onAfterInsert(List<SObject> records) {
        handleAssignToIncomingAnimals(records, null);
    }

    private void handleAssignToIncomingAnimals(List<SObject> records, Map<Id, SObject> existingRecords) {
        List<animalos__Movement__c> movementsWithCondition = new List<animalos__Movement__c>();

        Set<Id> locationIds = aos_Utils.sObjects.getIdFieldValues(records, animalos__Movement__c.animalos__Location__c);

        Map<String, animalos__Location__c> locationsById = new Map<String, animalos__Location__c>([
            SELECT Id, Name, aos_Sync_All_Animals__c
            FROM animalos__Location__c
            WHERE Id IN :locationIds
                AND RecordType.DeveloperName != 'Foster'
                AND RecordType.DeveloperName != 'Offsite'
        ]);

        for (animalos__Movement__c movementItem : (List<animalos__Movement__c>) records) {
            if (movementItem.animalos__Location__c != null && movementItem.animalos__Current__c == true) {
                animalos__Location__c locationVar = locationsById.get(movementItem.animalos__Location__c);

                if (locationVar != null && movementItem.animalos__Location__c == locationVar.Id) {
                    movementsWithCondition.add(movementItem);
                }
            }
        }

        if (movementsWithCondition.isEmpty()) return;

        Set<Id> animalsIds = aos_Utils.sObjects.getIdFieldValues(movementsWithCondition, animalos__Movement__c.animalos__Animal__c);

        List<SObject> animalsRecords = [
            SELECT Id, animalos__Stage__c, animalos__Type__c
            FROM animalos__Animal__c
            WHERE Id IN :animalsIds
                AND animalos__Stage__c != 'Pre-Intake'
                AND animalos__Stage__c != 'Out'
        ];

        if (animalsRecords.isEmpty()) return;

        aos_AssignToIncomingAnimalsService.handleAssignToIncomingAnimals(animalsRecords);
    }
}