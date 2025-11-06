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
    private Id sourceRecordId;
    private String sourceLookupFieldName;
    private Id targetRecordId;
    private String targetLookupFieldName;
    private Map<String, String> driveNames = new Map<String, String>();
    private String fileOperation;
    private String targetFolderType;
    private String sourceFolderType;

    private void doSubmit() {
        this.files = this.request.getMapper().mapToListSObjects('files', OneDrive_File__c.SObjectType);
        this.copyAllFiles = this.request.getBoolean('copyAllFiles') == null ? false : this.request.getBoolean('copyAllFiles');
        this.sourceRecordId = this.request.getRequiredString('fromRecordId');
        this.sourceLookupFieldName = this.request.getString('fromLookupFieldName');
        this.targetRecordId = this.request.getRequiredString('toRecordId');
        this.targetLookupFieldName = this.request.getString('toLookupFieldName');
        this.fileOperation = String.isBlank(this.request.getString('fileOperation')) ? 'copy' : this.request.getString('fileOperation');
        this.targetFolderType = this.request.getString('targetFolderType');
        this.sourceFolderType = this.request.getString('sourceFolderType');

        for (OnedriveSetting__mdt onedriveSetting : OnedriveSetting__mdt.getAll().values()) {
            this.driveNames.put(onedriveSetting.RecordApiName__c, onedriveSetting.DriveName__c);
        }

        fflib_QueryFactory fromQueryFactory = new fflib_QueryFactory(sourceRecordId.getSobjectType());
        fromQueryFactory.selectFields(this.recordsQueryFields);
        fromQueryFactory.setCondition('Id = :sourceRecordId');
        SObject fromRecord = Database.query(fromQueryFactory.toSOQL());

        fflib_QueryFactory toQueryFactory = new fflib_QueryFactory(targetRecordId.getSobjectType());
        toQueryFactory.selectFields(this.recordsQueryFields);
        toQueryFactory.setCondition('Id = :targetRecordId');
        SObject toRecord = Database.query(toQueryFactory.toSOQL());

        Map<String, String> drives = OneDriveUtils.getDrives();
        String fromDriveId = drives.get(driveNames.get(sourceRecordId.getSobjectType().getDescribe().getName()));
        String toDriveId = drives.get(driveNames.get(targetRecordId.getSobjectType().getDescribe().getName()));

        String folderName = String.valueOf(toRecord.get('One_Drive_Folder_Name__c'));

        if ('Adoption Photos'.equalsIgnoreCase(this.targetFolderType)) {
            toDriveId = drives.get('Adoption');
            folderName = folderName + '-photos';
        }

        if ('Adoption Photos'.equalsIgnoreCase(this.sourceFolderType)) {
            fromDriveId = drives.get('Adoption');
        }

        String toFolderId = OneDriveUtils.checkIsExistFolder(toDriveId, folderName);
        if (toFolderId == null) {
            toFolderId = OneDriveUtils.createFolder(toDriveId, folderName);
        }

        if (this.copyAllFiles) {
            List<OneDrive_File__c> fromRecordOneDriveFiles;
            if (String.isNotBlank(this.targetLookupFieldName) && String.isNotBlank(this.sourceLookupFieldName)) {
                this.oneDriveFilesQueryFields.addAll(new List<String>{
                        sourceLookupFieldName, targetLookupFieldName
                });
                fflib_QueryFactory fromRecordFilesQuery = new fflib_QueryFactory(OneDrive_File__c.SObjectType);
                fromRecordFilesQuery.selectFields(this.oneDriveFilesQueryFields);
                fromRecordFilesQuery.setCondition(this.sourceLookupFieldName + ' = :sourceRecordId');
                fromRecordOneDriveFiles = Database.query(fromRecordFilesQuery.toSOQL());
            }
            List<Object> fromRecordFolderFiles = OneDriveUtils.getItems(fromDriveId, String.valueOf(fromRecord.get('One_Drive_Folder_Name__c')));
            List<OneDrive_File__c> copiedOneDriveFiles = new List<OneDrive_File__c>();


            if (fromRecordFolderFiles != null) {
                for (Object fileMap : fromRecordFolderFiles) {
                    String fileId = String.valueOf(((Map<String, Object>) fileMap).get('id'));
                    String fileName = String.valueOf(((Map<String, Object>) fileMap).get('name'));
                    OneDriveUtils.copyFile(fromDriveId, fileId, toDriveId, toFolderId, fileName);
                }

                if (String.isNotBlank(this.targetLookupFieldName) && String.isNotBlank(this.sourceLookupFieldName)) {
                    for (OneDrive_File__c oneDriveFile : fromRecordOneDriveFiles) {
                        OneDrive_File__c oneDriveFileCopy = oneDriveFile.clone();
                        oneDriveFileCopy.put(this.sourceLookupFieldName, null);
                        oneDriveFileCopy.put(this.targetLookupFieldName, targetRecordId);

                        List<String> nameParts = oneDriveFile.Name.split('\\.');
                        oneDriveFileCopy.Name = oneDriveFile.Name.replace('.' + nameParts[nameParts.size() - 1], ' (Copy).' + nameParts[nameParts.size() - 1]);
                        oneDriveFileCopy.Is_Public__c = 'Adoption Photos'.equalsIgnoreCase(this.targetFolderType);
                        oneDriveFile.Folder_Name__c = folderName;
                    }

                    insert copiedOneDriveFiles;
                }
            }
        } else {
            if (!files.isEmpty()) {
                OneDrive_File__c oneDriveFileCopy = new OneDrive_File__c();
                List<OneDrive_File__c> copiedOneDriveFiles = new List<OneDrive_File__c>();

                for (OneDrive_File__c oneDriveFile : files) {
                    if (String.isNotBlank(this.fileOperation) && 'copy'.equals(this.fileOperation)) {
                        OneDriveUtils.copyFile(fromDriveId, oneDriveFile.File_ID__c, toDriveId, toFolderId, oneDriveFile.Name);

                        oneDriveFileCopy = oneDriveFile.clone();

                        if (String.isNotBlank(this.sourceLookupFieldName) && String.isNotBlank(this.targetLookupFieldName)) {
                            oneDriveFileCopy.put(this.sourceLookupFieldName, null);
                            oneDriveFileCopy.put(this.targetLookupFieldName, targetRecordId);
                        }

                        List<String> nameParts = oneDriveFile.Name.split('\\.');
                        oneDriveFileCopy.Name = oneDriveFile.Name.replace('.' + nameParts[nameParts.size() - 1], ' (Copy).' + nameParts[nameParts.size() - 1]);
                        oneDriveFileCopy.Is_Public__c = 'Adoption Photos'.equalsIgnoreCase(this.targetFolderType);
                        oneDriveFileCopy.Folder_Name__c = folderName;

                        copiedOneDriveFiles.add(oneDriveFileCopy);
                    } else if (String.isNotBlank(this.fileOperation) && 'move'.equals(this.fileOperation) && this.targetLookupFieldName.equals(this.sourceLookupFieldName)) {
                        OneDriveUtils.moveFileToFolder(toDriveId, oneDriveFile.File_ID__c, toFolderId, oneDriveFile.Name);
                        if (String.isNotBlank(this.sourceLookupFieldName)) {
                            oneDriveFile.put(this.sourceLookupFieldName, null);
                        }

                        if (String.isNotBlank(this.targetLookupFieldName)) {
                            oneDriveFile.put(targetLookupFieldName, targetRecordId);
                        }

                        oneDriveFile.Folder_Name__c = folderName;
                    }
                }

                if (String.isNotBlank(this.fileOperation) && 'copy'.equals(this.fileOperation) && !copiedOneDriveFiles.isEmpty()) {
                    List<Object> fromRecordFolderFiles = OneDriveUtils.getItems(toDriveId, folderName);

                    for (OneDrive_File__c oneDriveFileVar : copiedOneDriveFiles) {
                        for (Object fileMap : fromRecordFolderFiles) {
                            String fileId = String.valueOf(((Map<String, Object>) fileMap).get('id'));
                            String fileName = String.valueOf(((Map<String, Object>) fileMap).get('name'));

                            if (fileName.contains(oneDriveFileVar.Name)) {
                                oneDriveFileVar.File_ID__c = fileId;
                            }
                        }
                    }
                }

                if (String.isNotBlank(this.targetLookupFieldName)) {
                    try {
                        update files;
                    } catch (Exception e) {
                        System.debug(e.getMessage());
                        System.debug(e.getStackTraceString());
                        System.debug(e.getLineNumber());
                    }

                    if (String.isNotBlank(this.fileOperation) && 'copy'.equals(this.fileOperation)) {
                        insert copiedOneDriveFiles;
                    }
                }
            } else {
                throw new vertic_Structs.CommonException('Error: no files');
            }
        }
    }
}