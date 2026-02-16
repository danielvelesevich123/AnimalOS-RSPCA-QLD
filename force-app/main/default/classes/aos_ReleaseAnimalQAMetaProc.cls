public without sharing class aos_ReleaseAnimalQAMetaProc extends aos_MetadataProcessor{
    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

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