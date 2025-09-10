global class DeleteMonthlyStatusTrackingBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id 
            FROM animalos__Status_Tracking__c 
            WHERE RecordType.Name = 'Monthly'
        ]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<animalos__Status_Tracking__c> recordsToDelete = (List<animalos__Status_Tracking__c>) scope;
        delete recordsToDelete;
    }

    global void finish(Database.BatchableContext bc) {
        // Optional: Send email or log finish status
    }
}