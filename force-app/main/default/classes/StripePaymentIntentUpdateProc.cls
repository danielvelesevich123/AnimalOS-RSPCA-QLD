public inherited sharing class StripePaymentIntentUpdateProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        Map<String, String> requestData = new Map<String, String>{
            'amount' => '' + npsp_plus.Stripe.formatAmount(vertic_Utils.objects.defaultIfNull(this.request.getDecimal('amount'), 10.0)),
            'metadata[npsp_plus_contact]' => DonateSubmitProc.getContactMetadata(this.request)  
        };

        String campaignName = this.request.getString('campaignName');
        if (String.isNotBlank(campaignName)) {
            requestData.put('metadata[npsp_plus_campaign]', JSON.serialize(new Map<String, Object>{
                'Name' => campaignName
            }));
        }
        
        requestData.put('metadata[npsp_plus_donation]', JSON.serialize(new Map<String, Object>{
                'npsp__Acknowledgment_Status__c' => 'Email Acknowledgment Now'
            }));

        npsp_plus.vertic_DTO intentDTO;
        if (Test.isRunningTest()) {
            intentDTO = new npsp_plus.vertic_DTO(new Map<String, Object>{
                'intent' => this.request.getRequiredString('intentId'),
                'client_secret' => 'testKey'
            });
        }else {
            intentDTO = new npsp_plus.Stripe().getGenericAPI('payment_intents').doUpdate(this.request.getRequiredString('intentId'), requestData);
        }

        this.response.put('intent', intentDTO.getMap());
        this.response.put('clientSecret', intentDTO.getRequiredString('client_secret'));
    }

}