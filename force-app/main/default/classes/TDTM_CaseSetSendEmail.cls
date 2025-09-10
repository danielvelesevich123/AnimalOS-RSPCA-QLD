global class TDTM_CaseSetSendEmail extends animalos.TDTM.Handler implements animalos.TDTM.BeforeUpdate, animalos.TDTM.BeforeInsert {
    public static Map<String, Boolean> SEND_EMAIL_BY_CASE_ID = new Map<String, Boolean>();

    public void onBeforeInsert(List<SObject> records) {
        this.setSendEmailByCaseId(records);
    }

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.setSendEmailByCaseId(records);
    }

    private void setSendEmailByCaseId(List<SObject> records) {
        for (Case caseVar : (List<Case>) records) {
            SEND_EMAIL_BY_CASE_ID.put(caseVar.Id, SEND_EMAIL_BY_CASE_ID.get(caseVar.Id) == true || caseVar.Notify_Inspector__c == true);
            caseVar.Notify_Inspector__c = false;
        }
    }
}