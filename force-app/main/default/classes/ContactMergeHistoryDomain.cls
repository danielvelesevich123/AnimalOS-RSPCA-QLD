public with sharing class ContactMergeHistoryDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain{
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
            if(
                    String.isNotBlank(contactVar.BPAY_CRN__c)
                        || String.isNotBlank(contactVar.Second_BPAY_CRN__c)
                        || String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c)
                        || String.isNotBlank(contactVar.BPAY_CRN_History__c)
                        || String.isNotBlank(contactVar.BPAY_CRN_History_2__c)
                        || String.isNotBlank(contactVar.Merged_PIDs__c)
                        || String.isNotBlank(contactVar.Merged_PIDs_2__c)
            ){
                contacts.add(contactVar);
            }
        }

        this.populateMergeHistories(contacts);
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        List<Contact> contacts = new List<Contact>();

        System.debug('start');

        for(Contact contactVar : (List<Contact>) Records){
            if(
                    (
                            String.isNotBlank(contactVar.BPAY_CRN__c)
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

            ){
                contacts.add(contactVar);
            }
        }

        this.populateMergeHistories(contacts);
    }

    private void populateMergeHistories(List<Contact> contacts){
        List<Merge_History__c> mergeHistoriesToInsert = new List<Merge_History__c>();

        if(!contacts.isEmpty()){
            for (Contact contactVar : contacts) {
                if (String.isNotBlank(contactVar.BPAY_CRN__c)) {
                    Merge_History__c mergeHistory = new Merge_History__c();
                    mergeHistory.Contact__c = contactVar.Id;
                    mergeHistory.Type__c = 'BPAY CRN';
                    mergeHistory.Name = contactVar.BPAY_CRN__c;

                    mergeHistoriesToInsert.add(mergeHistory);
                }

                if (String.isNotBlank(contactVar.Second_BPAY_CRN__c)) {
                    Merge_History__c mergeHistory = new Merge_History__c();
                    mergeHistory.Contact__c = contactVar.Id;
                    mergeHistory.Type__c = 'Second BPAY CRN';
                    mergeHistory.Name = contactVar.Second_BPAY_CRN__c;

                    mergeHistoriesToInsert.add(mergeHistory);
                }

                if (String.isNotBlank(contactVar.BPAY_CRN_History__c)) {
                    List<String> splitStrings = contactVar.BPAY_CRN_History__c.split(',');
                    Set<String> splitStringsWithoutDuplicates = new Set<String>(splitStrings);

                    if(String.isNotBlank(contactVar.BPAY_CRN__c) && splitStringsWithoutDuplicates.contains(contactVar.BPAY_CRN__c)){
                        splitStringsWithoutDuplicates.remove(contactVar.BPAY_CRN__c);
                    }

                    for (String bpayNumber : splitStringsWithoutDuplicates) {
                        if (String.isNotBlank(bpayNumber)) {
                            Merge_History__c mergeHistory = new Merge_History__c();
                            mergeHistory.Contact__c = contactVar.Id;
                            mergeHistory.Type__c = bpayNumber.startsWith('2') ? 'Second BPAY CRN' : 'BPAY CRN';
                            mergeHistory.Name = bpayNumber;

                            mergeHistoriesToInsert.add(mergeHistory);
                        }
                    }
                }

                if (String.isNotBlank(contactVar.BPAY_CRN_History_2__c)) {
                    List<String> splitStrings = contactVar.BPAY_CRN_History_2__c.split(',');
                    Set<String> splitStringsWithoutDuplicates = new Set<String>(splitStrings);

                    for (String bpayNumber : splitStringsWithoutDuplicates) {
                        if (String.isNotBlank(bpayNumber)) {
                            Merge_History__c mergeHistory = new Merge_History__c();
                            mergeHistory.Contact__c = contactVar.Id;
                            mergeHistory.Type__c = bpayNumber.startsWith('2') ? 'Second BPAY CRN' : 'BPAY CRN';
                            mergeHistory.Name = bpayNumber;

                            mergeHistoriesToInsert.add(mergeHistory);
                        }
                    }
                }

                if (String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c)) {
                    Merge_History__c mergeHistory = new Merge_History__c();
                    mergeHistory.Contact__c = contactVar.Id;
                    mergeHistory.Type__c = 'ShelterBuddy ID (PID)';
                    mergeHistory.Name = contactVar.ShelterBuddy_ID_PID__c;

                    mergeHistoriesToInsert.add(mergeHistory);
                }

                if (String.isNotBlank(contactVar.Merged_PIDs__c)) {
                    List<String> splitStrings = contactVar.Merged_PIDs__c.split(',');
                    Set<String> splitStringsWithoutDuplicates = new Set<String>(splitStrings);

                    if(String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c) && splitStringsWithoutDuplicates.contains(contactVar.ShelterBuddy_ID_PID__c)){
                        splitStringsWithoutDuplicates.remove(contactVar.ShelterBuddy_ID_PID__c);
                    }

                    for (String shelterBuddyId : splitStringsWithoutDuplicates) {
                        if (String.isNotBlank(shelterBuddyId)) {
                            Merge_History__c mergeHistory = new Merge_History__c();
                            mergeHistory.Contact__c = contactVar.Id;
                            mergeHistory.Type__c = 'ShelterBuddy ID (PID)';
                            mergeHistory.Name = shelterBuddyId;

                            mergeHistoriesToInsert.add(mergeHistory);
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
                            Merge_History__c mergeHistory = new Merge_History__c();
                            mergeHistory.Contact__c = contactVar.Id;
                            mergeHistory.Type__c = 'ShelterBuddy ID (PID)';
                            mergeHistory.Name = shelterBuddyId;

                            mergeHistoriesToInsert.add(mergeHistory);
                        }
                    }
                }


                if(Trigger.isUpdate){
                    contactVar.Merge_Histories_Created__c = true;
                }
            }

            System.debug('Total Merge History records created - ' + mergeHistoriesToInsert.size());

            if (!mergeHistoriesToInsert.isEmpty()) {
                insert mergeHistoriesToInsert;
            }

            fflib_SObjectDomain.getTriggerEvent(ContactMergeHistoryDomain.class).disableAll();

            if(Trigger.isUpdate){
                Database.update(contacts);
            }

            fflib_SObjectDomain.getTriggerEvent(ContactMergeHistoryDomain.class).enableAll();
        }
    }
}