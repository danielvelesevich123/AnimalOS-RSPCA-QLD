public without sharing class CampaignGenerateCRNActionSubmitProc extends vertic_AbstractProcessor {
    /**
    * ==============================================================================================================
    *                                              PROCESS
    * ==============================================================================================================
    */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.init();
        this.getCRNInBatch();

        return this.response;
    }

    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void init() {
        this.recordId = this.request.getRequiredString('recordId');
    }

    private void getCRNInBatch(){
        String batchId = Database.executeBatch(new EzidebitGenerateCRNBatch(this.recordId), 1);
        this.response.getMapper().mapAnyValue('batchId', batchId);
    }

    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    private String recordId;
}