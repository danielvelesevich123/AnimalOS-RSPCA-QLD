public without sharing class OneDriveMoveFileToFolder extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
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

        OneDriveUtils.moveFileToFolder(
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
    // vertic_request
    // vertic_response


}