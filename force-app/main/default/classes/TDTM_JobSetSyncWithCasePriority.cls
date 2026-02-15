global class TDTM_JobSetSyncWithCasePriority extends animalos.TDTM.Handler implements animalos.TDTM.BeforeUpdate {
    public static Boolean triggeredFromRecordPage = true;
    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        if (records.size() == 1 && triggeredFromRecordPage) {
            this.setSyncWithCasePriority(records, oldMap);
        }
    }

    private void setSyncWithCasePriority(List<SObject> records, Map<Id, SObject> existingRecords) {
        for (animalos__Job__c jobVar : (List<animalos__Job__c>) records) {
            Boolean isUpdatedFromUi = Url.getCurrentRequestUrl()?.toExternalForm()?.contains('RecordUi.updateRecord=1');
            Boolean isUpdated = vertic_Utils.sObjects.isSomeFieldChanged(
                    jobVar,
                    existingRecords.get(jobVar.Id),
                    new List<SObjectField>{
                            animalos__Job__c.animalos__Priority__c
                    }
            );

            if (isUpdated && isUpdatedFromUi && String.isNotBlank(jobVar.animalos__Priority__c)) {
                jobVar.aos_Sync_with_Case_Priority__c = false;
            }
        }
    }
}