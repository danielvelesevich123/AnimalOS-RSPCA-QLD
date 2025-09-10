global class MapExternalIdToNameBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, External_ID__c
            FROM animalos__Job__c
            WHERE External_ID__c != NULL
        ]);
    }

    global void execute(Database.BatchableContext bc, List<animalos__Job__c> scope) {
        for (animalos__Job__c job : scope) {
            job.Name = job.External_ID__c;
        }
        update scope;
    }

    global void finish(Database.BatchableContext bc) {
        // Optional: Logging or notifications can go here
    }
}