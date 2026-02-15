trigger UserTrigger on User (after insert, after update) {
    animalos.TDTM.handle();
}