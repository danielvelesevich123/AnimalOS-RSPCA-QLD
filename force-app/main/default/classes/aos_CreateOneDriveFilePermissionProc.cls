public without sharing class aos_CreateOneDriveFilePermissionProc extends aos_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override aos_Response process(aos_Request request) {
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
        String oneDriveFileId = this.request.getString('id');
        String userId = UserInfo.getUserId();
        aos_OneDrive_File__c oneDriveFile = (aos_OneDrive_File__c) aos_Utils.arrays.firstOrNull([
                SELECT Id
                FROM aos_OneDrive_File__c
                WHERE aos_File_ID__c = :oneDriveFileId
        ]);


        List<Profile> profiles = [
                SELECT Id, Name
                FROM Profile
        ];
        String availableProfiles = '';

        if (oneDriveFile != null) {

            for (Profile profileVar : profiles) {
                availableProfiles += profileVar.Name + ';';
            }
        }

        aos_One_Drive_File_Permission__c oneDriveFilePermission = new aos_One_Drive_File_Permission__c(
                OwnerId = userId,
                aos_One_Drive_File_Id__c = oneDriveFileId,
                aos_Available_Profiles_Text__c = availableProfiles
        );

        insert oneDriveFilePermission;
    }


    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties:
    // aos_Request
    // aos_Response


}