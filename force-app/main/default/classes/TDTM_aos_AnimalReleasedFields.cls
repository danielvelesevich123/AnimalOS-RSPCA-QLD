global class TDTM_aos_AnimalReleasedFields extends animalos.TDTM.Handler implements animalos.TDTM.BeforeUpdate {

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        handleAnimalReleasedFieldsChange(records, oldMap);
    }

    private void handleAnimalReleasedFieldsChange(List<SObject> records, Map<Id, SObject> existingRecords) {
        for (animalos__Animal__c animal : (List<animalos__Animal__c>) records) {
            animalos__Animal__c existingAnimal = (animalos__Animal__c) existingRecords.get(animal.Id);
            if (animal.aos_Animal_Released__c && aos_Utils.sObjects.isSomeFieldChanged(
                animal, existingAnimal, new List<SObjectField>{
                    animalos__Animal__c.aos_Animal_Released__c
                }
            )) {
                animal.aos_Animal_Released_By__c = UserInfo.getUserId();
            }
            if (animal.aos_Animal_is_Ready_for_Release__c && aos_Utils.sObjects.isSomeFieldChanged(
                animal, existingAnimal, new List<SObjectField>{
                    animalos__Animal__c.aos_Animal_is_Ready_for_Release__c
                }
            )) {
                animal.aos_Declared_Ready_For_Release__c = UserInfo.getUserId();
            }
        }
    }
}