trigger AOSJobActivityTrigger on animalos__Job_Activity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
        animalos.TDTM.handle();   
}