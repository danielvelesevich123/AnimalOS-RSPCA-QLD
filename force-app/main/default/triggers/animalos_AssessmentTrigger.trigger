trigger animalos_AssessmentTrigger on animalos__Assessment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(animalos_AssessmentDomain.class);
}