public virtual with sharing class SyncInspectorateScheduledBatch extends animalos.vertic_SequentialScheduledBatch {

    protected SObjectType sObjectTypeVar;

    public override List<animalos__Setting__c> getSequentialBatchSettings() {
        return Database.query(new fflib_QueryFactory(animalos__Setting__c.SObjectType)
                .selectFields(animalos__Setting__c.SObjectType.getDescribe().fields.getMap().keySet())
                .setCondition('animalos__Is_Active__c = TRUE AND RecordType.DeveloperName = \'Sequential_Batch\' AND animalos__Processor__c LIKE \'SyncInspectorate%\'')
                .setOrdering(animalos__Setting__c.animalos__Order__c, fflib_QueryFactory.SortOrder.ASCENDING, true)
                .toSOQL()
        );
    }

    public virtual override Database.QueryLocator getLocator() {
        List<String> conditions = new List<String>();
        if (String.isNotBlank(this.sequentialBatchSetting.animalos__Conditions__c)) {
            conditions.add('(' + sequentialBatchSetting.animalos__Conditions__c + ')');
        }

        Datetime lastCalculationDatetime = this.sequentialBatchSetting.animalos__Last_Calculation_Datetime__c;
        if (lastCalculationDatetime != null) {
            conditions.add('(LastModifiedDate >= :lastCalculationDatetime OR Sync_Inspectorate__c = NULL)');
        }

        this.sObjectTypeVar = Schema.getGlobalDescribe().get(this.sequentialBatchSetting.animalos__SObject_Type__c);
        System.debug(new fflib_QueryFactory(this.sObjectTypeVar)
                .selectFields(this.getSelectFields())
                .setCondition(String.join(conditions, ' AND '))
                .toSOQL());

        return Database.getQueryLocator(
                new fflib_QueryFactory(this.sObjectTypeVar)
                        .selectFields(this.getSelectFields())
                        .setCondition(String.join(conditions, ' AND '))
                        .toSOQL()
        );
    }

    public Set<String> getSelectFields() {
        Set<String> fields = this.sObjectTypeVar.getDescribe().fields.getMap().keySet().clone();
        fields.addAll(this.addFields());
        return fields;
    }

    public virtual Set<String> addFields() {
        return new Set<String>();
    }

    public override void execute(Database.BatchableContext BC, List<SObject> scope) {
        try {
            this.process(scope);
        } catch (Exception ex) {
            insert new animalos.Logging()
                    .setProcess(this.sequentialBatchSetting.animalos__Processor__c)
                    .addPayload('recordIds', String.join(vertic_Utils.sObjects.getStringFieldValues(scope, 'Id'), ','))
                    .addPayload('errorMessage', ex.getMessage())
                    .addDetails(ex)
                    .build();
        }
    }

    public override Database.QueryLocator start(Database.BatchableContext BC) {
        delete [
                SELECT Id
                FROM animalos__Log__c
                WHERE animalos__Process__c = :this.sequentialBatchSetting.animalos__Processor__c
        ];

        return this.getLocator();
    }

    public override void handleFinish(Id batchJobId) {
        AsyncApexJob batchJob = (AsyncApexJob) vertic_Utils.arrays.firstOrNull([
                SELECT Id, NumberOfErrors, TotalJobItems
                FROM AsyncApexJob
                WHERE Id = :batchJobId
                WITH SECURITY_ENFORCED
        ]);

        if (batchJob == null) {
            return;
        }

        animalos__Setting__c settingVar = new animalos__Setting__c(
                Id = this.sequentialBatchSetting.Id,
                animalos__Last_Calculation_Datetime__c = Datetime.now()
        );

        List<AggregateResult> results = [
                SELECT COUNT(Id) countOfErrors
                FROM animalos__Log__c
                WHERE animalos__Process__c = :this.sequentialBatchSetting.animalos__Processor__c
        ];

        Integer countOfErrors = (Integer) results[0].get('countOfErrors');
        if (countOfErrors > 0) {
            settingVar.animalos__Scope_Size__c = this.sequentialBatchSetting.animalos__Scope_Size__c == 1 ?
                    this.sequentialBatchSetting.animalos__Scope_Size__c :
                    Integer.valueOf(this.sequentialBatchSetting.animalos__Scope_Size__c / 2);
        }

        update settingVar;
    }

    public static void restart() {
        restart(true);
    }

    public static void restart(Boolean initialSync) {
        recreateSettingRecords();
        schedule();
        if (initialSync == true) {
            sync();
        }
    }

    public static void recreateSettingRecords() {
        delete [
                SELECT Id
                FROM animalos__Setting__c
                WHERE animalos__Processor__c LIKE 'SyncInspectorate%'
        ];

        insert generateDefaultSyncInspectorateSettings();
    }

    public static void sync() {
        new SyncInspectorateScheduledBatch().run();
    }

    public static void removeScheduledJob() {
        CronTrigger existingJob = (CronTrigger) vertic_Utils.arrays.firstOrNull([
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name = 'Sync Inspectorate Data - Every Day at 5AM'
                LIMIT 1
        ]);

        if (existingJob != null) {
            System.abortJob(existingJob.Id);
        }
    }

    public static Id schedule() {
        removeScheduledJob();
        return System.schedule(
                'Sync Inspectorate Data - Every Hour',
                '0 0 * * * ?', // Every Hour
                new SyncInspectorateScheduledBatch()
        );
    }

    public SObject syncRecord(SObject source, SObject target, String targetSObjectType) {
        if (target == null) {
            target = (SObject) Type.forName(targetSObjectType).newInstance();
            target.put('Sync_Inspectorate__c', source.get('Id'));
            target = SObjectMapper.mapAuditFields(source, target);
        }

        target = SObjectMapper.mapAllFields(source, '', target, 'animalos');
        return target;
    }

    public static List<animalos__Setting__c> generateDefaultSyncInspectorateSettings() {
        String sequentialBatchRecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Sequential_Batch');
        return new List<animalos__Setting__c>{
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Parent Area',
                        animalos__Processor__c = 'SyncInspectorateParentArea',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 1,
                        animalos__SObject_Type__c = 'Area__c',
                        animalos__Conditions__c = 'Parent_Area__c = NULL',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Area',
                        animalos__Processor__c = 'SyncInspectorateArea',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 2,
                        animalos__SObject_Type__c = 'Area__c',
                        animalos__Conditions__c = 'Parent_Area__c != NULL',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Polygon',
                        animalos__Processor__c = 'SyncInspectoratePolygon',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 3,
                        animalos__SObject_Type__c = 'Polygon__c',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Coordinates',
                        animalos__Processor__c = 'SyncInspectorateCoordinates',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 4,
                        animalos__SObject_Type__c = 'Coordinates__c',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Resource',
                        animalos__Processor__c = 'SyncInspectorateResource',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 5,
                        animalos__SObject_Type__c = 'Inspector__c',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Area Assignment',
                        animalos__Processor__c = 'SyncInspectorateAreaAssignment',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 6,
                        animalos__SObject_Type__c = 'Area_Assignment__c',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Location of Interest',
                        animalos__Processor__c = 'SyncInspectorateLocationOfInterest',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 7,
                        animalos__SObject_Type__c = 'Location__c',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Parent Job',
                        animalos__Processor__c = 'SyncInspectorateParentJob',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 8,
                        animalos__SObject_Type__c = 'Job__c',
                        animalos__Conditions__c = 'Parent_Job__c = NULL',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Job',
                        animalos__Processor__c = 'SyncInspectorateJob',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 9,
                        animalos__SObject_Type__c = 'Job__c',
                        animalos__Conditions__c = 'Parent_Job__c != NULL',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Job Activity',
                        animalos__Processor__c = 'SyncInspectorateJobActivity',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 10,
                        animalos__SObject_Type__c = 'Inspectorate_Activity__c',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Assigned Resource',
                        animalos__Processor__c = 'SyncInspectorateAssignedResource',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 11,
                        animalos__SObject_Type__c = 'Assigned_Inspector__c',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Job Status Tracking',
                        animalos__Processor__c = 'SyncInspectorateJobStatusTracking',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 12,
                        animalos__SObject_Type__c = 'Job_Custom_Status_Tracking__c',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Job Contact',
                        animalos__Processor__c = 'SyncInspectorateJobContact',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 13,
                        animalos__SObject_Type__c = 'Job_Contact__c',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Animal Report',
                        animalos__Processor__c = 'SyncInspectorateAnimalReport',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 14,
                        animalos__SObject_Type__c = 'Animal_Report__c',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Interaction Caution',
                        animalos__Processor__c = 'SyncInspectorateInteractionCaution',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 15,
                        animalos__SObject_Type__c = 'Interaction_Caution__c',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Referral',
                        animalos__Processor__c = 'SyncInspectorateReferral',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 16,
                        animalos__SObject_Type__c = 'animalos__Referral__c',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        animalos__Conditions__c = 'Job_Custom__c != NULL AND animalos__Job__c = NULL',
                        RecordTypeId = sequentialBatchRecordTypeId
                ),
                new animalos__Setting__c(
                        Name = 'Sync Inspectorate Data – Contact',
                        animalos__Processor__c = 'SyncInspectorateContact',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 17,
                        animalos__SObject_Type__c = 'Contact',
                        animalos__Scope_Size__c = 100,
                        animalos__Type__c = 'Apex',
                        animalos__Conditions__c = '(Id IN (SELECT Contact__c FROM Job_Contact__c)) AND (AND POI_Description__c != NULL OR POI_Job_Codes__c != NULL)',
                        RecordTypeId = sequentialBatchRecordTypeId
                )
        };

    }
}