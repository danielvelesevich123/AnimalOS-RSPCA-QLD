trigger aos_UserTrigger on User (after insert, after update) {
    animalos.TDTM.handle();
}