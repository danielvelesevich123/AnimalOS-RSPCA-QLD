global without sharing class UpdateAnyRecordsBatch implements Database.Batchable<sObject> {

    global String SOQL;
    global Boolean OptAllOrNone = true;
    global Set<Type> domainToDisable;

    private Map<SObjectField, Object> updatesMap;

    global UpdateAnyRecordsBatch(String SOQL, Boolean OptAllOrNone) {
        this(SOQL, OptAllOrNone, null);
    }

    global UpdateAnyRecordsBatch(String SOQL, Boolean OptAllOrNone, Map<SObjectField, Object> updatesMap) {
        this(SOQL, OptAllOrNone, updatesMap, null);
    }

    global UpdateAnyRecordsBatch(String SOQL, Boolean OptAllOrNone, Map<SObjectField, Object> updatesMap, Set<Type> domainToDisable) {
        this.SOQL = SOQL;
        this.OptAllOrNone = OptAllOrNone;
        this.updatesMap = updatesMap;
        this.domainToDisable = domainToDisable;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.SOQL);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.OptAllOrNone = this.OptAllOrNone;
        dmlOptions.AllowFieldTruncation = true;

        if (this.updatesMap != null) {
            for (SObject recordVar : scope) {
                for (SObjectField fieldVar : updatesMap.keySet()) {
                    recordVar.put(fieldVar, updatesMap.get(fieldVar));
                }
            }
        }

        if(domainToDisable != null){
            for (Type domainType : domainToDisable) {
                fflib_SObjectDomain.getTriggerEvent(domainType).disableAll();
            }
        }

        List<Database.SaveResult> saveResults = Database.update(scope, dmlOptions);
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                System.debug(saveResult);
            }
        }

    }

    global void finish(Database.BatchableContext BC) {
    }

}