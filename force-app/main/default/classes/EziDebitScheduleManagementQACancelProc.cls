public class EziDebitScheduleManagementQACancelProc extends vertic_AbstractProcessor implements Database.AllowsCallouts {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String recordId = this.request.getRequiredString('recordId');

        npe03__Recurring_Donation__c recurringDonation = (npe03__Recurring_Donation__c) vertic_Utils.arrays.firstOrException([
                SELECT npsp__Status__c, EziDebit_Customer_ID__c, npsp__PaymentMethod__c
                FROM npe03__Recurring_Donation__c
                WHERE Id = :recordId
        ], 'Recurring Donation not found.');

        EzidebitPaymentProcessor ezidebitProcessor = new EzidebitPaymentProcessor(payment_ProcessorFactory.getGatewayCredentials('EziDebit'));
        //change status to Cancelled
        if (!ezidebitProcessor.changeCustomerStatus(recurringDonation.EziDebit_Customer_ID__c, 'C')) {
            throw new vertic_Structs.ProcessException('Ezidebit Schedule can not be cancelled. EziDebit Customer ID: ' + recurringDonation.EziDebit_Customer_ID__c);
        }
        //clear all scheduled payments
        if (!ezidebitProcessor.clearSchedule(recurringDonation.EziDebit_Customer_ID__c, null, true)) {
            throw new vertic_Structs.ProcessException('Ezidebit Schedule can not be cancelled. EziDebit Customer ID: ' + recurringDonation.EziDebit_Customer_ID__c);
        }

        List<npe01__OppPayment__c> payments = [
                SELECT Id
                FROM npe01__OppPayment__c
                WHERE npe01__Opportunity__r.npe03__Recurring_Donation__c = :recordId AND EziDebit_Transaction_ID__c = 'SCHEDULED'
        ];

        for (npe01__OppPayment__c payment : payments) {
            payment.npe01__Written_Off__c = true;
        }

        update payments;

        update new npe03__Recurring_Donation__c(
                Id = recordId,
                npsp__Status__c = 'Closed',
                npsp__ClosedReason__c = this.request.getString('closedReason')
        );

        Opportunity pledgedOpportunity = (Opportunity) vertic_Utils.arrays.firstOrNull([
                SELECT Id
                FROM Opportunity
                WHERE npe03__Recurring_Donation__c = :recordId AND StageName = 'Pledged'
        ]);

        if (pledgedOpportunity != null) {
            pledgedOpportunity.StageName = 'Closed Lost';
            update pledgedOpportunity;
        }
    }
}