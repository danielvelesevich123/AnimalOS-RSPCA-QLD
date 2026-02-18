global class TDTM_aos_AssessmentUpdateAnimalFlag extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert, animalos.TDTM.AfterUpdate {

    public void onAfterInsert(List<SObject> records) {
        updateAnimalFlag(records);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        updateAnimalFlag(records);
    }

    private void updateAnimalFlag(List<SObject> records) {
        Set<Id> animalIds = aos_Utils.sObjects.getIdFieldValues(
            records,
            animalos__Assessment__c.animalos__Animal__c
        );

        Map<String, Object> animalsByIds = aos_Utils.sObjects.getSObjectsByAnyFieldMap([
            SELECT Id, animalos__Type__c, animalos__Behaviour_Flag__c, animalos__Behaviour_Flag_Condition__c
            FROM animalos__Animal__c
            WHERE Id IN :animalIds
        ], animalos__Animal__c.Id);

        Map<String, Object> lastBehaviourObservationByAnimal = new Map<String, Object>();
        Map<String, Object> lastFelineBehaviourObservationByAnimal = new Map<String, Object>();
        Map<String, Object> lastBehaviourAssessmentByAnimal = new Map<String, Object>();

        for (animalos__Assessment__c assessment : [
            SELECT Id, aos_Flags__c, animalos__Animal__c, RecordType.DeveloperName
            FROM animalos__Assessment__c
            WHERE animalos__Animal__c IN :animalIds AND animalos__Assessment_Date_Time__c != NULL AND
            RecordType.DeveloperName IN ('aos_Behaviour_Observation_Canine', 'aos_Behaviour_Observation_Feline', 'aos_Behaviour_Evaluation_Canine', 'aos_Behaviour_Evaluation_Feline')
            ORDER BY animalos__Assessment_Date_Time__c ASC
        ]) {
            switch on assessment.RecordType.DeveloperName {
                when 'aos_Behaviour_Observation_Canine' {
                    lastBehaviourObservationByAnimal.put(assessment.animalos__Animal__c, assessment);
                }
                when 'aos_Behaviour_Observation_Feline' {
                    lastFelineBehaviourObservationByAnimal.put(assessment.animalos__Animal__c, assessment);
                }
                when 'aos_Behaviour_Evaluation_Canine', 'aos_Behaviour_Evaluation_Feline' {
                    lastBehaviourAssessmentByAnimal.put(assessment.animalos__Animal__c, assessment);
                }
            }
        }

        for (animalos__Animal__c animal : (List<animalos__Animal__c>) animalsByIds.values()) {
            animalos__Assessment__c behaviourObservation;
            animalos__Assessment__c behaviourAssessment = (animalos__Assessment__c) lastBehaviourAssessmentByAnimal.get(animal.Id);

            if ('Cat'.equals(animal.animalos__Type__c)) {
                behaviourObservation = (animalos__Assessment__c) lastFelineBehaviourObservationByAnimal.get(animal.Id);
            } else {
                behaviourObservation = (animalos__Assessment__c) lastBehaviourObservationByAnimal.get(animal.Id);
            }

            String behaviourObservationFlag = aos_AssessmentService.defineBehaviourFlag(behaviourObservation);
            String behaviourAssessmentFlag = aos_AssessmentService.defineBehaviourFlag(behaviourAssessment);

            if ('RED'.equals(behaviourAssessmentFlag) || 'RED'.equals(behaviourObservationFlag)) {
                animal.animalos__Behaviour_Flag_Condition__c = 'RED';
            } else if ('YELLOW'.equals(behaviourAssessmentFlag) || 'YELLOW'.equals(behaviourObservationFlag)) {
                animal.animalos__Behaviour_Flag_Condition__c = 'YELLOW';
            } else {
                animal.animalos__Behaviour_Flag_Condition__c = 'GREEN';
            }

            animalsByIds.put(animal.Id, animal);
        }

        update (List<SObject>) animalsByIds.values();
    }
}