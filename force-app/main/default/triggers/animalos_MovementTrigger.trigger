trigger animalos_MovementTrigger on animalos__Movement__c (after insert) {
    fflib_SObjectDomain.triggerHandler(animalos_MovementDomain.class);
}