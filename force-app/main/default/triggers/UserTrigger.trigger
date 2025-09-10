trigger UserTrigger on User (after insert, after update) {
    System.debug('UserTrigger: Triggered after insert');
    animalos.TDTM.handle();
}