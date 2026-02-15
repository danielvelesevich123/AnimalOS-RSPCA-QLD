global class TDTM_AnimalReferralSetAnimalType extends animalos.TDTM.Handler implements animalos.TDTM.BeforeInsert {

    public void onBeforeInsert(List<SObject> records) {
        this.setAnimalType(records);
    }

    public void setAnimalType(List<SObject> records) {
        Set<Id> animalIds = vertic_Utils.sObjects.getIdFieldValues(records, animalos__Animal_Referral__c.animalos__Animal__c);

        Map<Id, animalos__Animal__c> animalsByIds = new Map<Id, animalos__Animal__c>([
                SELECT Id, animalos__Type__c
                FROM animalos__Animal__c
                WHERE Id IN :animalIds
        ]);

        for (animalos__Animal_Referral__c animalReferral : (List<animalos__Animal_Referral__c>) records) {
            animalos__Animal__c animal = animalsByIds.get(animalReferral.animalos__Animal__c);
            animalReferral.aos_Type__c = animal.animalos__Type__c;
        }
    }
}