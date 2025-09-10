trigger ContentVersionTrigger on ContentVersion(before insert, after insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ContentVersionHandler.updateContentVersionOrigin(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        ContentVersionHandler.updatePortalURL(Trigger.new);
    }
}