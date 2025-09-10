public class OneDriveCopyFilesToFolderProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private Set<String> recordsQueryFields = new Set<String>{
        'One_Drive_Folder_Name__c'
    };

    private Set<String> oneDriveFilesQueryFields = new Set<String>{
        'Id'
    };

    private List<OneDrive_File__c> files;
    private Boolean copyAllFiles = false;
    private Id fromRecordId;
    private String fromLookupFieldName;
    private Id toRecordId;
    private String toLookupFieldName;
    private Map<String, String> driveNames = new Map<String, String>();

    private void doSubmit() {
        this.files = this.request.getMapper().mapToListSObjects('files', OneDrive_File__c.SObjectType);
        this.copyAllFiles = this.request.getBoolean('copyAllFiles') == null ? false : this.request.getBoolean('copyAllFiles');
        this.fromRecordId = this.request.getRequiredString('fromRecordId');
        this.fromLookupFieldName = this.request.getString('fromLookupFieldName');
        this.toRecordId = this.request.getRequiredString('toRecordId');
        this.toLookupFieldName = this.request.getString('toLookupFieldName');

        for (OnedriveSetting__mdt onedriveSetting : OnedriveSetting__mdt.getAll().values()) {
            this.driveNames.put(onedriveSetting.RecordApiName__c, onedriveSetting.DriveName__c);
        }

        fflib_QueryFactory fromQueryFactory = new fflib_QueryFactory(fromRecordId.getSobjectType());
        fromQueryFactory.selectFields(this.recordsQueryFields);
        fromQueryFactory.setCondition('Id = :fromRecordId');
        SObject fromRecord = Database.query(fromQueryFactory.toSOQL());

        fflib_QueryFactory toQueryFactory = new fflib_QueryFactory(toRecordId.getSobjectType());
        toQueryFactory.selectFields(this.recordsQueryFields);
        toQueryFactory.setCondition('Id = :toRecordId');
        SObject toRecord = Database.query(toQueryFactory.toSOQL());

        Map<String, String> drives = OneDriveUtils.getDrives();
        String fromDriveId = drives.get(driveNames.get(fromRecordId.getSobjectType().getDescribe().getName()));
        String toDriveId = drives.get(driveNames.get(toRecordId.getSobjectType().getDescribe().getName()));

        String toFolderId = OneDriveUtils.checkIsExistFolder(toDriveId, String.valueOf(toRecord.get('One_Drive_Folder_Name__c')));
        if (toFolderId == null) {
            toFolderId = OneDriveUtils.createFolder(toDriveId, String.valueOf(toRecord.get('One_Drive_Folder_Name__c')));
        }

        if (this.copyAllFiles) {
            List<OneDrive_File__c> fromRecordOneDriveFiles;
            if (!String.isBlank(this.toLookupFieldName) && !String.isBlank(this.fromLookupFieldName)) {
                this.oneDriveFilesQueryFields.addAll(new List<String>{
                    fromLookupFieldName, toLookupFieldName
                });
                fflib_QueryFactory fromRecordFilesQuery = new fflib_QueryFactory(OneDrive_File__c.SObjectType);
                fromRecordFilesQuery.selectFields(this.oneDriveFilesQueryFields);
                fromRecordFilesQuery.setCondition(fromLookupFieldName + ' = :fromRecordId');
                fromRecordOneDriveFiles = Database.query(fromRecordFilesQuery.toSOQL());
            }
            List<Object> fromRecordFolderFiles = OneDriveUtils.getItems(fromDriveId, String.valueOf(fromRecord.get('One_Drive_Folder_Name__c')));

            if (fromRecordFolderFiles != null) {
                for (Object fileMap : fromRecordFolderFiles) {
                    String fileId = String.valueOf(((Map<String, Object>) fileMap).get('id'));
                    String fileName = String.valueOf(((Map<String, Object>) fileMap).get('name'));
                    OneDriveUtils.copyFile(fromDriveId, fileId, toDriveId, toFolderId, fileName);
                }

                if (!String.isBlank(this.toLookupFieldName) && !String.isBlank(this.fromLookupFieldName)) {
                    for (OneDrive_File__c oneDriveFile : fromRecordOneDriveFiles) {
                        oneDriveFile.put(toLookupFieldName, toRecordId);
                    }

                    update fromRecordOneDriveFiles;
                }
            }
        } else {
            if (!files.isEmpty()) {
                for (OneDrive_File__c oneDriveFile : files) {
                    OneDriveUtils.copyFile(fromDriveId, oneDriveFile.File_ID__c, toDriveId, toFolderId, oneDriveFile.Name);
                    if (!String.isBlank(this.toLookupFieldName)) {
                        oneDriveFile.put(toLookupFieldName, toRecordId);
                    }
                }
                if (!String.isBlank(this.toLookupFieldName)) {
                    update files;
                }
            } else {
                throw new vertic_Structs.CommonException('Error: no files');
            }
        }
    }
}