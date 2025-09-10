public without sharing class vertic_DMLBatch implements Database.Batchable<SObject> {
    public SObjectType sObjectType;
    public List<String> conditions;
    public Map<Id, SObject> recordsMap;
    public Integer limitVar = 10000;
    public String operation = 'update';
    public String orderBy = 'Id ASC';

    public vertic_DMLBatch(SObjectType sObjectType, String condition) {
        this(sObjectType, String.isNotBlank(condition) ? new List<String>{
            condition
        } : new List<String>());
    }

    public vertic_DMLBatch(SObjectType sObjectType, List<String> conditions) {
        this(sObjectType, new Map<Id, SObject>(), conditions);
        this.sObjectType = sObjectType;
        this.conditions = conditions;
    }

    public vertic_DMLBatch(SObjectType sObjectType) {
        this.sObjectType = sObjectType;
        this.conditions = new List<String>();
    }

    public vertic_DMLBatch(Map<Id, SObject> recordsMap, List<String> conditions) {
        this(recordsMap.values().get(0).getSObjectType(), recordsMap, conditions);
    }
    public vertic_DMLBatch(SObjectType sObjectType, Map<Id, SObject> recordsMap, List<String> conditions) {
        this.sObjectType = sObjectType;
        this.conditions = conditions == null ? new List<String>() : conditions;
        this.recordsMap = recordsMap;
        if (recordsMap != null && recordsMap.size() > 0) {
            Set<String> ids = vertic_Utils.sObjects.getStringFieldValues(recordsMap.values(), 'Id');
            this.conditions.add('Id IN (\'' + String.join(new List<String>(ids), '\', \'') + '\')');
        }
    }


    public Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id FROM ' + sObjectType.getDescribe().getLocalName();
        if (conditions != null && conditions.size() > 0) {
            queryString += ' WHERE ' + String.join(conditions, ' AND ');
        }
        if(String.isNotBlank(this.orderBy)){
            queryString += ' ORDER BY ' + this.orderBy;
        }
        return Database.getQueryLocator(queryString);
    }

    public vertic_DMLBatch setDeleteOperation() {
        this.operation = 'delete';
        return this;
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        Map<Id, SObject> records = new Map<Id, SObject>();
        for (SObject sObj : scope) {
            if (recordsMap != null && recordsMap.containsKey(sObj.Id)) {
                SObject record = recordsMap.get(sObj.Id);
                records.put(record.Id, record);
            } else {
                records.put(sObj.Id, sObj);
            }
        }


        if (records.isEmpty()) {
            return;
        }

        if (this.operation.equals('delete')) {
            Database.delete(records.values(), false);

        } else if (this.operation.equals('update')) {
            Database.update(records.values(), false);

        }


    }

    public void finish(Database.BatchableContext BC) {
    }
}