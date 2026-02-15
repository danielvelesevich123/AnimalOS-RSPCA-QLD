global class TDTM_AnimalReportSetSendEmailCase extends animalos.TDTM.Handler implements animalos.TDTM.BeforeUpdate {
    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.setSendEmailByCaseId(records);
    }

    private void setSendEmailByCaseId(List<SObject> records) {
        for (animalos__Animal_Report__c animalReportVar : (List<animalos__Animal_Report__c>) records) {
            TDTM_CaseSetSendEmail.SEND_EMAIL_BY_CASE_ID.put(animalReportVar.aos_Case__c, TDTM_CaseSetSendEmail.SEND_EMAIL_BY_CASE_ID.get(animalReportVar.aos_Case__c) == true || animalReportVar.aos_Notify_Inspector__c == true);
            animalReportVar.aos_Notify_Inspector__c = false;
        }
    }
}