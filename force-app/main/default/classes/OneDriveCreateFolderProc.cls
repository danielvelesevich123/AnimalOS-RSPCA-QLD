public without sharing class OneDriveCreateFolderProc extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.createFolder();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void createFolder() {

        String newFolderId = OneDriveUtils.createFolder(request.getString('driveId'), request.getString('newOneDriveFolderName'));

//        System.debug('OneDriveCreateFolderProc FILES ==>> ' + this.request.get('Files'));

        List<Vertic_Async_Process__c> asyncProcesses = new List<Vertic_Async_Process__c>();

        for (Object fileObj : this.request.getList('Files')){

            Map<String, Object> file = (Map<String,Object>) fileObj;

            asyncProcesses.add(OneDriveMoveFileToFolder.enqueueVAP(
                this.request.getString('driveId'),
                (String)file.get('id'),
                newFolderId,
                (String)file.get('name'),
                this.request.getString('newOneDriveFolderName')
            ));
        }

        insert asyncProcesses;


    }

    public static void enqueueVAP(vertic_Request request){
        Vertic_Async_Process__c verticAsyncProcessVar = new Vertic_Async_Process__c();

        verticAsyncProcessVar.Processor__c = 'OneDriveCreateFolderProc';
        verticAsyncProcessVar.Payload__c = JSON.serialize(request.getMap());
        verticAsyncProcessVar.Description__c = 'Get OneDrive Folder Files';
        verticAsyncProcessVar.Group_Key__c = request.getString('newOneDriveFolderName');

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