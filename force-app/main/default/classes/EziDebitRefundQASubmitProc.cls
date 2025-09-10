public without sharing class EziDebitRefundQASubmitProc extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              ATTRIBUTES
     * ==============================================================================================================
     */

    private npe01__OppPayment__c payment;
    private npe01__OppPayment__c refundPayment;
    private vertic_UnitOfWork uow = new vertic_UnitOfWork(new List<SObjectType> {
        npe01__OppPayment__c.SObjectType,
        Opportunity.SObjectType
    });

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.init();
        this.doSubmit();

        this.uow.commitWork();

        this.response.put('refundPaymentId', refundPayment.Id);

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
            SELECT npe01__Opportunity__c, npe01__Payment_Amount__c, EziDebit_Transaction_ID__c
            FROM npe01__OppPayment__c
            WHERE Id = :recordId
        ],
            'No Payment with Id: ' + recordId
        );
    }

    private void doSubmit() {
        EzidebitStructs.RefundPayment refund = new EzidebitPaymentProcessor(
            payment_ProcessorFactory.getGatewayCredentials('EziDebit')
        ).processRefund(
            this.payment.EziDebit_Transaction_ID__c,
            this.payment.npe01__Payment_Amount__c
        );

        if ('Processed'.equals(refund.RefundResult)) {
            this.payment.Details__c = 'Refunded';
        }

        this.refundPayment = new npe01__OppPayment__c(
            npe01__Payment_Method__c = 'EziDebit',
            npe01__Opportunity__c = this.payment.npe01__Opportunity__c,
            npe01__Payment_Date__c = Date.today(),
            npe01__Payment_Amount__c = this.payment.npe01__Payment_Amount__c * -1,
            npe01__Paid__c = true,
            EziDebit_Transaction_ID__c = String.valueOf(refund.RefundPaymentID),
            Details__c = refund.RefundResultText,
            npsp_plus__Status__c = refund.RefundResult
        );

        this.uow.registerDirty(new Opportunity(Id = this.payment.npe01__Opportunity__c, StageName = 'Closed Lost'));
        this.uow.registerDirty(this.payment);
        this.uow.registerNew(this.refundPayment);
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