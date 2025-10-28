trigger ContactTrigger on Contact (after insert, after update) {
    fflib_SObjectDomain.triggerHandler(ContactMergeHistoryDomain.class);
}