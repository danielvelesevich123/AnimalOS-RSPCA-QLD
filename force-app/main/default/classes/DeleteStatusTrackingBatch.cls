public class DeleteStatusTrackingBatch implements Database.Batchable<SObject>{
    private Integer queryLimit;

    public DeleteStatusTrackingBatch(Integer queryLimit){
        this.queryLimit = queryLimit;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id FROM animalos__Status_Tracking__c WHERE RecordType.Name = \'Monthly\'';

        if(queryLimit > 0){
            query += ' LIMIT ' + String.valueOf(queryLimit);
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        if(scope.size() > 0){
            delete scope;
        }
    }

    public void finish(Database.BatchableContext context) {
    }
}