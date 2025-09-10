public without sharing class ContactGenerateCRNActionSubmitProc extends vertic_AbstractProcessor {

/**
 * ==============================================================================================================
 *                                              PROCESS
 * ==============================================================================================================
 */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.init();
        this.updateCRN();
        this.mapResponse();

        return this.response;
    }

    private void init() {
        this.contact = (Contact) vertic_Utils.arrays.firstOrException([
            SELECT Id,
                BPAY_CRN__c,
                BPAY_Contract_Reference__c
            FROM Contact
            WHERE Id =: THIS.request.getRequiredString('recordId')
        ]);
    }

    private void updateCRN() {

        if(this.contact.BPAY_CRN__c != null){
            throw new vertic_Structs.ValidationException('BPAY Customer Reference Number already exists!');
        }
        if(this.contact.BPAY_Contract_Reference__c == null){
            throw new vertic_Structs.ValidationException('BPAY Client Contract Reference is empty!');
        }

        this.bPayCRN = new EzidebitPaymentProcessor(payment_ProcessorFactory.getGatewayCredentials('EziDebit')).getCRN(
            this.contact.BPAY_Contract_Reference__c, 'Vertic'
        );

        this.contact.BPAY_CRN__c = this.bPayCRN.BPayCRN;
        this.contact.BPAY_Biller_Code__c = this.bPayCRN.BPayBillerCode;

        update this.contact;
    }

    private void mapResponse() {
        this.response.put('CRN', this.bPayCRN.BPayCRN);
    }

/**
 * ==============================================================================================================
 *                                             PRIVATE METHODS
 * ==============================================================================================================
 */


    private Contact contact;
    private EzidebitStructs.BPayCRN bPayCRN;


/**
 * ==============================================================================================================
 *                                               STRUCTURES
 * ==============================================================================================================
 */

// Proposed Live Templates to override Super properties:
// vertic_request
// vertic_response


}