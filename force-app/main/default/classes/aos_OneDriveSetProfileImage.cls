public without sharing class aos_OneDriveSetProfileImage extends aos_AbstractProcessor implements aos_Structs.IRollbackable {

    /**
     * ==============================================================================================================
     *                                              ATTRIBUTES
     * ==============================================================================================================
     */

    // private String recordId;


    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override aos_Response process(aos_Request request) {
        this.request = request;

        Id recordId = this.request.getRequiredString('recordId');
        String fileId = this.request.getString('fileId');

        SObjectType sObjectTypeName = recordId.getSobjectType();
        String sObjectTypeNameString = recordId.getSobjectType() == animalos__Animal__c.SObjectType ? 'aos_Animal__c' : aos_OneDriveCreateFileSObjectProc.getLookupFieldName(sObjectTypeName);

        String oneDriveFilesQuery = 'SELECT Id, aos_Is_Primary__c, aos_Profile_Image__c, aos_File_Link__c, Name, aos_File_ID__c FROM aos_OneDrive_File__c WHERE ' +
                sObjectTypeNameString.remove('__c') + '__c = ' + '\'' + recordId + '\'';

        List<aos_OneDrive_File__c> oneDriveFiles = Database.query(oneDriveFilesQuery);
        List<aos_OneDrive_File__c> oneDriveFilesForUpdate = new List<aos_OneDrive_File__c>();


        for (aos_OneDrive_File__c oneDriveFile : oneDriveFiles) {
            aos_OneDrive_File__c oneDriveFileClone = oneDriveFile.clone();

            if (oneDriveFile.aos_File_ID__c == fileId) {
                oneDriveFile.aos_Profile_Image__c = !oneDriveFile.aos_Profile_Image__c == true;
                this.response.put('primaryFile', oneDriveFile);
            } else {
                oneDriveFile.aos_Profile_Image__c = false;
            }

            if (aos_Utils.sObjects.isSomeFieldChanged(oneDriveFile, oneDriveFileClone, new List<String>{
                    'aos_Profile_Image__c'
            })) {
                oneDriveFilesForUpdate.add(oneDriveFile);
            }
        }

        update oneDriveFilesForUpdate;

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */


    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties:
    // aos_Request
    // aos_Response

}