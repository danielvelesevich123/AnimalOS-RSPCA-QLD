trigger animalos_AlertTrigger on animalos__Alert__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(animalos_AlertDomain.class);
}