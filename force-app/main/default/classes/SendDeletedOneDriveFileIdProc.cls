public class SendDeletedOneDriveFileIdProc extends vertic_AbstractProcessor implements vertic_Structs.IAsyncPostProcessing {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String recordId = this.request.getRequiredString('recordId');

        vertic_Response rspcanswmainResponse = new vertic_HttpRequestProc().process(new Map<String, Object>{
                'endpoint' => 'https://rspcanswmain.wpenginepowered.com/wp-json/animalos/v1/animalImage/' + recordId,
                'method' => 'DELETE',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'application/json',
                        'Accept' => 'application/json'
                }
        });

        vertic_Response adoptAPetResponse = new vertic_HttpRequestProc().process(new Map<String, Object>{
                'endpoint' => 'https://adoptapet.com.au/animalImage/2/' + recordId,
                'method' => 'DELETE',
                'headers' => new Map<String, Object>{
                        'Content-Type' => 'application/json',
                        'Accept' => 'application/json'
                }
        });

        Map<String, Object> responses = new Map<String, Object>{
                'rspcanswmain' => rspcanswmainResponse.getString('response'),
                'adoptAPet' => adoptAPetResponse.getString('response')
        };

        this.response.put('response', responses);

    }

    public Vertic_Async_Process__c postProcess(Vertic_Async_Process__c asyncProcess) {
        asyncProcess.Details__c = JSON.serializePretty(this.response.getString('response'));
        return asyncProcess;
    }
}