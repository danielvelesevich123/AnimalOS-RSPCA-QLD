public without sharing class OneDriveCreateFileSObjectProc extends vertic_AbstractProcessor {

    private vertic_AsyncProcess asyncProcess = new vertic_AsyncProcess();

    public override vertic_Response process(vertic_Request request) {

        this.request = request;

        this.createOneDriveFileRecords();

        return this.response;

    }

    public void createOneDriveFileRecords() {
        Id recordId = this.request.getRequiredString('recordId');
        String folderName = this.request.getString('folderName');
        String postfix = this.request.getString('postfix');
        String driveName = this.request.getString('driveName');
        List<Object> driveFiles = (List<Object>) request.get('driveFiles');


        SObjectType sObjectTypeName = recordId.getSobjectType();
        String sObjectTypeNameString = recordId.getSobjectType() == animalos__Animal__c.SObjectType ? 'animalos_Animal__c' : OneDriveCreateFileSObjectProc.getLookupFieldName(sObjectTypeName);

        Boolean isOneDriveFolderFieldExists = sObjectTypeName.getDescribe().fields.getMap().keySet().contains('one_drive_folder_name__c');

        if (!isOneDriveFolderFieldExists) {
            throw new vertic_Structs.CommonException('Error: Current object does not contain the One_Drive_Folder_Name__c field');
        }

        String currentRecordQuery = 'SELECT Id, One_Drive_Folder_Name__c FROM ' + sObjectTypeName.getDescribe().getName() + ' WHERE Id = \'' + recordId + '\'';
        SObject record = (SObject) vertic_Utils.arrays.firstOrException(Database.query(currentRecordQuery));

        String oneDriveRecordsQuery = 'SELECT Id, Name, Folder_Name__c, File_ID__c FROM OneDrive_File__c WHERE ' + sobjectTypeNameString.remove('__c') + '__c' + '= \'' + recordId + '\'';

        List<aos_OneDrive_File__c> oneDriveFileRecords = Database.query(oneDriveRecordsQuery);

        Map<String, SObject> oneDriveFileByFileId = new Map<String, SObject>();
        if (!oneDriveFileRecords.isEmpty()) {
            oneDriveFileByFileId = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(
                    oneDriveFileRecords,
                    aos_OneDrive_File__c.aos_File_ID__c
            );
        }
        List<aos_OneDrive_File__c> newFiles = new List<aos_OneDrive_File__c>();
        List<aos_OneDrive_File__c> oneDriveFiles = new List<aos_OneDrive_File__c>();

        Integer uploadedFileIndex;

        for (Object driveFile : driveFiles) {
            Map<String, Object> file = (Map<String, Object>) driveFile;
            String fileId = (String) file.get('id');
            aos_OneDrive_File__c oneDriveFile = (aos_OneDrive_File__c) oneDriveFileByFileId.get(fileId);
            if (oneDriveFile == null) {
                String name = (String) file.get('name');
                if (name.containsIgnoreCase('deleted_') != true) {
                    uploadedFileIndex = driveFiles.indexOf(driveFile);
                    oneDriveFile = new aos_OneDrive_File__c();
                    oneDriveFile.put(sobjectTypeNameString.remove('__c') + '__c', recordId);
                    oneDriveFile.aos_Is_Deleted__c = false;
                    oneDriveFile.Name = name.length() > 80 ? name.substring(0, 77) : name;
                    oneDriveFile.aos_File_Link__c = (String) file.get('@microsoft.graph.downloadUrl');
                    oneDriveFile.aos_Web_URL__c = (String) file.get('webUrl');
                    oneDriveFile.aos_File_ID__c = fileId;
                    oneDriveFile.aos_Folder_Name__c = (String.isNotBlank(folderName) ? folderName : record.get('aos_One_Drive_Folder_Name__c')) + (String.isNotBlank(postfix) ? '-' + postfix : '');
                    if ('Adoption'.equals(driveName)) {
                        oneDriveFile.aos_Is_Public__c = true;
                    }
                    oneDriveFiles.add(oneDriveFile);
                    newFiles.add(oneDriveFile);
                }
            } else {
                uploadedFileIndex = driveFiles.indexOf(driveFile);
                oneDriveFile.aos_Web_URL__c = (String) file.get('webUrl');
                oneDriveFiles.add(oneDriveFile);
            }
        }
        upsert oneDriveFiles;

        this.copyFiles(recordId, newFiles);

        this.response.put('isSuccess', true);
        this.response.put('oneDriveFiles', oneDriveFiles);
        if (!oneDriveFiles.isEmpty() && uploadedFileIndex != null) {
            this.response.put('uploadedOneDriveFileId', oneDriveFiles[uploadedFileIndex].Id);
        }

    }

    public static String getLookupFieldName(SObjectType sObjectTypeName) {
        if (sObjectTypeName == animalos__Animal__c.SObjectType) {
            return 'animalos_Animal__c';
        } else if (sObjectTypeName == animalos__Job__c.SObjectType) {
            return 'animalos_Job__c';
        } else {
            String sobjectTypeNameString = String.valueOf(sObjectTypeName.getDescribe().getLocalName());
            if (sobjectTypeNameString.split('__').size() == 3) {
                sobjectTypeNameString = sobjectTypeNameString.split('__')[1] + '__c';
            }
            if (sobjectTypeNameString.split('__').size() == 1) {
                sobjectTypeNameString = sobjectTypeNameString + '__c';
            }
            Boolean isAccordingLookupExists = aos_OneDrive_File__c.SObjectType.getDescribe().fields.getMap().keySet().contains(sobjectTypeNameString);

            if (isAccordingLookupExists) {
                throw new vertic_Structs.CommonException('Error: OneDrive_File__c does not contain lookup to the current object');
            }
            return sobjectTypeNameString;
        }
    }

    private void copyFiles(Id fromId, List<aos_OneDrive_File__c> files) {
        if (fromId.getSobjectType() == Case.SObjectType && !files.isEmpty()) {
            this.sendNotificationToCaseCreatedByUser(fromId);
            this.copyFilesToJob(fromId, files);
        }
        this.asyncProcess.enqueue();
    }

    private void sendNotificationToCaseCreatedByUser(Id fromId) {
        Case caseVar = (Case) vertic_Utils.arrays.firstOrNull([
                SELECT Id, CreatedById, CreatedBy.Id, CreatedBy.Email
                FROM Case
                WHERE Id = :fromId
        ]);

        if (caseVar == null) {
            return;
        }

        EmailTemplate fileAddedEmailNotification = (EmailTemplate) vertic_Utils.arrays.firstOrNull([
                SELECT DeveloperName, Name
                FROM EmailTemplate
                WHERE DeveloperName = 'AOS_File_Added_to_Case_Notification_1733313799030'
        ]);

        if (fileAddedEmailNotification != null && caseVar.CreatedBy != null) {
            if (caseVar.CreatedById == UserInfo.getUserId()) {
                return;
            }

            aos_Async_Process__c asyncProc = new vertic_SendEmailProc.EmailAsyncProcess(
                    fileAddedEmailNotification.DeveloperName,
                    caseVar.CreatedBy,
                    caseVar.Id
            )
                    .setOrgWideEmail('inspectors@rspcansw.org.au')
                    .toAsyncProcess();
            asyncProc.aos_Allowed_Attempts__c = 3;

            this.asyncProcess.add(asyncProc);
        }
    }

    private void copyFilesToJob(Id fromId, List<aos_OneDrive_File__c> files) {
//        animalos__Job__c job = (animalos__Job__c) vertic_Utils.arrays.firstOrNull([
//                SELECT Id, OwnerId
//                FROM animalos__Job__c
//                WHERE Case__c = :fromId
//                ORDER BY CreatedDate DESC
//                LIMIT 1
//        ]);
//
//        if (job == null) {
//            return;
//        }
//
//        User userVar = (User) vertic_Utils.arrays.firstOrNull([
//                SELECT Id, Email
//                FROM User
//                WHERE Id = :job.OwnerId
//        ]);
//
//        EmailTemplate fileAddedEmailNotification = (EmailTemplate) vertic_Utils.arrays.firstOrNull([
//                SELECT DeveloperName, Name
//                FROM EmailTemplate
//                WHERE DeveloperName = 'AOS_File_Added_Job_Notification_1732550007034'
//        ]);
//
//
//        vertic_Request request = new vertic_Request();
//        request.getMapper().mapFromListSObjects('files', files);
//        request.put('fromRecordId', fromId);
//        request.put('fromLookupFieldName', 'Case__c');
//        request.put('toRecordId', job.Id);
//        request.put('toLookupFieldName', 'animalos_Job__c');
//        aos_Async_Process__c vap = vertic_AsyncProcess.create(OneDriveCopyFilesToFolderProc.class, request.getMap());
//        vap.Group_Key__c = 'COPY_FILE_FROM_CASE_TO_JOB-' + job.Id;
//
//        this.asyncProcess.add(vap);
//
//        if (fileAddedEmailNotification != null && userVar != null) {
//            List<Map<String, Object>> contentAttachments = new List<Map<String, Object>>{
//                    new Map<String, Object>{
//                            'proc' => 'AOS_JobSummaryQA',
//                            'fileName' => 'Job Summary.pdf',
//                            'jobId' => job.Id
//                    }
//            };
//            aos_Async_Process__c asyncProc = new vertic_SendEmailProc.EmailAsyncProcess(
//                    fileAddedEmailNotification.DeveloperName,
//                    userVar,
//                    job.Id
//            )
//                    .setOrgWideEmail('inspectors@rspcansw.org.au')
//                    .setContentAttachments(contentAttachments)
//                    .toAsyncProcess();
//            asyncProc.Allowed_Attempts__c = 3;
//
//            this.asyncProcess.add(asyncProc);
//        }
    }

}