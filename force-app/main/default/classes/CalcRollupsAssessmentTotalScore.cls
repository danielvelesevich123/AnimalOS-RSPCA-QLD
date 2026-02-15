global class CalcRollupsAssessmentTotalScore extends animalos.vertic_SequentialScheduledBatch {
    global override Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id, animalos__Total_Score__c
                FROM animalos__Assessment__c
                WHERE Id IN (
                    SELECT aos_Assessment__c
                    FROM aos_Assessment_Score__c
                    WHERE LastModifiedDate >= :this.sequentialBatchSetting.animalos__Last_Calculation_Datetime__c
                )
        ]);
    }

    global override void process(List<SObject> records) {

        Map<String, Object> assessmentScoresByAssessmentId = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, aos_Score__c, aos_Assessment__c
                FROM aos_Assessment_Score__c
                WHERE aos_Assessment__c IN :records
        ], aos_Assessment_Score__c.aos_Assessment__c);

        List<animalos__Assessment__c> assessmentsForUpdate = new List<animalos__Assessment__c>();

        for (animalos__Assessment__c assessment : (List<animalos__Assessment__c>) records) {

            List<aos_Assessment_Score__c> assessmentScores = (List<aos_Assessment_Score__c>) assessmentScoresByAssessmentId.get(assessment.Id);

            Decimal totalScore = 0;
            if (assessmentScores != null) {
                for (aos_Assessment_Score__c assessmentScore : assessmentScores) {
                    totalScore += assessmentScore.aos_Score__c;
                }
            }
            assessment.animalos__Total_Score__c = totalScore;

            assessmentsForUpdate.add(assessment);
        }

        if (assessmentsForUpdate.size() > 0) {
            fflib_SObjectDomain.getTriggerEvent(animalos_AssessmentDomain.class).disableAll();
            update assessmentsForUpdate;
            fflib_SObjectDomain.getTriggerEvent(animalos_AssessmentDomain.class).enableAll();
        }
    }
}