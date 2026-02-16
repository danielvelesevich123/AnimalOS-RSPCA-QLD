global class aos_UpdateJobRecordTypeBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Map<String, String> oldRecordTypeToNewRecordTypeMap = new Map<String, String>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<RecordType> recordTypes = [
                SELECT Id, Name, DeveloperName, NamespacePrefix
                FROM RecordType
                WHERE SobjectType = 'animalos__Job__c'
                ORDER BY Name
        ];

        String managedInspectorateRecordType;
        String managedRescueRecordType;
        String customInspectorateRecordType;
        String customRescueRecordType;

        for (RecordType recordTypeVar : recordTypes) {
            switch on recordTypeVar.DeveloperName {
                when 'Inspectorate' {
                    if (String.isNotBlank(recordTypeVar.NamespacePrefix)) {
                        managedInspectorateRecordType = recordTypeVar.Id;
                    } else {
                        customInspectorateRecordType = recordTypeVar.Id;
                    }
                }
                when 'Rescue' {
                    if (String.isNotBlank(recordTypeVar.NamespacePrefix)) {
                        managedRescueRecordType = recordTypeVar.Id;
                    } else {
                        customRescueRecordType = recordTypeVar.Id;
                    }
                }
            }
        }

        this.oldRecordTypeToNewRecordTypeMap.put(customInspectorateRecordType, managedInspectorateRecordType);
        this.oldRecordTypeToNewRecordTypeMap.put(customRescueRecordType, managedRescueRecordType);

        return Database.getQueryLocator('SELECT Id, RecordTypeId\n' +
                'FROM animalos__Job__c\n' +
                'WHERE RecordTypeId != NULL');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        for (animalos__Job__c job : (List<animalos__Job__c>) scope) {
            if (this.oldRecordTypeToNewRecordTypeMap.containsKey(job.RecordTypeId)) {
                job.RecordTypeId = this.oldRecordTypeToNewRecordTypeMap.get(job.RecordTypeId);
            }
        }
        animalos.TDTM.getTriggerSObjectTypeEvent(animalos__Job__c.SObjectType).disableAll();
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
    }

}