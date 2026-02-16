public without sharing class aos_OneDriveMoveFileToFolder extends aos_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.moveFileToFolder();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void moveFileToFolder() {

        aos_OneDriveUtils.moveFileToFolder(
                this.request.getString('driveId'),
                this.request.getString('fileId'),
                this.request.getString('newFolderId'),
                this.request.getString('fileName')
        );

    }

    public static aos_Async_Process__c enqueueVAP(String driveId, String fileId, String newFolderId, String fileName, String newFolderName ){
        aos_Async_Process__c verticAsyncProcessVar = new aos_Async_Process__c();

        Map<String, Object> request = new Map<String, Object>{
                'driveId' => driveId,
                'fileId' => fileId,
                'newFolderId' => newFolderId,
                'fileName' => fileName
        };

        verticAsyncProcessVar.aos_Processor__c = 'OneDriveMoveFileToFolder';
        verticAsyncProcessVar.aos_Payload__c = JSON.serialize(request);
        verticAsyncProcessVar.aos_Description__c = 'Get OneDrive Folder Files';
        verticAsyncProcessVar.aos_Group_Key__c = newFolderName;

        return verticAsyncProcessVar;
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