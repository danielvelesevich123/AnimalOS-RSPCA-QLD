public without sharing class OneDriveCheckIsExistFolderProc extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.checkIsExistFolder();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void checkIsExistFolder() {
        this.request.put('isExistFolderId', OneDriveUtils.checkIsExistFolder(this.request.getString('driveId'), this.request.getString('newOneDriveFolderName')));

        if(this.request.getString('isExistFolderId') != null){
            List<Vertic_Async_Process__c> asyncProcesses = new List<Vertic_Async_Process__c>();

            for (Object fileObj : this.request.getList('Files')){

                Map<String, Object> file = (Map<String,Object>) fileObj;

                asyncProcesses.add(OneDriveMoveFileToFolder.enqueueVAP(
                        this.request.getString('driveId'),
                        (String)file.get('id'),
                        this.request.getString('isExistFolderId'),
                        (String)file.get('name'),
                        this.request.getString('newOneDriveFolderName')
                ));
            }

            insert asyncProcesses;
        } else {
            OneDriveCreateFolderProc.enqueueVAP(this.request);
        }
    }

    public static void enqueueVAP(vertic_Request request){
        Vertic_Async_Process__c verticAsyncProcessVar = new Vertic_Async_Process__c();

        verticAsyncProcessVar.Processor__c = 'OneDriveCheckIsExistFolderProc';
        verticAsyncProcessVar.Payload__c = JSON.serialize(request.getMap());
        verticAsyncProcessVar.Description__c = 'Check Is Exist Folder';
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