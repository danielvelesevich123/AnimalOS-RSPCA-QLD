global class TDTM_JobNoteSendEmailToJobOwner extends animalos.TDTM.Handler implements animalos.TDTM.AfterUpdate, animalos.TDTM.AfterInsert {
    private List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

    public void onAfterInsert(List<SObject> records) {
        this.sendEmailToJobOwner(records, null);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.sendEmailToJobOwner(records, oldMap);
    }


    private void sendEmailToJobOwner(List<sObject> records, Map<Id, sObject> existingRecords) {

        Set<Id> jobIds = vertic_Utils.sObjects.getIdFieldValues(
                records,
                animalos__Job_Note__c.animalos__Job__c
        );

        Map<Id, animalos__Job__c> jobsByIds = new Map<Id, animalos__Job__c>([
                SELECT Id, Name, OwnerId
                FROM animalos__Job__c
                WHERE Id IN :jobIds
        ]);

        if (jobsByIds.isEmpty()) {
            return;
        }

        Set<Id> ownerIds = vertic_Utils.sObjects.getIdFieldValues(jobsByIds.values(), animalos__Job__c.OwnerId);

        Map<Id, User> usersByIds = new Map<Id, User>([
                SELECT Id, Email
                FROM User
                WHERE Id IN :ownerIds
        ]);

        if (usersByIds.isEmpty()) {
            return;
        }

        EmailTemplate emailTemplateVar = (EmailTemplate) vertic_Utils.arrays.firstOrNull([
                SELECT DeveloperName, Name
                FROM EmailTemplate
                WHERE DeveloperName = 'AOS_Job_Note_Added_Notification_1732546602284'
        ]);

        vertic_AsyncProcess asyncProcess = new vertic_AsyncProcess();

        for (animalos__Job_Note__c jobNote : (List<animalos__Job_Note__c>) records) {
            animalos__Job__c job = (animalos__Job__c) jobsByIds.get(jobNote.animalos__Job__c);

            if (job == null) {
                continue;
            }

            Boolean isCreated = Trigger.isInsert && existingRecords == null;
            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingRecords.get(jobNote.Id) != null;

            if (isCreated || (isUpdated && TDTM_JobNoteSetSendEmail.SEND_EMAIL_BY_JOB_NOTE_ID.get(jobNote.Id))) {
                User userVar = usersByIds.get(job.OwnerId);

                if (userVar.Id == UserInfo.getUserId()) {
                    continue;
                }

                if (emailTemplateVar != null) {
                    List<Map<String, Object>> contentAttachments = new List<Map<String, Object>>{
                            new Map<String, Object>{
                                    'proc' => 'AOS_JobSummaryQA',
                                    'fileName' => 'Job Summary.pdf',
                                    'jobId' => job.Id
                            }
                    };

                    Vertic_Async_Process__c asyncProc = new vertic_SendEmailProc.EmailAsyncProcess(
                            emailTemplateVar.DeveloperName,
                            userVar,
                            jobNote.Id
                    )
                            .setOrgWideEmail('inspectors@rspcansw.org.au')
                            .setSaveAsActivity(false)
                            .setContentAttachments(contentAttachments)
                            .toAsyncProcess();

                    asyncProc.Group_Key__c = 'JOB_NOTE-' + job.Id;
                    asyncProcess.add(asyncProc);
                }

                if (!System.Test.isRunningTest() && isCreated) {
                    this.addFeedItem(job.OwnerId, job.Id, this.generateMessage(jobNote, job));
                }
            }
        }

        asyncProcess.enqueue();


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

        textSegmentInput.text = ' ' + message;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = parentId;

        this.batchInputs.add(new ConnectApi.BatchInput(feedItemInput));
    }

    private String generateMessage(animalos__Job_Note__c jobNote, animalos__Job__c job) {
        String message = '\n';
        message += job.Name + ' job has been updated with a new Job Note. The note details:\n';
        message += 'Subject: ' + jobNote.animalos__Subject__c + '\n';
        message += 'Content:\n' + jobNote.animalos__Content__c + '\n';
        return message;
    }
}