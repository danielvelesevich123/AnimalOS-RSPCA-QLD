public with sharing class aos_FileAccessRestrictionsModalMetaProc extends aos_MetadataProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override aos_Response process(aos_Request request) {
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

        aos_One_Drive_File_Permission__c oneDriveFilePermission = (aos_One_Drive_File_Permission__c) aos_Utils.arrays.firstOrException([
                SELECT Id, aos_Available_Profiles_Text__c
                FROM aos_One_Drive_File_Permission__c
                WHERE aos_One_Drive_File_Id__c = :oneDriveFileId
        ], 'One Drive File Permission not found');

        this.response.getMapper().mapFromSObject('oneDriveFilePermission', oneDriveFilePermission);
        this.response.addSelectOptions('availableProfilesOptions', aos_Utils.sObjects.toSelectOptions([
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