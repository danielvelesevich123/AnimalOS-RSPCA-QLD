global class TDTM_aos_JobContactSetJobPOI extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert, animalos.TDTM.AfterUpdate {

    public void onAfterInsert(List<SObject> records) {
        this.TDTM_JobContactSetJobPOI(records);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> existingRecords) {
        this.TDTM_JobContactSetJobPOI(records);
    }

    private void TDTM_JobContactSetJobPOI(List<sObject> records) {
        Map<Id, animalos__Job__c> jobsByIds = new Map<Id, animalos__Job__c>();

        for (animalos__Job_Contact__c jobContact : (List<animalos__Job_Contact__c>) records) {

            if ('Person Of Interest'.equalsIgnoreCase(jobContact.animalos__Contact_Type__c)) {
                jobsByIds.put(jobContact.animalos__Job__c, new animalos__Job__c(
                        Id = jobContact.animalos__Job__c,
                        aos_Person_of_Interest__c = jobContact.animalos__Contact__c
                ));
            }
        }

        if (!jobsByIds.isEmpty()) {
            animalos.TDTM.getTriggerSObjectTypeEvent(animalos__Job__c.SObjectType).disableAll();
            update jobsByIds.values();
            animalos.TDTM.getTriggerSObjectTypeEvent(animalos__Job__c.SObjectType).enableAll();
        }
    }
}