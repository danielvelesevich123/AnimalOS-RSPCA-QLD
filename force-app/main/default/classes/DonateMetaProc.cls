public inherited sharing class DonateMetaProc extends vertic_MetadataProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        String publicKey = npsp_plus.SettingsService.getStripePublishableKey();

        this.response.put('publicKey', publicKey);
        this.response.put('donationType', 'recurring');
        this.response.put('amount', 50);
//        this.response.put('email', 'test@test.com');
    }
}