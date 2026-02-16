global class TDTM_aos_AssessmentAssignRecentBehaviour extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert {

    public void onAfterInsert(List<SObject> records) {
        assignMostRecentBehaviourObservation(records);
    }

    private void assignMostRecentBehaviourObservation(List<SObject> records) {
        Set<Id> animalIds = aos_Utils.sObjects.getIdFieldValues(
            records,
            animalos__Assessment__c.animalos__Animal__c
        );

        Map<Id, SObject> animalsByIds = new Map<Id, SObject>([
            SELECT Id, aos_Most_Recent_Behaviour_Observation__c, aos_Most_Recent_Behaviour_Observation__r.animalos__Assessment_Date_Time__c
            FROM animalos__Animal__c
            WHERE Id IN :animalIds
        ]);

        Id behaviourObservationCanineRecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(
            animalos__Assessment__c.SObjectType,
            'Behaviour_Observation_Canine'
        );
        Id behaviourObservationFelineRecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(
            animalos__Assessment__c.SObjectType,
            'Behaviour_Observation_Feline'
        );

        for (animalos__Assessment__c assessment : (List<animalos__Assessment__c>) records) {
            if (behaviourObservationCanineRecordTypeId.equals(assessment.RecordTypeId) || behaviourObservationFelineRecordTypeId.equals(assessment.RecordTypeId)) {
                animalos__Animal__c animal = (animalos__Animal__c) animalsByIds.get(assessment.animalos__Animal__c);

                if (animal != null) {
                    animal.aos_Most_Recent_Behaviour_Observation__c = animal.aos_Most_Recent_Behaviour_Observation__c == null ?
                        assessment.Id :
                        animal.aos_Most_Recent_Behaviour_Observation__r.animalos__Assessment_Date_Time__c > assessment.animalos__Assessment_Date_Time__c ?
                            animal.aos_Most_Recent_Behaviour_Observation__c :
                            assessment.Id;

                    animalsByIds.put(animal.Id, animal);
                }
            }
        }

        update animalsByIds.values();
    }
}