public with sharing class aos_GenerateAnimalReportSummaryProc extends aos_AbstractProcessor {

    private Map<String, List<SObject>> animalReportByRecordTypeName;

    public aos_GenerateAnimalReportSummaryProc(List<animalos__Animal_Report__c> animalReports) {
        this.animalReportByRecordTypeName = aos_Utils.sObjects.getSObjectsListByAnyFieldMap(
                animalReports,
                animalos__Animal_Report__c.RecordTypeId
        );
    }

    public aos_GenerateAnimalReportSummaryProc() {
    }

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.generateSummary();

        return this.response;
    }

    private void generateSummary() {
        String animalReportSummary = '<p>';

        if (this.animalReportByRecordTypeName == null) {
            List<animalos__Animal_Report__c> animalReports = this.request.getMapper().mapToListSObjects('animalReports', animalos__Animal_Report__c.SObjectType);
            if (animalReports == null) {
                this.response.put('animalReportSummary', animalReportSummary);
                return;
            } else {
                this.animalReportByRecordTypeName = aos_Utils.sObjects.getSObjectsListByAnyFieldMap(
                        animalReports,
                        animalos__Animal_Report__c.RecordTypeId
                );
            }
        }

        Map<String, SObjectField> sObjectFieldByAPIName = animalos__Animal_Report__c.SObjectType.getDescribe().fields.getMap();

        animalos__Setting__c setting = (animalos__Setting__c) aos_Utils.arrays.firstOrException([
                SELECT Id, animalos__Setting__c
                FROM animalos__Setting__c
                WHERE RecordType.DeveloperName = 'Inspectorate_Application'
        ]);

        if (String.isBlank(setting.animalos__Setting__c) || !setting.animalos__Setting__c.containsIgnoreCase('animalReportSetting')) {
            return;
        }

        aos_DTO settingDTO = new aos_DTO(setting.animalos__Setting__c);

        Map<String, Object> animalReportSetting = (Map<String, Object>) settingDTO.get('unmanaged.animalReportSetting');

        if (animalReportSetting == null) {
            return;
        }

        for (String recordTypeId : this.animalReportByRecordTypeName.keySet()) {
            List<animalos__Animal_Report__c> animalReportsVar = this.animalReportByRecordTypeName.get(recordTypeId);
            if (animalReportsVar == null) {
                continue;
            }
            String recordTypeName = aos_Utils.sObjects.recordTypeNameById(animalos__Animal_Report__c.SObjectType, recordTypeId);
            String recordTypeDeveloperName = aos_Utils.sObjects.recordTypeAPINameById(animalos__Animal_Report__c.SObjectType, recordTypeId);

            List<Object> recordTypeFields = (List<Object>) animalReportSetting.get(recordTypeDeveloperName);
            animalReportSummary += '<p><b>' + recordTypeName + '</b></p>' ;

            if (recordTypeFields != null) {
                for (animalos__Animal_Report__c reportVar : animalReportsVar) {
                    for (Object fieldObject : recordTypeFields) {
                        String field = String.valueOf(fieldObject);
                        if (reportVar.get(field) != null) {
                            SObjectField sObjectFieldVar = sObjectFieldByAPIName.get(field.toLowerCase());

                            if (sObjectFieldVar != null) {
                                animalReportSummary += '<p>' + sObjectFieldVar.getDescribe().getLabel() + ' : ' + reportVar.get(field);
                                animalReportSummary += '</p>';
                            }

                        }
                    }
                    animalReportSummary += '<p><br></p>';
                }
            }
        }
        animalReportSummary += '</p>';
        this.response.put('animalReportSummary', animalReportSummary);
    }
}