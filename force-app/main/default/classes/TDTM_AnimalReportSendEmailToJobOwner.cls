global class TDTM_AnimalReportSendEmailToJobOwner extends animalos.TDTM.Handler implements animalos.TDTM.AfterUpdate, animalos.TDTM.AfterInsert {
    private List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

    public void onAfterInsert(List<SObject> records) {
        this.sendEmailToJobOwner(records, null);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.sendEmailToJobOwner(records, oldMap);
    }


    private void sendEmailToJobOwner(List<SObject> records, Map<Id, sObject> existingRecords) {
        Set<Id> jobIds = vertic_Utils.sObjects.getIdFieldValues(
                records,
                animalos__Animal_Report__c.animalos__Job__c
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
                WHERE DeveloperName = 'AOS_Animal_Report_Created_Updated_Notification_1737389360529'
        ]);

        vertic_AsyncProcess asyncProcess = new vertic_AsyncProcess();

        for (animalos__Animal_Report__c animalReportVar : (List<animalos__Animal_Report__c>) records) {
            animalos__Job__c job = jobsByIds.get(animalReportVar.animalos__Job__c);

            if (job == null) {
                continue;
            }

            Boolean isCreated = Trigger.isInsert && existingRecords == null;
            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingRecords.get(animalReportVar.Id) != null;

            if (isCreated || (isUpdated && TDTM_AnimalReportSetSendEmail.SEND_EMAIL_BY_ANIMAL_REPORT_ID.get(animalReportVar.Id))) {
                User userVar = usersByIds.get(job.OwnerId);

                if (userVar.Id == UserInfo.getUserId()) {
                    continue;
                }

                if (emailTemplateVar != null) {
                    aos_Async_Process__c asyncProc = new vertic_SendEmailProc.EmailAsyncProcess(
                            emailTemplateVar.DeveloperName,
                            userVar,
                            animalReportVar.Id
                    ).setOrgWideEmail('inspectors@rspcansw.org.au')
                            .toAsyncProcess();
                    asyncProc.aos_Group_Key__c = 'ANIMAL_REPORT-' + job.Id;
                    asyncProcess.add(asyncProc);
                }

                if (!System.Test.isRunningTest() && isCreated) {
                    this.addFeedItem(job.OwnerId, job.Id, this.generateMessage(job));
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

        textSegmentInput.text = message;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.subjectId = parentId;

        this.batchInputs.add(new ConnectApi.BatchInput(feedItemInput));
    }

    private String generateMessage(sObject record) {
        animalos__Job__c job = (animalos__Job__c) record;
        String message = '\n';
        message += 'Animal Report has been created on ' + job.Name + ' job.';
        return message;
    }
}