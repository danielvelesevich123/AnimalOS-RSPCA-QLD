global class TDTM_aos_AnimalValidateProtectiveCustody extends animalos.TDTM.Handler implements animalos.TDTM.BeforeUpdate {

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        validateProtectiveCustodyStatus(records, oldMap);
    }

    private void validateProtectiveCustodyStatus(List<SObject> records, Map<Id, SObject> existingRecords) {
        for (animalos__Animal__c animal : (List<animalos__Animal__c>) records) {
            animalos__Animal__c existingAnimal = (animalos__Animal__c) existingRecords?.get(animal.Id);

            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingAnimal != null
                && vertic_Utils.sObjects.isSomeFieldChanged(
                animal,
                existingAnimal,
                new List<SObjectField>{
                    animalos__Animal__c.animalos__Status__c
                });
            Boolean existingStatusContainsProtectiveCustody = String.isNotBlank(existingAnimal?.animalos__Status__c) && existingAnimal?.animalos__Status__c?.containsIgnoreCase('Protective Custody');
            Boolean newStatusContainsProtectiveCustody = String.isNotBlank(animal.animalos__Status__c) && animal.animalos__Status__c?.containsIgnoreCase('Protective Custody');

            if (isUpdated && existingStatusContainsProtectiveCustody && !newStatusContainsProtectiveCustody && animal.aos_Animal_Released_By__c == null) {
                animal.addError('Animal status can\'t be changed to ' + animal.animalos__Status__c + ' because Animal Released By field is empty');
            }
        }
    }
}
