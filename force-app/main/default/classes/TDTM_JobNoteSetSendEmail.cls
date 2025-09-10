global class TDTM_JobNoteSetSendEmail extends animalos.TDTM.Handler implements animalos.TDTM.BeforeUpdate {
    public static Map<String, Boolean> SEND_EMAIL_BY_JOB_NOTE_ID = new Map<String, Boolean>();

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.setSendEmailByJobNoteId(records);
    }

    private void setSendEmailByJobNoteId(List<SObject> records) {
        for (animalos__Job_Note__c jobNote : (List<animalos__Job_Note__c>) records) {
            SEND_EMAIL_BY_JOB_NOTE_ID.put(jobNote.Id, jobNote.Notify_Inspector__c);
            jobNote.Notify_Inspector__c = false;
        }
    }
}