global without sharing class TDTM_aos_AssessmentCalculateScore extends animalos.TDTM.Handler implements animalos.TDTM.BeforeInsert, animalos.TDTM.BeforeUpdate, animalos.TDTM.AfterInsert {

    private Map<String, Object> assessmentMatrixSettingByName = new Map<String, Object>();
    private vertic_UnitOfWork uow = new vertic_UnitOfWork(new List<SObjectType>{
        animalos__Assessment__c.SObjectType,
        aos_Assessment_Score__c.SObjectType,
        animalos__Animal_Action__c.SObjectType
    });

    public void onBeforeInsert(List<SObject> records) {
        calculateAssessmentScore(records, null);
    }

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        calculateAssessmentScore(records, oldMap);
        uow.commitWork();
    }

    public void onAfterInsert(List<SObject> records) {
        calculateAssessmentScore(records, null);
        uow.commitWork();
    }

    private void calculateAssessmentScore(List<SObject> records, Map<Id, SObject> existingRecords) {
        assessmentMatrixSettingByName = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
            SELECT Id, animalos__Setting__c, Name
            FROM animalos__Setting__c
            WHERE RecordType.DeveloperName = 'Assessment_Score'
        ], animalos__Setting__c.Name);

        Map<String, Object> assessmentScoresByAssessmentId = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
            SELECT Id, aos_Assessment__c, aos_Score_Category__c
            FROM aos_Assessment_Score__c
            WHERE aos_Assessment__c IN :records
        ], aos_Assessment_Score__c.aos_Assessment__c);

        Map<String, SObjectField> sObjectFieldMap = animalos__Assessment__c.SObjectType.getDescribe().fields.getMap();

        for (animalos__Assessment__c assessment : (List<animalos__Assessment__c>) records) {
            Map<String, Object> picklistValueScoreMatrix = getPicklistValueScoreMatrix(vertic_Utils.sObjects.recordTypeNameById(animalos__Assessment__c.SObjectType, assessment.RecordTypeId));

            if (assessment.RecordTypeId == null || picklistValueScoreMatrix == null) {
                continue;
            }

            animalos__Assessment__c existingAssessment = (animalos__Assessment__c) existingRecords?.get(assessment.Id);

            Boolean isCreated = Trigger.isInsert && existingRecords == null;
            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingAssessment != null
                && vertic_Utils.sObjects.isSomeFieldChanged(assessment, existingAssessment, new List<String>(picklistValueScoreMatrix.keySet()));

            if (isCreated || isUpdated) {
                if (Trigger.isAfter) {
                    assessment = assessment.clone(true, true);
                }

                List<aos_Assessment_Score__c> assessmentScores = (List<aos_Assessment_Score__c>) assessmentScoresByAssessmentId.get(assessment.Id);
                Map<String, aos_Assessment_Score__c> assessmentScoreByAssessmentIdAndScoreCategory = new Map<String, aos_Assessment_Score__c>();

                if (assessmentScores != null) {
                    for (aos_Assessment_Score__c assessmentScore : assessmentScores) {
                        assessmentScoreByAssessmentIdAndScoreCategory.put(assessmentScore.aos_Assessment__c + '' + assessmentScore.aos_Score_Category__c, assessmentScore);
                    }
                }

                assessment.aos_Flags__c = '';

                Decimal totalScore = 0;

                for (String assessmentField : picklistValueScoreMatrix.keySet()) {
                    Map<String, Object> fieldScoreMap = (Map<String, Object>) picklistValueScoreMatrix.get(assessmentField);

                    String scoreField = String.valueOf(fieldScoreMap.get('scoreField'));
                    Map<String, Object> valueScores = (Map<String, Object>) fieldScoreMap.get('scores');

                    if (String.isBlank(scoreField) || valueScores == null) {
                        continue;
                    }

                    String fieldValue = String.valueOf(assessment.get(assessmentField));
                    Integer score = 0;

                    Set<String> flags = new Set<String>();

                    if (String.isNotBlank(fieldValue)) {
                        for (String value : valueScores.keySet()) {
                            if (fieldValue.contains(value)) {
                                score += Integer.valueOf(valueScores.get(value));

                                if (aos_AssessmentService.RED_FLAG_PICKLIST_VALUES.contains(value) || aos_AssessmentService.ORANGE_FLAG_PICKLIST_VALUES.contains(value)) {
                                    flags.add(value);
                                }
                            }
                        }
                    }

                    if (!flags.isEmpty()) {
                        assessment.aos_Flags__c = assessment.aos_Flags__c + String.join(new List<String>(flags), ';') + ';';
                    }

                    assessment.put(scoreField, score);

                    DescribeFieldResult fieldDescribe = sObjectFieldMap.get(assessmentField).getDescribe();
                    String categoryName = fieldDescribe.getLabel();

                    aos_Assessment_Score__c assessmentScore = assessmentScoreByAssessmentIdAndScoreCategory.get(assessment.Id + '' + categoryName) ?? new aos_Assessment_Score__c();
                    assessmentScore.aos_Score__c = score;
                    totalScore += score;

                    if (assessmentScore.Id == null) {
                        assessmentScore.Name = categoryName;
                        assessmentScore.aos_Score_Category__c = categoryName;
                    }
                    uow.registerUpsert(assessmentScore);
                    uow.registerRelationship(assessmentScore, aos_Assessment_Score__c.aos_Assessment__c, assessment);
                }

                assessment.animalos__Total_Score__c = totalScore;
            }
        }
    }

    private Map<String, Object> getPicklistValueScoreMatrix(String assessmentRecordTypeName) {
        animalos__Setting__c assessmentMatrix = (animalos__Setting__c) assessmentMatrixSettingByName.get(assessmentRecordTypeName);

        if (assessmentMatrix == null || String.isBlank(assessmentMatrix.animalos__Setting__c)) {
            return null;
        }

        return (Map<String, Object>) JSON.deserializeUntyped(assessmentMatrix.animalos__Setting__c);
    }
}
