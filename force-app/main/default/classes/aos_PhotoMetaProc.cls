global without sharing class aos_PhotoMetaProc extends aos_AbstractProcessor {

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

    public override aos_Response process(aos_Request request) {
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
        Boolean isOneDriveFolderFieldExists = sObjectTypeName.getDescribe().fields.getMap().keySet().contains('aos_one_drive_folder_name__c');

        if (!isOneDriveFolderFieldExists) {
            throw new aos_Structs.CommonException('Error: Current object does not contain the aos_One_Drive_Folder_Name__c field');
        }

        Boolean isAnimal = sObjectTypeName == animalos__Animal__c.SObjectType;

        String currentRecordQuery = 'SELECT Id, Name, aos_One_Drive_Folder_Name__c ';
        currentRecordQuery += isAnimal ? ', animalos__Animal_Name__c' : '';
        currentRecordQuery += ' FROM ' + sObjectTypeName.getDescribe().getName() + ' WHERE Id = \'' + this.recordId + '\'' ;

        this.record = (sObject) aos_Utils.arrays.firstOrException(Database.query(currentRecordQuery), 'Record not found by ID: ' + this.recordId);

        String initials;
        if (isAnimal && record.get('animalos__Animal_Name__c') != null && record.get('animalos__Animal_Name__c').toString().length() > 1) {
            initials = record.get('animalos__Animal_Name__c').toString().substring(0, 2).toUpperCase();
        } else {
            initials = record.get('Name').toString().substring(0, 2).toUpperCase();
        }

        this.response.put('initials', initials);
        this.response.put('name', record.get('Name'));
    }

    private void getLocalPhoto() {

        String photoTitle = 'Profile Photo - ' + record.get('Name');

        ContentDocumentLink photoDocumentLink = (ContentDocumentLink) aos_Utils.arrays.firstOrNull([
            SELECT ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :this.recordId
            AND ContentDocument.Title = :photoTitle
        ]);
        if (photoDocumentLink != null) {
            ContentDistribution photoDistribution = (ContentDistribution) aos_Utils.arrays.firstOrNull([
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
        String sObjectTypeNameString = recordId.getSobjectType() == animalos__Animal__c.SObjectType ? 'aos_Animal__c' : aos_OneDriveCreateFileSObjectProc.getLookupFieldName(sObjectTypeName);

        String searchBy = recordId.getSobjectType() == animalos__Animal__c.SObjectType ? 'aos_Profile_Image__c' : 'aos_Is_Primary__c';

        String oneDriveFileQuery = 'SELECT Id, aos_File_Link__c, Name, aos_File_ID__c FROM aos_OneDrive_File__c WHERE ' + sobjectTypeNameString.remove('__c') + '__c = \'' + this.recordId + '\' AND ' + searchBy + ' = true AND aos_Is_Deleted__c = FALSE';

        aos_OneDrive_File__c oneDriveFile = (aos_OneDrive_File__c) aos_Utils.arrays.firstOrNull(Database.query(oneDriveFileQuery));

        Map<String, String> drivesMap = aos_OneDriveUtils.getDrives();
        if (drivesMap.get(this.driveName) == null) {
            throw new aos_Structs.CommonException(this.driveName + ' drive was not found');
        }

        String postfix = folderNamePostfix == null ? '' : '-' + folderNamePostfix;
        List<Object> items = aos_OneDriveUtils.getItems(drivesMap.get(this.driveName), this.record.get('aos_One_Drive_Folder_Name__c') + postfix);

        this.response.put('driveId', drivesMap.get(this.driveName));

        if (items != null && !items.isEmpty()) {
            if (oneDriveFile != null) {
                this.response.put('oneDriveFileId', oneDriveFile.Id);
                for (Object item : items) {
                    Map<String, Object> itemMap = (Map<String, Object>) item;
                    if (oneDriveFile.aos_File_ID__c == (String) itemMap.get('id')) {
                        String publicLink = aos_OneDriveUtils.getFileThumbnail(drivesMap.get(this.driveName), (String) itemMap.get('id'));
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
//                String publicLink = aos_OneDriveUtils.getFileThumbnail(drivesMap.get(this.driveName), lastUploadedItemId);
//                this.response.put('photoUrl', publicLink);
//            }
        } else {
            if (oneDriveFile != null) {
                this.response.put('oneDriveFileId', oneDriveFile.Id);
                String publicLink = aos_OneDriveUtils.getFileThumbnail(drivesMap.get(this.driveName), (String) oneDriveFile.aos_File_ID__c);
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
    // aos_request
    // aos_response

}