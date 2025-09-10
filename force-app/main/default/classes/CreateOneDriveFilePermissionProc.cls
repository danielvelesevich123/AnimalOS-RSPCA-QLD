public without sharing class CreateOneDriveFilePermissionProc extends vertic_AbstractProcessor {

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
        String oneDriveFileId = this.request.getString('id');
        String userId = UserInfo.getUserId();
        OneDrive_File__c oneDriveFile = (OneDrive_File__c) vertic_Utils.arrays.firstOrNull([
                SELECT Id
                FROM OneDrive_File__c
                WHERE File_ID__c = :oneDriveFileId
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

        One_Drive_File_Permission__c oneDriveFilePermission = new One_Drive_File_Permission__c(
                OwnerId = userId,
                One_Drive_File_Id__c = oneDriveFileId,
                Available_Profiles_Text__c = availableProfiles
        );

        insert oneDriveFilePermission;
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