global class TDTM_aos_AnimalReportGenAnimalSummary extends animalos.TDTM.Handler implements animalos.TDTM.AfterUpdate, animalos.TDTM.AfterInsert {
    public void onAfterInsert(List<SObject> records) {
        this.generateAnimalSummaryReport(records);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.generateAnimalSummaryReport(records);
    }


    private void generateAnimalSummaryReport(List<SObject> records) {
        Set<Id> caseIds = vertic_Utils.sObjects.getIdFieldValues(
                records,
                animalos__Animal_Report__c.aos_Case__c
        );

        if (!caseIds.isEmpty()) {
            List<Case> cases = [
                    SELECT Id
                    FROM Case
                    WHERE Id = :caseIds
            ];

            Set<String> fieldsInString = new Set<String>(animalos__Animal_Report__c.getSObjectType().getDescribe().getSObjectType().getDescribe().fields.getMap().keySet());
            fieldsInString.add('RecordType.Name');
            fieldsInString.add('RecordType.DeveloperName');

            fflib_QueryFactory factory = new fflib_QueryFactory(animalos__Animal_Report__c.SObjectType);
            factory.selectFields(fieldsInString);
            factory.setCondition('Case__c IN :caseIds');

            Map<String, Object> animalReportsByCaseId = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap(
                    Database.query(factory.toSOQL()),
                    animalos__Animal_Report__c.aos_Case__c
            );

            for (Case caseVar : cases) {
                List<animalos__Animal_Report__c> animalReports = (List<animalos__Animal_Report__c>) animalReportsByCaseId.get(caseVar.Id);
                vertic_Response generateAnimalReportSummaryResponse = new AOSGenerateAnimalReportSummaryProc(animalReports).process(
                        new Map<String, Object>()
                );

                caseVar.Animal_Report_Summary__c = generateAnimalReportSummaryResponse.getString('animalReportSummary');

            }

            update cases;
        }
    }
}