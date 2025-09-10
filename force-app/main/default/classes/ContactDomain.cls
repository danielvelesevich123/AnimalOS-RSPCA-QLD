public without sharing class ContactDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {

    public ContactDomain(List<Contact> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new ContactDomain(sObjectList);
        }
    }

    public override void onBeforeInsert() {
        this.formatContacts(this.Records);
        this.populateLGA(this.Records, new Map<Id, Contact>());
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        this.formatContacts(this.Records);
        this.populateLGA(this.Records, (Map<Id, Contact>) existingRecords);
    }

    public override void onAfterDelete() {
        List<String> oneDriveFolders = new List<String>();
        String newOneDriveFolderName;

        for (Contact contact : (List<Contact>) Trigger.old) {
            if (contact.MasterRecordId != null) {
                oneDriveFolders.add(contact.One_Drive_Folder_Name__c);

                if (newOneDriveFolderName == null) {
                    newOneDriveFolderName = ((Contact) vertic_Utils.arrays.firstOrNull(
                    [
                            SELECT One_Drive_Folder_Name__c
                            FROM Contact
                            WHERE Id = :contact.MasterRecordId
                    ])
                    )?.One_Drive_Folder_Name__c;
                }
            }
        }

        if (oneDriveFolders.size() > 0) {
            List<Vertic_Async_Process__c> asyncProcesses = new List<Vertic_Async_Process__c>();

            for (String oneDriveFolder : oneDriveFolders) {
                asyncProcesses.add(OneDriveMigrateFoldersProc.enqueueVAP(oneDriveFolder, newOneDriveFolderName, 'Contact'));
            }

            insert asyncProcesses;
        }
    }


    public void formatContacts(List<Contact> contacts) {
        FormatService.format(contacts);
    }

    private void populateLGA(List<Contact> contacts, Map<Id, Contact> existingContacts) {
        Set<String> cityValues = vertic_Utils.sObjects.getStringFieldValues(contacts, 'MailingCity');
        Set<String> postcodeValues = vertic_Utils.sObjects.getStringFieldValues(contacts, 'MailingPostalCode');

        List<Postcode__c> postcodes = [
                SELECT Id, LGA__c, Postcode__c, Suburb__c
                FROM Postcode__c
                WHERE Suburb__c IN :cityValues
                AND Postcode__c IN :postcodeValues
                AND LGA__c != NULL
                AND Suburb__c != NULL
                AND Postcode__c != NULL
                AND LGA__r.Old__c = FALSE
        ];

        for (Contact contact : contacts) {
            Boolean isInsert = Trigger.isInsert;
            Boolean isUpdate = Trigger.isUpdate &&
                    !existingContacts.isEmpty() &&
                    existingContacts.containsKey(contact.Id) &&
                    vertic_Utils.sObjects.isSomeFieldChanged(contact, existingContacts.get(contact.Id), new List<String>{
                            'MailingCity', 'MailingPostalCode'
                    });

            if(isInsert || isUpdate) {
                for (Postcode__c postcode : postcodes) {
                    if (contact.MailingCity == postcode.Suburb__c && contact.MailingPostalCode == postcode.Postcode__c) {
                        contact.LGA__c = postcode.LGA__c;
                    }
                }
            }
        }
    }


}