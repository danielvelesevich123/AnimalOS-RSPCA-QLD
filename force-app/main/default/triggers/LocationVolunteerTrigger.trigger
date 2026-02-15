trigger LocationVolunteerTrigger on aos_Location_Volunteer__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    animalos.TDTM.handle();
}