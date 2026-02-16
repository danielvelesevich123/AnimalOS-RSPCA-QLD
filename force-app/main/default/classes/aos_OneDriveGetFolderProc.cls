public without sharing class aos_OneDriveGetFolderProc extends aos_AbstractProcessor {

    String siteName = 'SalesForceDocInt';
    Map<String, String> overrides = new Map<String, String>();

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.getFiles();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void getFiles() {

        List<Object> files = aos_OneDriveUtils.getItems(this.request.getString('driveId'), this.request.getString('oldOneDriveFolderName'));

        if (files == null) {
            return ;
        }

        this.request.put('Files', files);

        aos_OneDriveCheckIsExistFolderProc.enqueueVAP(this.request);
    }

    public static void enqueueVAP(String oldOneDriveFolderName, String newOneDriveFolderName, String driveId){
        aos_Async_Process__c verticAsyncProcessVar = new aos_Async_Process__c();
        Map<String, Object> requestMap = new Map<String, Object>{
                'oldOneDriveFolderName' => oldOneDriveFolderName,
                'newOneDriveFolderName' => newOneDriveFolderName,
                'driveId' => driveId
        };
        verticAsyncProcessVar.aos_Processor__c = 'OneDriveGetFolderProc';
        verticAsyncProcessVar.aos_Payload__c = JSON.serialize(requestMap);
        verticAsyncProcessVar.aos_Description__c = 'Get OneDrive Folder Files';
        verticAsyncProcessVar.aos_Group_Key__c = newOneDriveFolderName;

        insert verticAsyncProcessVar;
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