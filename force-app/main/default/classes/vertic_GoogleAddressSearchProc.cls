public without sharing class vertic_GoogleAddressSearchProc extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              ATTRIBUTES
     * ==============================================================================================================
     */

    private String placeId;
    private String endpoint = 'https://maps.googleapis.com/maps/api/place';
    private final static String GOOGLE_MAPS_API_KEY = vertic_SettingService.getValue('GOOGLE_MAPS_API_KEY');


    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.init();
        this.prepareRequest();
        this.response.put('googleResponse', JSON.deserializeUntyped(send(this.endpoint)));

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void init() {
        this.placeId = this.request.getString('placeId');
    }

    private void prepareRequest() {
        if (String.isBlank(this.placeId)) {
            this.endpoint += String.format('/autocomplete/json?input={0}&types={1}&key={2}&components=country:AU', new List<String> {
                EncodingUtil.urlEncode(this.request.getString('searchTerm'), 'UTF-8'),
                this.request.getString('types'),
                GOOGLE_MAPS_API_KEY
            });
        } else {
            this.endpoint += String.format('/details/json?placeid={0}&key={1}', new List<String> {
                this.placeId,
                GOOGLE_MAPS_API_KEY
            });
        }
    }

    private static String send(String strURL) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req);
        return res.getBody();
    }


    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties: 
    // vertic_request
    // vertic_response

}