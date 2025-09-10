public without sharing class OneDriveMigrateFoldersProc extends vertic_AbstractProcessor {

    Map<String, String> overrides = new Map<String, String>();
    Map<String, String> drives = new Map<String, String>();

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.getOverrides();
        this.getDrives();
        this.nextStep();


        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void nextStep() {
        OneDriveGetFolderProc.enqueueVAP(
            this.request.getString('oldOneDriveFolderName'),
            this.request.getString('newOneDriveFolderName'),
            this.drives.get(this.overrides.get(this.request.getString('recordApiName')))
        );
    }

    private void getDrives(){
        this.drives = OneDriveUtils.getDrives();
    }

    private void getOverrides(){
        for (OnedriveSetting__mdt onedriveSetting : [SELECT DeveloperName, RecordApiName__c, DriveName__c FROM OnedriveSetting__mdt]){
            this.overrides.put(onedriveSetting.RecordApiName__c, onedriveSetting.DriveName__c);
        }
    }

    public static Vertic_Async_Process__c enqueueVAP(String oldOneDriveFolderName, String newOneDriveFolderName, String recordApiName){
        Vertic_Async_Process__c verticAsyncProcessVar = new Vertic_Async_Process__c();
        Map<String, Object> requestMap = new Map<String, Object>{
            'oldOneDriveFolderName' => oldOneDriveFolderName,
            'newOneDriveFolderName' => newOneDriveFolderName,
            'recordApiName' => recordApiName
        };
        verticAsyncProcessVar.Processor__c = 'OneDriveMigrateFoldersProc';
        verticAsyncProcessVar.Payload__c = JSON.serialize(requestMap);
        verticAsyncProcessVar.Description__c = 'Start Migrate One Drive Folders';
        verticAsyncProcessVar.Group_Key__c = newOneDriveFolderName;

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