global class TDTM_aos_AnimalReportSetSendEmail extends animalos.TDTM.Handler implements animalos.TDTM.BeforeUpdate {
    public static Map<String, Boolean> SEND_EMAIL_BY_ANIMAL_REPORT_ID = new Map<String, Boolean>();

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.setSendEmailByAnimalReportId(records);
    }

    private void setSendEmailByAnimalReportId(List<SObject> records) {
        for (animalos__Animal_Report__c animalReportVar : (List<animalos__Animal_Report__c>) records) {
            SEND_EMAIL_BY_ANIMAL_REPORT_ID.put(animalReportVar.Id, animalReportVar.aos_Notify_Inspector__c);
            animalReportVar.aos_Notify_Inspector__c = false;
        }
    }
}