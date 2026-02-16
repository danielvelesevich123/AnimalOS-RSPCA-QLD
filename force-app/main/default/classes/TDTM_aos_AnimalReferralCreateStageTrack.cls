global inherited sharing class TDTM_aos_AnimalReferralCreateStageTrack extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert {

    public void onAfterInsert(List<SObject> records) {
        this.updateParentStageTrackingRecord(records);
    }

    private void updateParentStageTrackingRecord(List<SObject> records) {
        Set<Id> referralIds = vertic_Utils.sObjects.getIdFieldValues(records, animalos__Animal_Referral__c.animalos__Referral__c);

        List<aos_Referral_Stage_Tracking__c> lastReferralStageTrackingRecords = [
                SELECT Id
                FROM aos_Referral_Stage_Tracking__c
                WHERE aos_Referral__c IN :referralIds
                AND aos_Parent_Referral_Stage_Tracking__c = NULL
                AND aos_End_Date_Time__c = NULL
        ];

        if (!lastReferralStageTrackingRecords.isEmpty()) {
            //it will trigger TDTM_aos_ReferralStageTrackingChilds and create child records
            update lastReferralStageTrackingRecords;
        }
    }
}