public without sharing class EziDebitScheduleManagementQAMetaProc extends vertic_MetadataProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new MetadataRequest() : (MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                npe03__Recurring_Donation__c.npsp__ClosedReason__c
        };

        super.process(this.request);

        return this.response;
    }
}