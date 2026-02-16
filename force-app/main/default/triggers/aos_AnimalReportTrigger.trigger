trigger aos_AnimalReportTrigger on animalos__Animal_Report__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
        animalos.TDTM.handle();
}