public without sharing class ReleaseAnimalQAMetaProc extends vertic_MetadataProcessor{
    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
//        this.response.put('googleKey', GoogleMapsCtrl.getGoogleMapsAPIKey());
        this.response.put('googleKey', 'AIzaSyAw-6Svh5nPe97j336wMQat98KKxs8d1UU');
    }
}