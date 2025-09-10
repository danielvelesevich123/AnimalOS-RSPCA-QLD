global with sharing class ProcessAnyRecordsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private vertic_Request request;

    public ProcessAnyRecordsBatch(vertic_Request request){
        this.request = request;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.request.getRequiredString('query'));
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Map<String, Object> procRequest = new Map<String, Object>();

        if(this.request.getBoolean('onePerChunk') == true){
            procRequest.put('recordId', scope[0].Id);
        } else {
            procRequest.put('recordIds', new List<String>(vertic_Utils.sObjects.getStringFieldValues(scope, 'Id')));
        }

        if(this.request.get('params') != null){
            procRequest.put('params', (Map<String, Object>) this.request.get('params'));
        }
        procRequest.put('isCompleteStatus', true);

        List<String> procNames = this.request.getListAsStrings('procNames');
        for (String procName : procNames) {
            vertic_ProcessorFactory.getInstance(procName).process(new vertic_MetadataProcessor.MetadataRequest(JSON.serialize(procRequest)));
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('ProcessAnyRecordsBatch finished!');
    }
}