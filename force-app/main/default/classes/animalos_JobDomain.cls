public with sharing class animalos_JobDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {
    private List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

    public animalos_JobDomain(List<sObject> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new animalos_JobDomain(sObjectList);
        }
    }

    public override void onAfterInsert() {
        List<animalos__Job__c> rescueJobsToProceed = new List<animalos__Job__c>();
        List<animalos__Job__c> inspectorateJobsToProceed = new List<animalos__Job__c>();

        Map<Id, RecordTypeInfo> recordTypeInfosByIds = animalos__Job__c.SObjectType.getDescribe().getRecordTypeInfosById();

        String inspectorateRecordTypeName = 'Inspectorate';
        String rescueRecordTypeName = 'Rescue';

        for (animalos__Job__c jobVar : (List<animalos__Job__c>) Trigger.new) {
            if(recordTypeInfosByIds.containsKey(jobVar.RecordTypeId)) {
                inspectorateRecordTypeName = recordTypeInfosByIds.get(jobVar.RecordTypeId).getName();
                rescueRecordTypeName = recordTypeInfosByIds.get(jobVar.RecordTypeId).getName();
            }

            if(
                    'Inspectorate'.equals(inspectorateRecordTypeName)
                            && 'Critical'.equals(jobVar.animalos__Priority__c)
            ) {
                inspectorateJobsToProceed.add(jobVar);
            } else if(
                    'Rescue'.equals(rescueRecordTypeName)
                            && 'Critical'.equals(jobVar.animalos__Priority__c)
            ){
                rescueJobsToProceed.add(jobVar);
            }
        }

        if(inspectorateJobsToProceed.size() > 0){
            this.sendChatterMessageToInspectorateGroup(inspectorateJobsToProceed);
        }

        if(rescueJobsToProceed.size() > 0){
            this.sendChatterMessageToRescueGroup(rescueJobsToProceed);
        }
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        Map<Id, animalos__Job__c> existingJobs = (Map<Id, animalos__Job__c>) existingRecords;
        List<animalos__Job__c> rescueJobsToProceed = new List<animalos__Job__c>();
        List<animalos__Job__c> inspectorateJobsToProceed = new List<animalos__Job__c>();

        Map<Id, RecordTypeInfo> recordTypeInfosByIds = animalos__Job__c.SObjectType.getDescribe().getRecordTypeInfosById();

        String inspectorateRecordTypeName = 'Inspectorate';
        String rescueRecordTypeName = 'Rescue';

        for (animalos__Job__c jobVar : (List<animalos__Job__c>) Trigger.new) {
            if(recordTypeInfosByIds.containsKey(jobVar.RecordTypeId)) {
                inspectorateRecordTypeName = recordTypeInfosByIds.get(jobVar.RecordTypeId).getName();
                rescueRecordTypeName = recordTypeInfosByIds.get(jobVar.RecordTypeId).getName();
            }

            if(
                    'Inspectorate'.equals(inspectorateRecordTypeName)
                            && (
                                jobVar.animalos__Priority__c != existingJobs.get(jobVar.Id).animalos__Priority__c)
                                    && 'Critical'.equals(jobVar.animalos__Priority__c
                                )
            ) {
                inspectorateJobsToProceed.add(jobVar);
            } else if(
                    'Rescue'.equals(rescueRecordTypeName)
                            && (
                            jobVar.animalos__Priority__c != existingJobs.get(jobVar.Id).animalos__Priority__c)
                            && 'Critical'.equals(jobVar.animalos__Priority__c
                    )
            ){
                rescueJobsToProceed.add(jobVar);
            }
        }

        if(inspectorateJobsToProceed.size() > 0){
            this.sendChatterMessageToInspectorateGroup(inspectorateJobsToProceed);
        }

        if(rescueJobsToProceed.size() > 0){
            this.sendChatterMessageToRescueGroup(rescueJobsToProceed);
        }
    }

    private void sendChatterMessageToRescueGroup(List<animalos__Job__c> jobs){
        String rescueGroupName = 'Rescue';

        CollaborationGroup rescueGroup = [
                SELECT Id, Name
                FROM CollaborationGroup
                WHERE Name = :rescueGroupName AND CollaborationType = 'Private'
                LIMIT 1
        ];

        if (rescueGroup == null) {
            throw new IllegalArgumentException('Private Chatter Group not found: ' + rescueGroupName);
        }

        for(animalos__Job__c jobVar : jobs){
            String titleText = 'Critical Job: ' + jobVar.Name;
            String bodyText = 'Critical Job: ' + jobVar.Name + ' requires attention!';

            if (!System.Test.isRunningTest()) {
                this.addFeedItem(rescueGroup.Id, bodyText);
            }
        }

        if (!this.batchInputs.isEmpty()) {
            ConnectApi.ChatterFeeds.postFeedElementBatch(null, batchInputs);
        }
    }

    private void sendChatterMessageToInspectorateGroup(List<animalos__Job__c> jobs){
        String inspectorateGroupName = 'Inspectorate';

        CollaborationGroup inspectorateGroup = [
                SELECT Id, Name
                FROM CollaborationGroup
                WHERE Name = :inspectorateGroupName AND CollaborationType = 'Private'
                LIMIT 1
        ];

        if (inspectorateGroupName == null) {
            throw new IllegalArgumentException('Private Chatter Group not found: ' + inspectorateGroupName);
        }

        for(animalos__Job__c jobVar : jobs){
            String titleText = 'Critical Job: ' + jobVar.Name;
            String bodyText = 'Critical Job: ' + jobVar.Name + ' requires attention!';

            if (!System.Test.isRunningTest()) {
                this.addFeedItem(inspectorateGroup.Id, bodyText);
            }
        }

        if (!this.batchInputs.isEmpty()) {
            ConnectApi.ChatterFeeds.postFeedElementBatch(null, batchInputs);
        }
    }

    private void addFeedItem(String parentId, String message) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        textSegmentInput.text = message;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.subjectId = parentId;


        this.batchInputs.add(new ConnectApi.BatchInput(feedItemInput));
    }

//    private void sendChatterNotifications(List<animalos__Job__c> jobs){
//        Set<String> usernamesToReceiveNotifications = new Set<String>();
//
//        List<Critical_Jobs_Chatter_Notification__mdt> criticalJobsChatterNotifications = [
//                SELECT Id, Username__c
//                FROM Critical_Jobs_Chatter_Notification__mdt
//        ];
//
//        if(criticalJobsChatterNotifications.size() > 0){
//            for(Critical_Jobs_Chatter_Notification__mdt cjcnVar : criticalJobsChatterNotifications){
//                usernamesToReceiveNotifications.add(cjcnVar.Username__c);
//            }
//        }
//
//        Set<Id> userIdsToReceiveNotifications = (new Map<Id,SObject>([SELECT Id FROM User WHERE Name IN :usernamesToReceiveNotifications])).keySet();
//
//        Set<String> userIdsStr = (Set<String>)JSON.deserialize(JSON.serialize(userIdsToReceiveNotifications), Set<String>.class);
//
//        if(userIdsToReceiveNotifications.size() > 0){
//            CustomNotificationType notificationType = [
//                    SELECT
//                            Id,
//                            DeveloperName
//                    FROM CustomNotificationType
//                    WHERE DeveloperName = 'Critical_Job_Notification'
//            ];
//
//            Id userId = UserInfo.getUserId();
//
//            for(animalos__Job__c jobVar : jobs){
//                String titleText = 'Critical Job: ' + jobVar.Name;
//                String bodyText = 'Critical Job: ' + jobVar.Name + ' requires attention!';
//
//                Messaging.CustomNotification notification = new Messaging.CustomNotification();
//
//                notification.setTitle(titleText);
//                notification.setBody(bodyText);
//
//                notification.setNotificationTypeId(notificationType.Id);
//                notification.setTargetId(jobVar.Id);
//                notification.setSenderId(userId);
//
//                notification.send(userIdsStr);
//            }
//        }
//    }
}