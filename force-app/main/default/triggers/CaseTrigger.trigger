trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//    fflib_SObjectDomain.triggerHandler(CaseDomain.class);
//    fflib_SObjectDomain.triggerHandler(AOSCaseDomain.class);
    animalos.TDTM.handle();
}