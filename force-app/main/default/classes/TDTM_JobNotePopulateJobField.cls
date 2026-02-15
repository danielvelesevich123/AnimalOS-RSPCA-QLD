global class TDTM_JobNotePopulateJobField extends animalos.TDTM.Handler implements animalos.TDTM.BeforeInsert {
    public void onBeforeInsert(List<SObject> records) {
        this.populateJobField(records);
    }

    private void populateJobField(List<sObject> records) {

        Set<Id> caseIds = vertic_Utils.sObjects.getIdFieldValues(records, animalos__Job_Note__c.aos_Case__c);

        Map<String, sObject> jobsByCaseId = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, aos_Case__c, OwnerId, Name
                FROM animalos__Job__c
                WHERE aos_Case__c IN :caseIds
                ORDER BY CreatedDate ASC
        ], animalos__Job__c.aos_Case__c);

        for (animalos__Job_Note__c clientNote : (List<animalos__Job_Note__c>) records) {
            if (clientNote.aos_Case__c != null && clientNote.animalos__Job__c == null) {
                animalos__Job__c job = (animalos__Job__c) jobsByCaseId.get(clientNote.aos_Case__c);

                if (job != null) {
                    clientNote.animalos__Job__c = job.Id;
                }
            }
        }

    }
}