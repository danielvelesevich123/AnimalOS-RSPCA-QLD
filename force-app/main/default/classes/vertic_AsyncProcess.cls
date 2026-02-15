public class vertic_AsyncProcess {

    private List<aos_Async_Process__c> asyncProcesses = new List<aos_Async_Process__c>();

    public List<aos_Async_Process__c> enqueue() {
        insert this.asyncProcesses;
        return asyncProcesses;
    }

    public Id enqueueAndRun() {
        for (aos_Async_Process__c verticAsyncProcess : asyncProcesses) {
            verticAsyncProcess.aos_Autorun__c = false;
        }
        return run(this.enqueue());
    }

    public Boolean isEmpty() {
        return this.asyncProcesses.isEmpty();
    }

    public vertic_AsyncProcess add(aos_Async_Process__c asyncProcessVar) {
        this.asyncProcesses.add(asyncProcessVar);
        return this;
    }

    public vertic_AsyncProcess add(String processor, Map<String, Object> payload) {
        return this.add(create(processor, payload, null));
    }

    public vertic_AsyncProcess add(String processor, Map<String, Object> payload, Datetime runAfter) {
        return this.add(create(processor, payload, runAfter));
    }

    public vertic_AsyncProcess add(Type processorType, Map<String, Object> payload) {
        return add(create(processorType, payload, (Datetime) null));
    }

    public vertic_AsyncProcess add(Type processorType, Map<String, Object> payload, Time atTime) {
        return add(create(processorType, payload, atTime));
    }

    public vertic_AsyncProcess add(Type processorType, Map<String, Object> payload, Integer daysAfter, Time atTime) {
        return add(create(processorType, payload, daysAfter, atTime));
    }


    public static Id run(List<aos_Async_Process__c> asyncProcesses) {
        List<Id> ids = new List<Id>();
        for (aos_Async_Process__c verticAsyncProcess : asyncProcesses) {
            vertic_Utils.objects.throwIfNull(verticAsyncProcess.Id, 'Async Process should be created before the run');
            ids.add(verticAsyncProcess.Id);
        }
        return vertic_AsyncProcessBatch.run(ids);
    }


    public static aos_Async_Process__c create(String processor, Map<String, Object> payload, Datetime runAfter) {
        return new aos_Async_Process__c(
                aos_Processor__c = processor,
                aos_Payload__c = JSON.serialize(payload),
                aos_Run_After__c = runAfter
        );
    }

    public static aos_Async_Process__c create(Type processorType, Map<String, Object> payload, Datetime runAfter) {
        return create('' + processorType, payload, runAfter);
    }

    public static aos_Async_Process__c create(Type processorType, Map<String, Object> payload) {
        return create(processorType, payload, (Datetime) null);
    }

    public static aos_Async_Process__c create(Type processorType, Map<String, Object> payload, Integer daysAfter, Time atTime) {
        Datetime runAfter = Datetime.newInstance(Date.today().addDays(daysAfter), atTime);
        if (daysAfter == 0 && runAfter < Datetime.now()) {
            runAfter = runAfter.addDays(1);
        }

        return create(processorType, payload, runAfter);
    }

    public static aos_Async_Process__c create(Type processorType, Map<String, Object> payload, Time atTime) {
        return create(processorType, payload, 0, atTime);
    }

    public static void process(Set<String> verticAsyncProcessIds) {
        process(verticAsyncProcessIds, null);
    }

    public static void process(Set<String> verticAsyncProcessIds, Map<String, Object> options) {

        try {

            List<aos_Async_Process__c> asyncProcesses = [
                    SELECT Id, aos_Status__c, aos_Processor__c, aos_Payload__c, aos_Details__c, aos_Is_Queueable__c, aos_Attempts__c, aos_Allowed_Attempts__c
                    FROM aos_Async_Process__c
                    WHERE Id IN :verticAsyncProcessIds
                    FOR UPDATE
            ];

            List<aos_Async_Process__c> asyncProcessesToUpdate = new List<aos_Async_Process__c>();

            vertic_DTO optionsDTO = new vertic_DTO(options == null ? new Map<String, Object>() : options);

            for (aos_Async_Process__c asyncProcessVar : asyncProcesses) {

                Boolean isProcessed = new Set<String>{
                        'Pending', 'Retrying', 'Queued'
                }.contains(asyncProcessVar.aos_Status__c) == false;
                Boolean forceStatus = optionsDTO.getBoolean('forceStatus');

                if (isProcessed && forceStatus != true) {
                    continue;
                }

                if (asyncProcessVar.aos_Is_Queueable__c && !System.isQueueable() && !Test.isRunningTest()) {
                    System.enqueueJob(new QueueableProc(asyncProcessVar.Id));
                    asyncProcessVar.aos_Status__c = 'Queued';
                    asyncProcessesToUpdate.add(asyncProcessVar);
                    continue;
                }

                Boolean isValidationException = false;
                Savepoint savepointVar;
                try {

                    vertic_AbstractProcessor processorVar = vertic_ProcessorFactory.getInstance(asyncProcessVar.aos_Processor__c);
                    if (processorVar instanceof vertic_Structs.IRollbackable) {
                        savepointVar = Database.setSavepoint();
                    }

                    vertic_Request requestVar = processorVar.getRequestInstance(asyncProcessVar.aos_Payload__c);
                    vertic_Response responseVar = processorVar.process(requestVar);

                    asyncProcessVar.aos_Details__c = JSON.serialize(responseVar.getMap());

                    if (responseVar.isValid == true) {
                        asyncProcessVar.aos_Status__c = 'Completed';
                    } else {
                        asyncProcessVar.aos_Status__c = 'Failed';

                        if (!requestVar.has('logger') || requestVar.getBoolean('logger') == true) {
                        }
                    }

                    if (processorVar instanceof vertic_Structs.IAsyncPostProcessing) {
                        asyncProcessVar = ((vertic_Structs.IAsyncPostProcessing) processorVar).postProcess(asyncProcessVar);
                    }

                } catch (Exception ex) {

                    if (savepointVar != null) {
                        Database.rollback(savepointVar);
                    }

                    asyncProcessVar.aos_Status__c = 'Failed';
                    asyncProcessVar.aos_Details__c = ex.getMessage() + ' ' + ex.getStackTraceString();

                    isValidationException = ex instanceof vertic_Structs.ValidationException;

                } finally {

                    asyncProcessVar.aos_Attempts__c = vertic_Utils.objects.defaultIfNull(asyncProcessVar.aos_Attempts__c, 0) + 1;

                    Boolean isFailed = 'Failed'.equalsIgnoreCase(asyncProcessVar.aos_Status__c);
                    Boolean canBeRetried = isFailed &&
                            isValidationException != true &&
                            asyncProcessVar.aos_Allowed_Attempts__c != null &&
                            asyncProcessVar.aos_Allowed_Attempts__c > asyncProcessVar.aos_Attempts__c;

                    if (canBeRetried) {
                        asyncProcessVar.aos_Status__c = 'Retrying';

                        vertic_Request requestVar = new vertic_Request(asyncProcessVar.aos_Payload__c);

                        if (!requestVar.has('logger') || requestVar.getBoolean('logger') == true) {
                        }

                        Boolean isManyAttempts = asyncProcessVar.aos_Attempts__c > 2 && asyncProcessVar.aos_Allowed_Attempts__c > asyncProcessVar.aos_Attempts__c;

                        Boolean isConcurrentRecordUpdateError = asyncProcessVar.aos_Details__c != null &&
                                (asyncProcessVar.aos_Details__c.contains('UNABLE_TO_LOCK_ROW') || asyncProcessVar.aos_Details__c.contains('Record Currently Unavailable'));

                        Boolean isDisableQueueable = isManyAttempts &&
                                isConcurrentRecordUpdateError &&
                                asyncProcessVar.aos_Is_Queueable__c;

                        Boolean isSetRunAfter = isManyAttempts &&
                                isConcurrentRecordUpdateError &&
                                asyncProcessVar.aos_Run_After__c == null;


                        if (isDisableQueueable) {
                            asyncProcessVar.aos_Is_Queueable__c = false;
                        } else if (isSetRunAfter) {
                            asyncProcessVar.aos_Run_After__c = Datetime.now().addMinutes((Math.random() * 15).intValue());
                        }
                    }

                    asyncProcessesToUpdate.add(asyncProcessVar);
                }

            }

            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.allowFieldTruncation = true;
            Database.update(asyncProcessesToUpdate, dmlOptions);

        } catch (Exception ex) {
        } finally {
        }

    }

    public class QueueableProc implements Queueable, Database.AllowsCallouts {

        private String verticAsyncProId;

        public QueueableProc(String verticAsyncProId) {
            this.verticAsyncProId = verticAsyncProId;
        }

        public void execute(QueueableContext param1) {
            vertic_AsyncProcess.process(new Set<String>{
                    this.verticAsyncProId
            });
        }
    }
}