global class TDTM_aos_AssessmentUpdateSite extends animalos.TDTM.Handler implements animalos.TDTM.BeforeInsert, animalos.TDTM.BeforeUpdate {

    public void onBeforeInsert(List<SObject> records) {
        updateAssessmentMonthsKnownAndSite(records);
    }

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        updateAssessmentMonthsKnownAndSite(records);
    }

    private void updateAssessmentMonthsKnownAndSite(List<SObject> records) {
        Set<Id> animalIds = vertic_Utils.sObjects.getIdFieldValues(
            records,
            animalos__Assessment__c.animalos__Animal__c
        );

        Map<Id, SObject> animalsById = new Map<Id, SObject>([
            SELECT Id, animalos__Current_Site__c
            FROM animalos__Animal__c
            WHERE Id IN :animalIds
        ]);

        for (animalos__Assessment__c assessment : (List<animalos__Assessment__c>) records) {
            animalos__Animal__c animal = (animalos__Animal__c) animalsById.get(assessment.animalos__Animal__c);

            assessment.aos_Site__c = animal?.animalos__Current_Site__c;
        }
    }
}
