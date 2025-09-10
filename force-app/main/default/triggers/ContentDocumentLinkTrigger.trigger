trigger ContentDocumentLinkTrigger on ContentDocumentLink(before insert) {
    ContentDocumentLinkHandler.updateContentDocumentVisibility(Trigger.new);
}