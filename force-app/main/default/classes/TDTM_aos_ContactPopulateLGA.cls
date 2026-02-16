global class TDTM_aos_ContactPopulateLGA extends animalos.TDTM.Handler implements animalos.TDTM.BeforeInsert, animalos.TDTM.BeforeUpdate {
    public void onBeforeInsert(List<SObject> records) {
        this.populateLGA((List<Contact>) records, new Map<Id, Contact>());
    }

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> existingRecords) {
        this.populateLGA((List<Contact>) records, (Map<Id, Contact>) existingRecords);
    }

    private void populateLGA(List<Contact> contacts, Map<Id, Contact> existingContacts) {
        Set<String> cityValues = vertic_Utils.sObjects.getStringFieldValues(contacts, 'MailingCity');
        Set<String> postcodeValues = vertic_Utils.sObjects.getStringFieldValues(contacts, 'MailingPostalCode');

        List<aos_Postcode__c> postcodes = [
                SELECT Id, aos_LGA__c, aos_Postcode__c, aos_Suburb__c
                FROM aos_Postcode__c
                WHERE aos_Suburb__c IN :cityValues
                AND aos_Postcode__c IN :postcodeValues
                AND aos_LGA__c != NULL
                AND aos_Suburb__c != NULL
                AND aos_Postcode__c != NULL
                AND aos_LGA__r.aos_Old__c = FALSE
        ];

        for (Contact contact : contacts) {
            Boolean isInsert = Trigger.isInsert;
            Boolean isUpdate = Trigger.isUpdate &&
                    !existingContacts.isEmpty() &&
                    existingContacts.containsKey(contact.Id) &&
                    vertic_Utils.sObjects.isSomeFieldChanged(contact, existingContacts.get(contact.Id), new List<String>{
                            'MailingCity', 'MailingPostalCode'
                    });

            if (isInsert || isUpdate) {
                for (aos_Postcode__c postcode : postcodes) {
                    if (contact.MailingCity == postcode.aos_Suburb__c && contact.MailingPostalCode == postcode.aos_Postcode__c) {
                        contact.LGA__c = postcode.aos_LGA__c;
                    }
                }
            }
        }
    }
}
