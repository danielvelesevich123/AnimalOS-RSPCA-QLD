public without sharing class aos_PhotoSubmitProc extends aos_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              ATTRIBUTES
     * ==============================================================================================================
     */

    private Id recordId;
    private Boolean isOneDriveLoad;
    private Boolean isCreateAttachment;
    private String driveName;
    private String folderNamePostfix;
    private Blob contentData;
    private String base64Data;
    private String base64DataDecoded;
    private SObject record;

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.init();

        if (isOneDriveLoad == true) {
            this.uploadOneDrivePhoto();
            if (!'Guest'.equalsIgnoreCase(UserInfo.getUserType())) {
                this.saveLocalPhoto();
            }
        }

        if (isCreateAttachment == true) {
            this.createAttachment();
        }

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */
    private void init() {
        this.recordId = this.request.getRequiredString('recordId');
        this.isOneDriveLoad = this.request.getBoolean('loadOneDrive') == true;
        this.isCreateAttachment = this.request.getBoolean('createAttachment') == true;
        this.base64DataDecoded = EncodingUtil.urlDecode(this.request.getString('base64Data'), 'UTF-8');
        this.base64Data = this.request.getString('base64Data');
        this.contentData = EncodingUtil.base64Decode(base64DataDecoded);

        if (this.isOneDriveLoad == true) {
            this.driveName = this.request.getRequiredString('driveName');
            this.folderNamePostfix = this.request.getString('folderNamePostfix');
        }

        SObjectType sObjectTypeName = recordId.getSobjectType();
        Boolean isOneDriveFolderFieldExists = sObjectTypeName.getDescribe().fields.getMap().keySet().contains('aos_one_drive_folder_name__c');

        if (!isOneDriveFolderFieldExists) {
            throw new aos_Structs.CommonException('Error: Current object does not contain the aos_One_Drive_Folder_Name__c field');
        }

        String currentRecordQuery = 'SELECT Id, Name, aos_One_Drive_Folder_Name__c FROM ' + sObjectTypeName.getDescribe().getName() + ' WHERE Id = \'' + this.recordId + '\'' ;

        this.record = (sObject) aos_Utils.arrays.firstOrException(Database.query(currentRecordQuery), 'Record not found by ID: ' + this.recordId);
    }

    private void saveLocalPhoto() {
        String photoTitle = 'Profile Photo - ' + record.get('Name');

        ContentVersion photoVersion = new ContentVersion(
                Title = photoTitle,
                VersionData = contentData,
                PathOnClient = this.request.getString('fileName')
        );

        ContentDocumentLink photoDocumentLink = (ContentDocumentLink) aos_Utils.arrays.firstOrNull([
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :this.recordId
                AND ContentDocument.Title = :photoTitle
        ]);

        if (photoDocumentLink != null) {
            photoVersion.ContentDocumentId = photoDocumentLink.ContentDocumentId;
        } else {
            photoDocumentLink = new ContentDocumentLink(
                    LinkedEntityId = this.recordId,
                    ShareType = Test.isRunningTest() ? 'I' : 'V',
                    Visibility = 'AllUsers'
            );
        }

        insert photoVersion;

        if (photoDocumentLink.ContentDocumentId == null) {
            photoDocumentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :photoVersion.Id].ContentDocumentId;
            insert photoDocumentLink;
        }

        ContentDistribution photoDistribution = (ContentDistribution) aos_Utils.arrays.firstOrNull([SELECT ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId = :photoVersion.Id]);

        if (photoDistribution == null) {
            photoDistribution = new ContentDistribution(
                    Name = photoVersion.Title,
                    ContentVersionId = photoVersion.Id,
                    PreferencesAllowViewInBrowser = true,
                    PreferencesLinkLatestVersion = true,
                    PreferencesNotifyOnVisit = false,
                    PreferencesPasswordRequired = false,
                    PreferencesAllowOriginalDownload = true,
                    PreferencesAllowPDFDownload = true
            );
            insert photoDistribution;

            photoDistribution = (ContentDistribution) aos_Utils.arrays.firstOrException([SELECT ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId = :photoVersion.Id]);
        }

        if (!this.isOneDriveLoad) {
            this.response.put('photoUrl', photoDistribution.ContentDownloadUrl);
        }

    }

    private void uploadOneDrivePhoto() {
        Map<String, String> drivesMap = aos_OneDriveUtils.getDrives();
        String drive = drivesMap.get(this.driveName);
        if (drive == null) {
            throw new aos_Structs.CommonException(this.driveName + ' drive was not found');
        }

        String postfix = folderNamePostfix == null ? '' : '-' + folderNamePostfix;
        //List<Object> items = aos_OneDriveUtils.getItems(drivesMap.get(this.driveName), this.animalVar.aos_One_Drive_Folder_Name__c + postfix);

        String itemId = aos_OneDriveUtils.checkIsExistFolder(drive, this.record.get('aos_One_Drive_Folder_Name__c') + postfix);
        if (itemId == null) {
            itemId = aos_OneDriveUtils.createFolder(drive, this.record.get('aos_One_Drive_Folder_Name__c') + postfix);
        }

        String fileId = aos_OneDriveUtils.uploadSmallFile(drive, itemId, this.request.getString('fileName'), this.base64Data);
        if (fileId != null) {
            String publicLink = aos_OneDriveUtils.getFileThumbnail(drive, fileId);
            this.response.put('photoUrl', publicLink);
        } else {
            this.response.put('photoUrl', null);
        }


        aos_Request request = new aos_Request(new Map<String, Object>{
                'recordId' => recordId,
                'postfix' => folderNamePostfix,
                'driveFiles' => aos_OneDriveUtils.getItems(drive, this.record.get('aos_One_Drive_Folder_Name__c') + postfix)
        });

        aos_OneDriveCreateFileSObjectProc oneDriveCreateFileSObjectProc = new aos_OneDriveCreateFileSObjectProc();
        aos_Response oneDriveCreateFileSObjectProcResponse = oneDriveCreateFileSObjectProc.process(request);

        String uploadedOneDriveFileId = oneDriveCreateFileSObjectProcResponse.getString('uploadedOneDriveFileId');
        if (String.isNotBlank(uploadedOneDriveFileId)) {
            this.response.put('oneDriveFileId', uploadedOneDriveFileId);
        }

        request = new aos_Request(new Map<String, Object>{
                'recordId' => recordId,
                'fileId' => fileId
        });

        this.response.put('oneDriveId', fileId);
        this.response.put('driveId', drive);

        if (recordId.getSobjectType() != animalos__Animal__c.sObjectType) {
            aos_OneDriveSetPrimaryFile oneDriveSetPrimaryFile = new aos_OneDriveSetPrimaryFile();
            oneDriveSetPrimaryFile.process(request);
        } else {
            aos_OneDriveSetProfileImage oneDriveSetProfileImage = new aos_OneDriveSetProfileImage();
            oneDriveSetProfileImage.process(request);
        }

    }

    private void createAttachment() {
        Attachment attachment = new Attachment();
        attachment.Body = contentData;
        attachment.Name = this.request.getString('fileName');
        attachment.ParentId = recordId;
        attachment.ContentType = this.request.getString('contentType');
        insert attachment;

        this.response.put('attachmentId', attachment.Id);
    }
}


/**
 * ==============================================================================================================
 *                                               STRUCTURES
 * ==============================================================================================================
 */

// Proposed Live Templates to override Super properties:
// aos_request
// aos_response