global class MigrateActionUsedInBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, animalos__Action_Used_In__c\n' +
                'FROM animalos__Medicine_Used__c\n' +
                'WHERE animalos__Animal_Action__c = NULL AND animalos__Action_Used_In__c != NULL');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        for (animalos__Medicine_Used__c medicineUsed : (List<animalos__Medicine_Used__c>) scope) {
//            medicineUsed.animalos__Animal_Action__c = medicineUsed.animalos__Action_Used_In__c;
        }

       update scope;
    }

    global void finish(Database.BatchableContext BC) {
    }

}