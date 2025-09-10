public without sharing class EziDebitRefundQAMetaProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    /**
     * ==============================================================================================================
     *                                              ATTRIBUTES
     * ==============================================================================================================
     */

    private npe01__OppPayment__c payment;


    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.init();

        this.response.put('payment', this.payment);

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void init() {
        String recordId = this.request.getRequiredString('recordId');
        this.payment = (npe01__OppPayment__c) vertic_Utils.arrays.firstOrException([
            SELECT EziDebit_Transaction_ID__c, npsp_plus__Status__c
            FROM npe01__OppPayment__c
            WHERE Id = :recordId
        ],
            'No Payment with Id: ' + recordId
        );
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