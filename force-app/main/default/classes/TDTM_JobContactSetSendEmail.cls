global class TDTM_JobContactSetSendEmail extends animalos.TDTM.Handler implements animalos.TDTM.BeforeUpdate {
    public static Map<String, Boolean> SEND_EMAIL_BY_JOB_CONTACT_ID = new Map<String, Boolean>();

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.setSendEmailByJobContactId(records);
    }

    private void setSendEmailByJobContactId(List<SObject> records) {
        for (animalos__Job_Contact__c jobContact : (List<animalos__Job_Contact__c>) records) {
            SEND_EMAIL_BY_JOB_CONTACT_ID.put(jobContact.Id, jobContact.aos_Notify_Inspector__c);
            jobContact.aos_Notify_Inspector__c = false;
        }
    }
}