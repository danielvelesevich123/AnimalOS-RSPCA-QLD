global without sharing class vertic_LookupRollupSequentialProc extends vertic_ScheduledProc implements Database.Batchable<sObject>, Database.Stateful{

    private List<AbstractBatchableProcessor> processors;
    private AbstractBatchableProcessor currentProcessor;
    private Boolean trackLastTotalsUpdate = true;

    public override String getScheduledJobName() {
        return 'Vertic Lookup Rollup Sequential Proc - Every Day at 6PM';
    }

    public override String getScheduledCRON() {
        return '0 0 18 * * ? *'; // Every Day at 6pm
    }

    public override Type getScheduledProcType() {
        return vertic_LookupRollupSequentialProc.class;
    }

    public override Boolean isQueueable() {
        return true;
    }

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        if (!'true'.equalsIgnoreCase(vertic_SettingService.getValue('LOOKUP_ROLLUP_SEQUENTIAL_PROC_DISABLED'))) {
            run();
        }

        return this.response;
    }

    public static final Integer DEFAULT_SCOPE_SIZE = 100;
    public static Boolean IS_BATCH_PROCESSING = false;

    public static List<SObject> getProcessorsSettings(){
        SObjectType lookupRollupSettingSObjType = Schema.getGlobalDescribe().get('vertic_Lookup_Rollup_Setting__mdt');
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(lookupRollupSettingSObjType);
        queryFactory.selectFields(new Set<String>{
                'Id',
                'Label',
                'DeveloperName',
                'Is_Active__c',
                'Order__c',
                'Processors__c',
                'Scope_size__c',
                'SObject_Type__c'
        });
        queryFactory.setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING, true);
        queryFactory.setCondition('Is_Active__c = TRUE');
        List<SObject> lookupRollupSettings = Database.query(queryFactory.toSOQL());

        return lookupRollupSettings;
    }

    public static Id run(){
        List<AbstractBatchableProcessor> processors = new List<AbstractBatchableProcessor>();
        Map<String, SObject> lookupRollupStringsMap = new Map<String, SObject>();
        for(SObject processorSetting : getProcessorsSettings()){
            for(String processorName : processorSetting.get('Processors__c').toString().split(',')){
                processors.add((AbstractBatchableProcessor)Type.forName(processorName).newInstance());
                lookupRollupStringsMap.put(processorName, processorSetting);

            }
        }

        return run(processors, lookupRollupStringsMap);
    }

    public static Id run(List<AbstractBatchableProcessor> processors){

        Map<String, SObject> lookupRollupStringsMap = new Map<String, SObject>();

        for(SObject processorSetting : getProcessorsSettings()){
            for(AbstractBatchableProcessor processor : processors){
                String processorName = String.valueOf(processor).split(':')[0];
                if( processorSetting.get('Processors__c').toString().split(',').contains(processorName)){
                    lookupRollupStringsMap.put(processorName, processorSetting);
                }
            }
        }

        return run(processors, lookupRollupStringsMap);

    }
    public static Id run(List<AbstractBatchableProcessor> processors, Map<String, SObject> lookupRollupStringsMap) {
        return run(processors, lookupRollupStringsMap, true);
    }

    public static Id run(List<AbstractBatchableProcessor> processors, Map<String, SObject> lookupRollupStringsMap, Boolean trackLastTotalsUpdate) {

        IS_BATCH_PROCESSING = true;

        if (!processors.isEmpty()) {

            AbstractBatchableProcessor currentProcessor = processors.remove(0);

            return Database.executeBatch(

                    new vertic_LookupRollupSequentialProc(
                            processors,
                            currentProcessor,
                            trackLastTotalsUpdate
                    ),
                    vertic_Utils.objects.defaultIfNull(Integer.valueOf(lookupRollupStringsMap
                            .get(String.valueOf(currentProcessor).split(':')[0])
                            .get('Scope_size__c')),
                            currentProcessor.getScopeSize())
            );

        } else {

            return null;

        }

    }

    public static void setIsBatchProcessing(List<SObject> records) {
        setIsBatchProcessing(records, 'Is_Batch_Processing__c');
    }

    public static void setIsBatchProcessing(List<SObject> records, String field) {
        if (records.size() > 0) {
            for (SObject record : records) {
                record.put(field, IS_BATCH_PROCESSING);
            }
        }
    }

    public vertic_LookupRollupSequentialProc(){

    }

    private vertic_LookupRollupSequentialProc(List<AbstractBatchableProcessor> processors, AbstractBatchableProcessor currentProcessor) {
        this(processors, currentProcessor);
    }

    private vertic_LookupRollupSequentialProc(List<AbstractBatchableProcessor> processors, AbstractBatchableProcessor currentProcessor, Boolean trackLastTotalsUpdate) {
        this.processors = processors;
        this.currentProcessor = currentProcessor;
        this.trackLastTotalsUpdate = trackLastTotalsUpdate;
    }


    global Database.QueryLocator start(Database.BatchableContext BC) {
        return this.currentProcessor.getLocator();
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        this.currentProcessor.processScope(scope);
    }

    global void finish(Database.BatchableContext BC) {

        this.currentProcessor.handleFinish();

        if (!this.processors.isEmpty()) {
            run(this.processors);
        } else {
            if (this.trackLastTotalsUpdate == true) {
                vertic_SettingService.setValues(new Map<String, String>{
                        'LAST_TOTALS_UPDATE' => System.now().format()
                });
            }
        }
    }


    public abstract class AbstractBatchableProcessor {

        public abstract Database.QueryLocator getLocator();

        public abstract void processScope(List<SObject> records);

        public virtual void handleFinish() {
        }

        public virtual Integer getScopeSize() {
            return DEFAULT_SCOPE_SIZE;
        }

    }

    public interface IProcessor {
        void process(List<SObject> records);
    }

//	public interface IStartHandler{
//		void handleStart();
//	}

    public interface IProcessorWithFinishHandler extends IProcessor {
        void handleFinish();
    }

    public class BatchableProcessor extends AbstractBatchableProcessor {

        private String SOQL;
        private IProcessor processorImpl;
        private Integer scopeSize;

        public BatchableProcessor(String SOQL, IProcessor processorImpl) {
            this(
                    SOQL,
                    processorImpl,
                    DEFAULT_SCOPE_SIZE
            );
        }

        public BatchableProcessor(String SOQL, IProcessor processorImpl, Integer scopeSize) {
            this.SOQL = SOQL;
            this.processorImpl = processorImpl;
            this.scopeSize = scopeSize;
        }

        public override Database.QueryLocator getLocator() {
            return Database.getQueryLocator(this.SOQL);
        }

        public override void processScope(List<SObject> records) {
            vertic_LookupRollupSequentialProc.IS_BATCH_PROCESSING = true;
            processorImpl.process(records);
        }

        public override void handleFinish() {
            if (processorImpl instanceOf IProcessorWithFinishHandler) {
                vertic_LookupRollupSequentialProc.IS_BATCH_PROCESSING = true;
                ((IProcessorWithFinishHandler) processorImpl).handleFinish();
            }
        }

        public override Integer getScopeSize() {
            return this.scopeSize;
        }

    }

}