public without sharing class OneDriveGetFolderProc extends vertic_AbstractProcessor {

    String siteName = 'SalesForceDocInt';
    Map<String, String> overrides = new Map<String, String>();

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
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

        List<Object> files = OneDriveUtils.getItems(this.request.getString('driveId'), this.request.getString('oldOneDriveFolderName'));

        if (files == null) {
            return ;
        }

        this.request.put('Files', files);

        OneDriveCheckIsExistFolderProc.enqueueVAP(this.request);
    }

    public static void enqueueVAP(String oldOneDriveFolderName, String newOneDriveFolderName, String driveId){
        Vertic_Async_Process__c verticAsyncProcessVar = new Vertic_Async_Process__c();
        Map<String, Object> requestMap = new Map<String, Object>{
            'oldOneDriveFolderName' => oldOneDriveFolderName,
            'newOneDriveFolderName' => newOneDriveFolderName,
            'driveId' => driveId
        };
        verticAsyncProcessVar.Processor__c = 'OneDriveGetFolderProc';
        verticAsyncProcessVar.Payload__c = JSON.serialize(requestMap);
        verticAsyncProcessVar.Description__c = 'Get OneDrive Folder Files';
        verticAsyncProcessVar.Group_Key__c = newOneDriveFolderName;

        insert verticAsyncProcessVar;
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