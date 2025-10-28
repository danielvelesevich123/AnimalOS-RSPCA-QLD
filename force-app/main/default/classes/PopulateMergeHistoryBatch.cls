public class PopulateMergeHistoryBatch implements Database.Batchable<SObject>, Schedulable{
    private Set<String> recordIds;
    private String filter;
    private Integer queryLimit;
    private static Set<Id> processedContactIds = new Set<Id>();

    public PopulateMergeHistoryBatch(){
    }

    public PopulateMergeHistoryBatch(Set<String> recordIds){
        this.recordIds = recordIds;
    }

    public PopulateMergeHistoryBatch(String filter){
        this.filter = filter;
    }

    public PopulateMergeHistoryBatch(Integer queryLimit){
        this.queryLimit = queryLimit;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Name, BPAY_CRN__c, Second_BPAY_CRN__c, BPAY_CRN_History__c, BPAY_CRN_History_2__c, ShelterBuddy_ID_PID__c, Merged_PIDs__c, Merged_PIDs_2__c FROM Contact WHERE ShelterBuddy_ID_PID__c != null AND Merge_Histories_Created__c = false';

        if(recordIds != null && !recordIds.isEmpty()){
            query += ' AND Id IN :recordIds LIMIT ' + recordIds.size();
        }

        if(String.isNotBlank(filter)){
            query += ' AND ' + filter;
        }

        if(queryLimit > 0){
            query += ' LIMIT ' + String.valueOf(queryLimit);
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        List<Merge_History__c> mergeHistoriesToInsert = new List<Merge_History__c>();
        List<Contact> contactsToUpdate = new List<Contact>();

        if(!scope.isEmpty()){
            Set<Id> contactIds = new Set<Id>();
            for(Contact contactVar : (List<Contact>)scope) {
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

            for (Contact contactVar : (List<Contact>)scope) {
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

                contactVar.Merge_Histories_Created__c = true;
            }

            System.debug('Total Merge History records created - ' + mergeHistoriesToInsert.size());

            if (!mergeHistoriesToInsert.isEmpty()) {
                insert mergeHistoriesToInsert;
            }

        fflib_SObjectDomain.getTriggerEvent(ContactMergeHistoryDomain.class).disableAll();

            update scope;

        fflib_SObjectDomain.getTriggerEvent(ContactMergeHistoryDomain.class).enableAll();
    }
    }

    public void finish(Database.BatchableContext context) {
    }

    public void execute(SchedulableContext context) {
//        Database.executeBatch(new PopulateMergeHistoryBatch(), 1);
        Database.executeBatch(new PopulateMergeHistoryBatch('LastModifiedDate >= LAST_N_DAYS:1'), 200);
    }
}