public without sharing class PopulateLocationProc extends vertic_AbstractProcessor {
    private Account record;

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.init();
        this.populateLocation();

        return this.response;
    }

    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void init() {
        Id recordId = this.request.getId('recordId');
        this.record = new rspcaqldAccountSelector().getAccountById(recordId);
    }

    private void populateLocation() {
        String address = String.format('{0}, {1}, {2}, {3}', new List<String>{this.record.ShippingStreet, this.record.ShippingPostalCode, this.record.ShippingState, this.record.ShippingCity});

        if (String.isNotBlank(address)) {
            vertic_Response getLocationResponse = new GetGeocodeProc().process(new vertic_Request(new Map<String, Object>{
                'address' => address
            }));

            if (getLocationResponse.isValid == true) {
                Location locationVar = (Location) getLocationResponse.get('location');

                this.record.Geolocation__Latitude__s = locationVar.getLatitude();
                this.record.Geolocation__Longitude__s = locationVar.getLongitude();

                update this.record;
            } else {
                this.response = getLocationResponse;
            }
        }
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