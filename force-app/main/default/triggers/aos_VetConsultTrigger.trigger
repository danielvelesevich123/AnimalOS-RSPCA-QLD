trigger aos_VetConsultTrigger on animalos__Vet_Consult__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    animalos.TDTM.handle();
}