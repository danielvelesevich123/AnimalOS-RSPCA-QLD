global class TDTM_aos_ReferralSetSecureContact extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert, animalos.TDTM.AfterUpdate {
    global void onAfterInsert(List<SObject> records) {
        this.setSecureContact(records);
    }

    global void onAfterUpdate(List<SObject> records, Map<Id, SObject> existingRecords) {
        this.setSecureContact(records);
    }

    private void setSecureContact(List<SObject> records) {
        Set<Id> contactIds = aos_Utils.sObjects.getIdFieldValues(records, animalos__Referral__c.aos_Programs_Contact__c);
        List<Contact> contacts = new List<Contact>();

        for (Id contactId : contactIds) {
            contacts.add(new Contact(Id = contactId, aos_Program_Contact__c = true));
        }

        animalos.TDTM.getTriggerSObjectTypeEvent(Contact.SObjectType).disableAll();
        update contacts;
    }
}