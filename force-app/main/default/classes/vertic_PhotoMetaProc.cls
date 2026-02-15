global without sharing class vertic_PhotoMetaProc extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              ATTRIBUTES
     * ==============================================================================================================
     */

    private Id recordId;
    private Boolean isOneDriveLoad;
    private String driveName;
    private String folderNamePostfix;
    private sObject record;


    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.init();

        if (this.isOneDriveLoad == true) {
            this.getOneDrivePhoto();
        } else {
            this.getLocalPhoto();
        }

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void init() {
        this.recordId = (Id) this.request.getRequiredString('recordId');
        this.isOneDriveLoad = this.request.getBoolean('loadOneDrive');
        if (this.isOneDriveLoad == true) {
            this.driveName = this.request.getRequiredString('driveName');
            this.folderNamePostfix = this.request.getString('folderNamePostfix');
        }

        SObjectType sObjectTypeName = recordId.getSobjectType();
        Boolean isOneDriveFolderFieldExists = sObjectTypeName.getDescribe().fields.getMap().keySet().contains('one_drive_folder_name__c');

        if (!isOneDriveFolderFieldExists) {
            throw new vertic_Structs.CommonException('Error: Current object does not contain the One_Drive_Folder_Name__c field');
        }

        Boolean isAnimal = sObjectTypeName == animalos__Animal__c.SObjectType;

        String currentRecordQuery = 'SELECT Id, Name, One_Drive_Folder_Name__c ';
        currentRecordQuery += isAnimal ? ', animalos__Animal_Name__c' : '';
        currentRecordQuery += ' FROM ' + sObjectTypeName.getDescribe().getName() + ' WHERE Id = \'' + this.recordId + '\'' ;

        this.record = (sObject) vertic_Utils.arrays.firstOrException(Database.query(currentRecordQuery), 'Record not found by ID: ' + this.recordId);

        this.response.put('initials', isAnimal && record.get('animalos__Animal_Name__c') != null ? record.get('animalos__Animal_Name__c').toString().substring(0, 2).toUpperCase() : record.get('Name').toString().substring(0, 2).toUpperCase());
        this.response.put('name', record.get('Name'));
    }

    private void getLocalPhoto() {

        String photoTitle = 'Profile Photo - ' + record.get('Name');

        ContentDocumentLink photoDocumentLink = (ContentDocumentLink) vertic_Utils.arrays.firstOrNull([
            SELECT ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :this.recordId
            AND ContentDocument.Title = :photoTitle
        ]);
        if (photoDocumentLink != null) {
            ContentDistribution photoDistribution = (ContentDistribution) vertic_Utils.arrays.firstOrNull([
                SELECT ContentDownloadUrl
                FROM ContentDistribution
                WHERE ContentVersionId = :photoDocumentLink.ContentDocument.LatestPublishedVersionId
                OR ContentDocumentId = :photoDocumentLink.ContentDocumentId
            ]);
            if (photoDistribution != null) {
                this.response.put('photoUrl', photoDistribution.ContentDownloadUrl);
            }
        }
    }

    private void getOneDrivePhoto() {
        SObjectType sObjectTypeName = recordId.getSobjectType();
        String sObjectTypeNameString = recordId.getSobjectType() == animalos__Animal__c.SObjectType ? 'animalos_Animal__c' : OneDriveCreateFileSObjectProc.getLookupFieldName(sObjectTypeName);

        String searchBy = recordId.getSobjectType() == animalos__Animal__c.SObjectType ? 'Profile_Image__c' : 'Is_Primary__c';

        String oneDriveFileQuery = 'SELECT Id, File_Link__c, Name, File_ID__c FROM OneDrive_File__c WHERE ' + sobjectTypeNameString.remove('__c') + '__c = \'' + this.recordId + '\' AND ' + searchBy + ' = true AND Is_Deleted__c = FALSE';

        aos_OneDrive_File__c oneDriveFile = (aos_OneDrive_File__c) vertic_Utils.arrays.firstOrNull(Database.query(oneDriveFileQuery));

        Map<String, String> drivesMap = OneDriveUtils.getDrives();
        if (drivesMap.get(this.driveName) == null) {
            throw new vertic_Structs.CommonException(this.driveName + ' drive was not found');
        }

        String postfix = folderNamePostfix == null ? '' : '-' + folderNamePostfix;
        List<Object> items = OneDriveUtils.getItems(drivesMap.get(this.driveName), this.record.get('One_Drive_Folder_Name__c') + postfix);

        this.response.put('driveId', drivesMap.get(this.driveName));

        if (items != null && !items.isEmpty()) {
            if (oneDriveFile != null) {
                this.response.put('oneDriveFileId', oneDriveFile.Id);
                for (Object item : items) {
                    Map<String, Object> itemMap = (Map<String, Object>) item;
                    if (oneDriveFile.aos_File_ID__c == (String) itemMap.get('id')) {
                        String publicLink = OneDriveUtils.getFileThumbnail(drivesMap.get(this.driveName), (String) itemMap.get('id'));
                        this.response.put('fileName', itemMap.get('name'));
                        this.response.put('oneDriveId', oneDriveFile.aos_File_ID__c);
                        this.response.put('photoUrl', publicLink);
                        break;
                    }
                }
            }
//            else {
//                Datetime lastModifiedDate;
//                String lastUploadedItemId;
//                for (Object item : items) {
//                    Map<String, Object> itemMap = (Map<String, Object>) item;
//                    String gmtDateTime = (String) itemMap.get('lastModifiedDateTime');
//                    String gmtDateTimeFormatted = gmtDateTime.replace('T', ' ');
//
//                    if (lastModifiedDate == null || lastModifiedDate < DateTime.valueOfGmt(gmtDateTimeFormatted)) {
//                        lastModifiedDate = DateTime.valueOfGmt(gmtDateTimeFormatted);
//                        lastUploadedItemId = (String) itemMap.get('id');
//                    }
//                }
//                String publicLink = OneDriveUtils.getFileThumbnail(drivesMap.get(this.driveName), lastUploadedItemId);
//                this.response.put('photoUrl', publicLink);
//            }
        } else {
            if (oneDriveFile != null) {
                this.response.put('oneDriveFileId', oneDriveFile.Id);
                String publicLink = OneDriveUtils.getFileThumbnail(drivesMap.get(this.driveName), (String) oneDriveFile.aos_File_ID__c);
                if (String.isNotBlank(publicLink)) {
                    this.response.put('photoUrl', publicLink);
                } else {
                    this.response.put('photoUrl', null);
                }
                this.response.put('fileName', oneDriveFile.Name);
                this.response.put('oneDriveId', oneDriveFile.aos_File_ID__c);
            } else {
                this.response.put('photoUrl', null);
            }
        }


    }


    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties:
    // vertic_request
    // vertic_response

}