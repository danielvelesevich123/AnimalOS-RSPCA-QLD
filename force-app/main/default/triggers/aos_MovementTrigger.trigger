trigger aos_MovementTrigger on animalos__Movement__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    animalos.TDTM.handle();
}