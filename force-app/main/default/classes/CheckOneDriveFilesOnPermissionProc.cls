public without sharing class CheckOneDriveFilesOnPermissionProc extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void doSubmit() {
        Id recordId = this.request.getString('recordId');

        List<Map<String, Object>> files = this.request.getListAsMap('files');

        List<String> filesId = new List<String>();

        for (Map<String, Object> fileMap : files) {
            filesId.add(String.valueOf(fileMap.get('id')));
        }

        User currentUser = [SELECT Id, Profile.Name, Profile.UserLicense.Name FROM User WHERE Id = :UserInfo.getUserId()].get(0);

        fflib_QueryFactory queryFactory = new fflib_QueryFactory(aos_OneDrive_File__c.SObjectType)
                .selectFields(new Set<String>{
                        'Id',
                        'Name',
                        'File_ID__c',
                        'CreatedBy.Name'
                })
                .setCondition(String.join(new List<String>{
                        '(File_ID__c IN :filesId OR ' + OneDriveCreateFileSObjectProc.getLookupFieldName(recordId?.getSobjectType()) + ' = \'' + recordId + '\')'
                }, ' AND '));

        Map<String, sObject> oneDriveFilesByFileId = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(
                Database.query(queryFactory.toSOQL()),
                aos_OneDrive_File__c.aos_File_ID__c
        );

        Map<String, SObject> oneDriveFilePermissionMap = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, OwnerId, aos_One_Drive_File_Id__c, aos_Available_Profiles_Text__c
                FROM aos_One_Drive_File_Permission__c
                WHERE aos_One_Drive_File_Id__c IN :filesId
        ], aos_One_Drive_File_Permission__c.aos_One_Drive_File_Id__c);

        for (Map<String, Object> file : files) {
            String oneDriveFileId = String.valueOf(file.get('id'));
            String oneDriveFileName = String.valueOf(file.get('name')).remove(' (Copy)');

            aos_One_Drive_File_Permission__c oneDriveFilePermission = (aos_One_Drive_File_Permission__c) oneDriveFilePermissionMap.get(oneDriveFileId);
            aos_OneDrive_File__c oneDriveFile = (aos_OneDrive_File__c) oneDriveFilesByFileId.get(oneDriveFileId);

            if (oneDriveFile == null) {
                for (aos_OneDrive_File__c driveFile : (List<aos_OneDrive_File__c>) oneDriveFilesByFileId.values()) {
                    if (oneDriveFileName?.containsIgnoreCase(driveFile.Name)) {
                        oneDriveFile = driveFile;
                        break;
                    }
                }
            }


            Boolean isCommunityUser = currentUser.Profile.UserLicense.Name.containsIgnoreCase('Customer Community');
            Boolean isFileOwner = oneDriveFilePermission == null ? false : currentUser.Id == oneDriveFilePermission.OwnerId;
            Boolean userHasAccess = oneDriveFilePermission == null ? true :
                    oneDriveFilePermission.aos_Available_Profiles_Text__c == null ? true : oneDriveFilePermission.aos_Available_Profiles_Text__c.contains(currentUser.Profile?.Name);


            this.response.getMapper().mapAnyValue(oneDriveFileId, new Map<String, Object>{
                    'isCommunityUser' => isCommunityUser,
                    'isFileOwner' => isFileOwner,
                    'userHasAccess' => userHasAccess,
                    'createdBy' => oneDriveFile?.CreatedBy?.Name
            });
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