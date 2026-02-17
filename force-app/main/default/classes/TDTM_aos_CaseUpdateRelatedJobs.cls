global class TDTM_aos_CaseUpdateRelatedJobs extends animalos.TDTM.Handler implements animalos.TDTM.AfterUpdate, animalos.TDTM.AfterInsert {
    private List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

    public void onAfterInsert(List<SObject> records) {
        this.updateRelatedJobs(records, new Map<Id, Case>());
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.updateRelatedJobs(records, (Map<Id, Case>) oldMap);
    }

    private void updateRelatedJobs(List<Case> records, Map<Id, Case> existingRecords) {
        String crueltyRecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(Case.SObjectType, 'Inspectorate_Cruelty');
        List<animalos__Job__c> jobsToUpdate = new List<animalos__Job__c>();

        Map<String, SObject> jobsByCaseIds = aos_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, Name, aos_Case__c, animalos__Subject__c, animalos__Description__c, animalos__Animal_Report_Summary__c, animalos__Priority__c, OwnerId, aos_Sync_with_Case_Priority__c
                FROM animalos__Job__c
                WHERE aos_Case__c IN :records
                AND aos_Case__r.RecordTypeId = :crueltyRecordTypeId
                ORDER BY CreatedDate ASC
        ], animalos__Job__c.aos_Case__c);

        Set<Id> ownerIds = aos_Utils.sObjects.getIdFieldValues(jobsByCaseIds.values(), animalos__Job__c.OwnerId);

        EmailTemplate jobUpdateEmailTemplate = (EmailTemplate) aos_Utils.arrays.firstOrException([
                SELECT DeveloperName, Name
                FROM EmailTemplate
                WHERE DeveloperName = 'AOS_Job_Update_Notification_1732535621814'
        ], 'No Template with DeveloperName AOS_Job_Update_Notification_1732535621814 found');

        Map<Id, User> usersById = new Map<Id, User>([
                SELECT Id, Email
                FROM User
                WHERE Id IN :ownerIds
        ]);

        aos_AsyncProcess asyncProcess = new aos_AsyncProcess();

        for (Case caseVar : records) {
            Boolean isInsert = Trigger.isInsert;
            Boolean isUpdate = Trigger.isUpdate && existingRecords != null && existingRecords.get(caseVar.Id) != null && aos_Utils.sObjects.isSomeFieldChanged(
                    caseVar,
                    existingRecords.get(caseVar.Id),
                    new List<SObjectField>{
                            Case.Subject,
                            Case.Status,
                            Case.Description,
                            Case.Priority,
                            Case.Animal_Report_Summary__c
                    });

            if ((isInsert || isUpdate) && crueltyRecordTypeId.equalsIgnoreCase(caseVar.RecordTypeId)) {
                animalos__Job__c jobVar = (animalos__Job__c) jobsByCaseIds.get(caseVar.Id);
                if (jobVar != null) {
                    jobVar.animalos__Subject__c = caseVar.Subject;
//                    jobVar.Status__c = caseVar.Status;
                    jobVar.animalos__Description__c = caseVar.Description;
                    jobVar.animalos__Animal_Report_Summary__c = caseVar.Animal_Report_Summary__c;
                    if (jobVar.aos_Sync_with_Case_Priority__c) {
                        jobVar.animalos__Priority__c = caseVar.Priority;
                    }
                    if (!System.Test.isRunningTest() && (jobVar.OwnerId != UserInfo.getUserId())) {
                        this.addFeedItem(jobVar.OwnerId, jobVar.Id, this.generateMessage(jobVar));
                    }
                    jobsToUpdate.add(jobVar);
                }


            }
        }

        TDTM_aos_JobSetSyncWithCasePriority.triggeredFromRecordPage = false;
        if (!jobsToUpdate.isEmpty()) {
            update jobsToUpdate;
        }

        for (Case caseVar : records) {
            Boolean isInsert = Trigger.isInsert;
            Boolean isUpdate = Trigger.isUpdate && existingRecords != null && existingRecords.get(caseVar.Id) != null && aos_Utils.sObjects.isSomeFieldChanged(
                    caseVar,
                    existingRecords.get(caseVar.Id),
                    new List<SObjectField>{
                            Case.Subject,
                            Case.Status,
                            Case.Description,
                            Case.Priority,
                            Case.Animal_Report_Summary__c
                    });

            if ((isInsert || isUpdate) && crueltyRecordTypeId.equalsIgnoreCase(caseVar.RecordTypeId) &&
                    TDTM_aos_CaseSetSendEmail.SEND_EMAIL_BY_CASE_ID.get(caseVar.Id) != null &&
                    TDTM_aos_CaseSetSendEmail.SEND_EMAIL_BY_CASE_ID.get(caseVar.Id)) {

                animalos__Job__c jobVar = (animalos__Job__c) jobsByCaseIds.get(caseVar.Id);
                if (jobVar != null) {
                    List<Map<String, Object>> contentAttachments = new List<Map<String, Object>>{
                            new Map<String, Object>{
                                    'proc' => 'aos_JobSummaryQA',
                                    'fileName' => 'Job Summary.pdf',
                                    'jobId' => jobVar.Id
                            }
                    };

                    User userVar = usersById.get(jobVar.OwnerId);

                    if (userVar.Id == UserInfo.getUserId()) {
                        continue;
                    }

                    if (userVar != null && jobUpdateEmailTemplate != null) {
                        aos_Async_Process__c asyncProc = new aos_SendEmailProc.EmailAsyncProcess(
                                jobUpdateEmailTemplate.DeveloperName,
                                userVar,
                                jobVar.Id
                        ).setOrgWideEmail('inspectors@rspcansw.org.au')
                                .setContentAttachments(contentAttachments)
                                .toAsyncProcess();
                        asyncProcess.add(asyncProc);
                    }
                }
            }
        }

        if (!asyncProcess.isEmpty()) {
            asyncProcess.enqueue();
        }

        if (!this.batchInputs.isEmpty()) {
            ConnectApi.ChatterFeeds.postFeedElementBatch(null, batchInputs);
        }
    }

    private void addFeedItem(String userToMentionId, String parentId, String message) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        mentionSegmentInput.id = userToMentionId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        textSegmentInput.text = message;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.subjectId = parentId;

        this.batchInputs.add(new ConnectApi.BatchInput(feedItemInput));
    }

    private String generateMessage(sObject record) {
        animalos__Job__c job = (animalos__Job__c) record;
        String message = '\n';
        message += job.Name + ' job has been updated. The following details have been updated:\n\n';
        message += 'Subject:\n' + job.animalos__Subject__c + '\n\n';
        message += 'Description:\n' + job.animalos__Description__c + '\n\n';
        message += 'Animal Report Summary:\n' + job.animalos__Animal_Report_Summary__c + '\n\n';
        message += 'Priority:\n' + job.animalos__Priority__c;
        return message;
    }
}