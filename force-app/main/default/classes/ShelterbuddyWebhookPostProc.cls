public without sharing class ShelterbuddyWebhookPostProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = (vertic_RestService.Request) request;
        this.response = (vertic_RestService.Response) super.response;

        this.doSubmit();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void doSubmit() {

        insert new aos_Async_Process__c(
                aos_Processor__c = '' + ShelterbuddyWebhookPostProc.class,
                aos_Payload__c = JSON.serialize(new Map<String, Object>{
                    'headers' => this.request.headers,
                    'body' => this.request.getMap()
                }),
                aos_Autorun__c = true,
                aos_Is_Queueable__c = false,
                aos_Status__c = 'Failed',
                aos_Description__c = 'Test shelterbuddy webhooks'
        );

        Savepoint sp = Database.setSavepoint();

        String requestMapDump;
        try {

            String event = 'Shelterbuddy_Animal_Upsert';

            String flowSetting = vertic_Utils.objects.defaultIfNull(event, this.request.params.get('flow'));
            vertic_Utils.objects.throwIfBlank(flowSetting, '"flow" URL param is required!');
            String payloadJSON = this.request.getJSON();

            System.debug('payloadJSON: ' + payloadJSON);

            Map<String, Object> requestMap = new Map<String, Object>{
                    'settingName' => flowSetting,
                    'inputs' => (Map<String, Object>) JSON.deserializeUntyped(payloadJSON)
            };

            System.debug(requestMap);

            requestMapDump = JSON.serialize(requestMap);

            vertic_Response flowResponseVar;

            System.debug(flowResponseVar);
            if(flowResponseVar.isValid != true){
                throw new vertic_Structs.ProcessException(flowResponseVar.error.message);
            } else {
                this.response.dto.putAll(flowResponseVar.getMap());
            }

        } catch (Exception e) {
            if(sp != null){ Database.rollback(sp); }

            this.response.error = new vertic_Structs.ErrorDetails(e.getMessage());
            this.response.isValid = false;

            aos_Async_Process__c asyncProcess = new aos_Async_Process__c(
                    aos_Autorun__c = true,
                    aos_Allowed_Attempts__c = 3,
                    aos_Is_Queueable__c = false,
                    aos_Status__c = 'Pending',
                    aos_Processor__c = 'vertic_FlowSettingProc',
                    aos_Payload__c = requestMapDump,
                    aos_Details__c = e.getMessage(),
                    aos_Description__c = 'Automated retry of Failed REST Flow Processing'
            );
            insert asyncProcess;
        } finally {
            this.response.headers.put('Content-Type', 'application/json');
        }

    }


    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    private vertic_RestService.Response response;

    protected override vertic_Response getResponseInstance() {
        return new vertic_RestService.Response();
    }

    /** ============================================================================================================= */

    private vertic_RestService.Request request;

    public override Type getRequestType() {
        return vertic_RestService.Request.class;
    }

    public override vertic_Request getRequestInstance(String requestJSON) {
        return (vertic_RestService.Request) JSON.deserialize(requestJSON, this.getRequestType());
    }
}