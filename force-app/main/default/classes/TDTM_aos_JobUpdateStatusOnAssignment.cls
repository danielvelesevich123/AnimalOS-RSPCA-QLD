global class TDTM_aos_JobUpdateStatusOnAssignment extends animalos.TDTM.Handler implements animalos.TDTM.BeforeUpdate {
    global void onBeforeUpdate(List<SObject> records, Map<Id, SObject> existingRecords) {
        this.updateJobStatus(records, existingRecords);
    }

    private void updateJobStatus(List<SObject> records, Map<Id, SObject> existingRecords) {

        for (animalos__Job__c job : (List<animalos__Job__c>) records) {
            animalos__Job__c existingJob = (animalos__Job__c) existingRecords?.get(job.Id);

            Boolean isPreviousOwnerAGroup = existingJob?.OwnerId?.getSobjectType() == Group.SObjectType;
            Boolean isOwnerAUser = job.OwnerId.getSobjectType() == User.SObjectType;

            if (isPreviousOwnerAGroup && isOwnerAUser && 'New'.equals(job.animalos__Status__c)) {
                job.animalos__Status__c = 'Assigned';
            }
        }
    }
}