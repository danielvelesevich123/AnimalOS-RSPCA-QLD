public with sharing class aos_FileAccessRestrictionsModalMetaProc extends vertic_MetadataProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new MetadataRequest() : (MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void init() {
        String oneDriveFileId = request.getString('oneDriveFileID');

        aos_One_Drive_File_Permission__c oneDriveFilePermission = (aos_One_Drive_File_Permission__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, aos_Available_Profiles_Text__c
                FROM aos_One_Drive_File_Permission__c
                WHERE aos_One_Drive_File_Id__c = :oneDriveFileId
        ], 'One Drive File Permission not found');

        this.response.getMapper().mapFromSObject('oneDriveFilePermission', oneDriveFilePermission);
        this.response.addSelectOptions('availableProfilesOptions', vertic_Utils.sObjects.toSelectOptions([
                SELECT Id, Name
                FROM Profile
                ORDER BY Name ASC
        ], 'Name', 'Name'));
    }

    /**
     * ==============================================================================================================
     *                                         STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */

}