trigger ReferralStageTrackingTrigger on Referral_Stage_Tracking__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    animalos.TDTM.handle();
}