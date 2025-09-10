trigger animalos_AnimalTrigger on animalos__Animal__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(animalos_AnimalDomain.class);
}