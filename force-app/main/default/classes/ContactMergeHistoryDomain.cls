public with sharing class ContactMergeHistoryDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain{
    private static Set<Id> processedContactIds = new Set<Id>();

    public ContactMergeHistoryDomain(List<Event> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new ContactMergeHistoryDomain(sObjectList);
        }
    }

    public override void onAfterInsert() {
        List<Contact> contacts = new List<Contact>();

        System.debug('start');

        for(Contact contactVar : (List<Contact>) Records){
            if(!processedContactIds.contains(contactVar.Id) &&
                    (String.isNotBlank(contactVar.BPAY_CRN__c)
                            || String.isNotBlank(contactVar.Second_BPAY_CRN__c)
                            || String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c)
                            || String.isNotBlank(contactVar.BPAY_CRN_History__c)
                            || String.isNotBlank(contactVar.BPAY_CRN_History_2__c)
                            || String.isNotBlank(contactVar.Merged_PIDs__c)
                            || String.isNotBlank(contactVar.Merged_PIDs_2__c)
                    )){
                contacts.add(contactVar);
            }
        }

        if(!contacts.isEmpty()) {
            this.populateMergeHistories(contacts);
        }
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        List<Contact> contacts = new List<Contact>();

        System.debug('start');

        for(Contact contactVar : (List<Contact>) Records){
            if(!processedContactIds.contains(contactVar.Id) &&
                    (
                            (String.isNotBlank(contactVar.BPAY_CRN__c)
                                    || String.isNotBlank(contactVar.Second_BPAY_CRN__c)
                                    || String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c)
                                    || String.isNotBlank(contactVar.BPAY_CRN_History__c)
                                    || String.isNotBlank(contactVar.BPAY_CRN_History_2__c)
                                    || String.isNotBlank(contactVar.Merged_PIDs__c)
                                    || String.isNotBlank(contactVar.Merged_PIDs_2__c)
                            ) &&
                                    vertic_Utils.sObjects.isSomeFieldChanged(
                                            contactVar,
                                            existingRecords.get(contactVar.Id),
                                            new List<SObjectField>{
                                                    Contact.BPAY_CRN__c,
                                                    Contact.Second_BPAY_CRN__c,
                                                    Contact.ShelterBuddy_ID_PID__c,
                                                    Contact.BPAY_CRN_History__c,
                                                    Contact.BPAY_CRN_History_2__c,
                                                    Contact.Merged_PIDs__c,
                                                    Contact.Merged_PIDs_2__c
                                            }
                                    )

                    )){
                contacts.add(contactVar);
            }
        }

        if(!contacts.isEmpty()) {
            this.populateMergeHistories(contacts);
        }
    }

    private void populateMergeHistories(List<Contact> contacts){
        List<Merge_History__c> mergeHistoriesToInsert = new List<Merge_History__c>();
        List<Contact> contactsToUpdate = new List<Contact>();

        if(!contacts.isEmpty()){
            Set<Id> contactIds = new Set<Id>();
            for(Contact contactVar : contacts) {
                contactIds.add(contactVar.Id);
                processedContactIds.add(contactVar.Id);
            }

            Map<String, Merge_History__c> existingMergeHistoriesMap = new Map<String, Merge_History__c>();
            for(Merge_History__c existingHistory : [
                    SELECT Id, Contact__c, Type__c, Name
                    FROM Merge_History__c
                    WHERE Contact__c IN :contactIds
            ]) {
                String historyKey = existingHistory.Contact__c + '|' + existingHistory.Type__c + '|' + existingHistory.Name;
                existingMergeHistoriesMap.put(historyKey, existingHistory);
            }

            for (Contact contactVar : contacts) {
                if (String.isNotBlank(contactVar.BPAY_CRN__c)) {
                    String historyKey = contactVar.Id + '|BPAY CRN|' + contactVar.BPAY_CRN__c;

                    if(!existingMergeHistoriesMap.containsKey(historyKey)) {
                        Merge_History__c mergeHistory = new Merge_History__c();
                        mergeHistory.Contact__c = contactVar.Id;
                        mergeHistory.Type__c = 'BPAY CRN';
                        mergeHistory.Name = contactVar.BPAY_CRN__c;
                        mergeHistoriesToInsert.add(mergeHistory);
                    }
                }

                if (String.isNotBlank(contactVar.Second_BPAY_CRN__c)) {
                    String historyKey = contactVar.Id + '|Second BPAY CRN|' + contactVar.Second_BPAY_CRN__c;

                    if(!existingMergeHistoriesMap.containsKey(historyKey)) {
                        Merge_History__c mergeHistory = new Merge_History__c();
                        mergeHistory.Contact__c = contactVar.Id;
                        mergeHistory.Type__c = 'Second BPAY CRN';
                        mergeHistory.Name = contactVar.Second_BPAY_CRN__c;
                        mergeHistoriesToInsert.add(mergeHistory);
                    }
                }

                if (String.isNotBlank(contactVar.BPAY_CRN_History__c)) {
                    List<String> splitStrings = contactVar.BPAY_CRN_History__c.split(',');
                    Set<String> splitStringsWithoutDuplicates = new Set<String>(splitStrings);

                    if(String.isNotBlank(contactVar.BPAY_CRN__c) && splitStringsWithoutDuplicates.contains(contactVar.BPAY_CRN__c)){
                        splitStringsWithoutDuplicates.remove(contactVar.BPAY_CRN__c);
                    }

                    for (String bpayNumber : splitStringsWithoutDuplicates) {
                        if (String.isNotBlank(bpayNumber)) {
                            String type = bpayNumber.startsWith('2') ? 'Second BPAY CRN' : 'BPAY CRN';
                            String historyKey = contactVar.Id + '|' + type + '|' + bpayNumber;

                            if(!existingMergeHistoriesMap.containsKey(historyKey)) {
                                Merge_History__c mergeHistory = new Merge_History__c();
                                mergeHistory.Contact__c = contactVar.Id;
                                mergeHistory.Type__c = type;
                                mergeHistory.Name = bpayNumber;
                                mergeHistoriesToInsert.add(mergeHistory);
                            }
                        }
                    }
                }

                if (String.isNotBlank(contactVar.BPAY_CRN_History_2__c)) {
                    List<String> splitStrings = contactVar.BPAY_CRN_History_2__c.split(',');
                    Set<String> splitStringsWithoutDuplicates = new Set<String>(splitStrings);

                    for (String bpayNumber : splitStringsWithoutDuplicates) {
                        if (String.isNotBlank(bpayNumber)) {
                            String type = bpayNumber.startsWith('2') ? 'Second BPAY CRN' : 'BPAY CRN';
                            String historyKey = contactVar.Id + '|' + type + '|' + bpayNumber;

                            if(!existingMergeHistoriesMap.containsKey(historyKey)) {
                                Merge_History__c mergeHistory = new Merge_History__c();
                                mergeHistory.Contact__c = contactVar.Id;
                                mergeHistory.Type__c = type;
                                mergeHistory.Name = bpayNumber;
                                mergeHistoriesToInsert.add(mergeHistory);
                            }
                        }
                    }
                }

                if (String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c)) {
                    String historyKey = contactVar.Id + '|ShelterBuddy ID (PID)|' + contactVar.ShelterBuddy_ID_PID__c;

                    if(!existingMergeHistoriesMap.containsKey(historyKey)) {
                        Merge_History__c mergeHistory = new Merge_History__c();
                        mergeHistory.Contact__c = contactVar.Id;
                        mergeHistory.Type__c = 'ShelterBuddy ID (PID)';
                        mergeHistory.Name = contactVar.ShelterBuddy_ID_PID__c;
                        mergeHistoriesToInsert.add(mergeHistory);
                    }
                }

                if (String.isNotBlank(contactVar.Merged_PIDs__c)) {
                    List<String> splitStrings = contactVar.Merged_PIDs__c.split(',');
                    Set<String> splitStringsWithoutDuplicates = new Set<String>(splitStrings);

                    if(String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c) && splitStringsWithoutDuplicates.contains(contactVar.ShelterBuddy_ID_PID__c)){
                        splitStringsWithoutDuplicates.remove(contactVar.ShelterBuddy_ID_PID__c);
                    }

                    for (String shelterBuddyId : splitStringsWithoutDuplicates) {
                        if (String.isNotBlank(shelterBuddyId)) {
                            String historyKey = contactVar.Id + '|ShelterBuddy ID (PID)|' + shelterBuddyId;

                            if(!existingMergeHistoriesMap.containsKey(historyKey)) {
                                Merge_History__c mergeHistory = new Merge_History__c();
                                mergeHistory.Contact__c = contactVar.Id;
                                mergeHistory.Type__c = 'ShelterBuddy ID (PID)';
                                mergeHistory.Name = shelterBuddyId;
                                mergeHistoriesToInsert.add(mergeHistory);
                            }
                        }
                    }
                }

                if (String.isNotBlank(contactVar.Merged_PIDs_2__c)) {
                    List<String> splitStrings = contactVar.Merged_PIDs_2__c.split(',');
                    Set<String> splitStringsWithoutDuplicates = new Set<String>(splitStrings);

                    if(String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c) && splitStringsWithoutDuplicates.contains(contactVar.ShelterBuddy_ID_PID__c)){
                        splitStringsWithoutDuplicates.remove(contactVar.ShelterBuddy_ID_PID__c);
                    }

                    for (String shelterBuddyId : splitStringsWithoutDuplicates) {
                        if (String.isNotBlank(shelterBuddyId)) {
                            String historyKey = contactVar.Id + '|ShelterBuddy ID (PID)|' + shelterBuddyId;
                            
                            if(!existingMergeHistoriesMap.containsKey(historyKey)) {
                                Merge_History__c mergeHistory = new Merge_History__c();
                                mergeHistory.Contact__c = contactVar.Id;
                                mergeHistory.Type__c = 'ShelterBuddy ID (PID)';
                                mergeHistory.Name = shelterBuddyId;
                                mergeHistoriesToInsert.add(mergeHistory);
                            }
                        }
                    }
                }

                if(Trigger.isUpdate){
                    contactsToUpdate.add(new Contact(
                            Id = contactVar.Id,
                            Merge_Histories_Created__c = true
                    ));
                }
            }

            System.debug('Total Merge History records created - ' + mergeHistoriesToInsert.size());

            if (!mergeHistoriesToInsert.isEmpty()) {
                insert mergeHistoriesToInsert;
            }

            fflib_SObjectDomain.getTriggerEvent(ContactMergeHistoryDomain.class).disableAll();

            if(Trigger.isUpdate){
                Database.update(contactsToUpdate);
            }

            fflib_SObjectDomain.getTriggerEvent(ContactMergeHistoryDomain.class).enableAll();
        }
    }
}