public inherited sharing class StripeSetupIntentCreationProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {

        npsp_plus.vertic_DTO setupIntentDTO;
        if (Test.isRunningTest()) {
            setupIntentDTO = new npsp_plus.vertic_DTO(new Map<String, Object>{
                'intent' => this.request.getRequiredString('intentId'),
                'client_secret' => 'testKey',
                'payment_method_types'=>'card,au_becs_debi'
            });
        }else {
            setupIntentDTO = new npsp_plus.Stripe().getGenericAPI('setup_intents').create(new Map<String, String>{
//            'automatic_payment_methods[enabled]' => 'true',
                'payment_method_types[]' => 'card,au_becs_debit',
                'usage' => 'on_session'
            });
        }
        this.response.put('intent', setupIntentDTO.getMap());
        this.response.put('clientSecret', setupIntentDTO.getRequiredString('client_secret'));
    }

}