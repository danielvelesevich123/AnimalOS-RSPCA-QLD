global class TDTM_aos_AssessmentCheckDailyObs extends animalos.TDTM.Handler implements animalos.TDTM.BeforeInsert {

    public void onBeforeInsert(List<SObject> records) {
        checkAnimalDailyObservationsInProgress((List<animalos__Assessment__c>) records);
    }

    private void checkAnimalDailyObservationsInProgress(List<animalos__Assessment__c> records) {
        Set<Id> animalIds = aos_Utils.sObjects.getIdFieldValues(
            records,
            animalos__Assessment__c.animalos__Animal__c
        );

        Map<String, List<animalos__Assessment__c>> mapAssessmentsByAnimalIds = aos_Utils.sObjects.getSObjectsListByAnyFieldMap([
            SELECT Id, animalos__Animal__c, animalos__Status__c, RecordType.DeveloperName
            FROM animalos__Assessment__c
            WHERE animalos__Animal__c IN :animalIds AND Id NOT IN :records
        ], animalos__Assessment__c.animalos__Animal__c);

        Id behaviourObservationCanineRecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(
            animalos__Assessment__c.SObjectType,
            'aos_Behaviour_Observation_Canine'
        );

        for (animalos__Assessment__c assessment : records) {
            if ('In Progress'.equals(assessment.animalos__Status__c) &&
                (behaviourObservationCanineRecordTypeId.equals(assessment.RecordTypeId))) {

                if (mapAssessmentsByAnimalIds.get(assessment.animalos__Animal__c) != null) {
                    for (animalos__Assessment__c existingAssessment : mapAssessmentsByAnimalIds.get(assessment.animalos__Animal__c)) {
                        if ('In Progress'.equals(existingAssessment.animalos__Status__c) &&
                            (behaviourObservationCanineRecordTypeId.equals(existingAssessment.RecordTypeId))) {
                            assessment.addError('There is already an in progress assessment for this animal');
                        }
                    }
                }
            }
        }
    }
}