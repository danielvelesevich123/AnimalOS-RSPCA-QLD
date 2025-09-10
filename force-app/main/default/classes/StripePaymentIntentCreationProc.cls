public inherited sharing class StripePaymentIntentCreationProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        npsp_plus.vertic_DTO intentDTO;
        if (Test.isRunningTest()) {
            intentDTO = new npsp_plus.vertic_DTO(new Map<String, Object>{
                'amount' => this.request.getDecimal('amount'),
                'currency' => this.request.getString('currency'),
                'confirm' => 'false',
                'client_secret' => 'testKey'
            });
        } else {
             intentDTO = new npsp_plus.Stripe().getGenericAPI('payment_intents').create(new Map<String, String>{
                'amount' => '' + npsp_plus.Stripe.formatAmount(vertic_Utils.objects.defaultIfNull(this.request.getDecimal('amount'), 10.0)),
                'currency' => vertic_Utils.objects.defaultIfNull(npsp_plus.SettingsService.getDTO().getString('currency'), 'aud'), 'confirm' => 'false'
            });
        }
        this.response.put('intent', intentDTO.getMap());
        this.response.put('clientSecret', intentDTO.getRequiredString('client_secret'));
    }

}