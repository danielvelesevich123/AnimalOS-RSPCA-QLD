trigger aos_AssessmentTrigger on animalos__Assessment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    animalos.TDTM.handle();
}