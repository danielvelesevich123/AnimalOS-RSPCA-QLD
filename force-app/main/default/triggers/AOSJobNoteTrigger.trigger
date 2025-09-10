trigger AOSJobNoteTrigger on animalos__Job_Note__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
        animalos.TDTM.handle();
}