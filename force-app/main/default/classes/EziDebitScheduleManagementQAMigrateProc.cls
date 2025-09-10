public class EziDebitScheduleManagementQAMigrateProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String recurringDonationId = this.request.getRequiredString('recordId');

        npe03__Recurring_Donation__c recurringDonation = [
                SELECT Id, EziDebit_Customer_ID__c
                FROM npe03__Recurring_Donation__c
                WHERE Id = :recurringDonationId
        ];

        vertic_Utils.objects.throwIfBlank(recurringDonation.EziDebit_Customer_ID__c, 'Scheduled RD with empty EziDebit Customer ID can not be canceled');

        EzidebitPaymentProcessor ezidebitProcessor = new EzidebitPaymentProcessor(payment_ProcessorFactory.getGatewayCredentials('EziDebit'));
        //change status to Cancelled
        if (!ezidebitProcessor.changeCustomerStatus(recurringDonation.EziDebit_Customer_ID__c, 'C')) {
            throw new vertic_Structs.ProcessException('Ezidebit Schedule can not be cancelled. EziDebit Customer ID: ' + recurringDonation.EziDebit_Customer_ID__c);
        }
        //clear all scheduled payments
        if (!ezidebitProcessor.clearSchedule(recurringDonation.EziDebit_Customer_ID__c, null, true)) {
            throw new vertic_Structs.ProcessException('Ezidebit Schedule can not be cancelled. EziDebit Customer ID: ' + recurringDonation.EziDebit_Customer_ID__c);
        }

        update new npe03__Recurring_Donation__c(
                Id = recurringDonationId,
                npsp__PaymentMethod__c = 'ACH/EFT',
                EziDebit_Customer_ID__c = null
        );
    }
}