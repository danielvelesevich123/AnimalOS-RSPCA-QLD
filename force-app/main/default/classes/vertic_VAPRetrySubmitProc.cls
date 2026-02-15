public without sharing class vertic_VAPRetrySubmitProc extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void doSubmit() {

        String vapId = this.request.getRequiredString('id');

        aos_Async_Process__c vapVar = (aos_Async_Process__c)vertic_Utils.arrays.firstOrException(
            [SELECT Id, aos_Status__c FROM aos_Async_Process__c WHERE Id = :vapId],
            'No aos_Async_Process__c with Id: ' + vapId
        );

        if('Completed'.equalsIgnoreCase(vapVar.aos_Status__c)){
            throw new vertic_Structs.ValidationException('The process already successfully processed!');
        }

        vertic_AsyncProcess.process(new Set<String>{vapId}, new Map<String, Object>{
            'forceStatus' => true
        });

        vapVar = (aos_Async_Process__c)vertic_Utils.arrays.firstOrException(
        [SELECT Id, aos_Details__c, aos_Payload__c, aos_Status__c FROM aos_Async_Process__c WHERE Id = :vapId],
            'No aos_Async_Process__c with Id: ' + vapId
        );

        this.response.getMapper().mapFromSObject('vap', vapVar);

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