public without sharing class GetGeocodeProc extends vertic_AbstractProcessor {
    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.geocode();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void geocode() {
        String googleMapsApiKey = vertic_SettingService.getValue('GOOGLE_MAPS_API_KEY');
        if (String.isBlank(googleMapsApiKey)) {
            throw new vertic_Structs.NotFoundException('Google Maps API Key not found. Please check the \'GOOGLE_MAPS_API_KEY\' custom setting.');
        }

        String geoAddress = EncodingUtil.urlEncode(this.request.getString('address'), 'UTF-8');

        Http http = new Http();

        HttpRequest request = new HttpRequest();

        request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + geoAddress + '&key=' + googleMapsApiKey + '&sensor=false');

        request.setMethod('GET');

        request.setTimeout(120000);

        try {
            String responseBody;

            if (Test.isRunningTest()){
                responseBody = '{"results":[{"address_components":[{"long_name":"Brest","short_name":"Brest","types":["locality","political"]},{"long_name":"Finistere","short_name":"Finistere","types":["administrative_area_level_2","political"]},{"long_name":"Brittany","short_name":"Brittany","types":["administrative_area_level_1","political"]},{"long_name":"France","short_name":"FR","types":["country","political"]}],"formatted_address":"Brest, France","geometry":{"bounds":{"northeast":{"lat":48.459562,"lng":-4.4302621},"southwest":{"lat":48.3572541,"lng":-4.568938999999999}},"location":{"lat":48.390394,"lng":-4.486076},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":48.459562,"lng":-4.4302621},"southwest":{"lat":48.3572541,"lng":-4.568938999999999}}},"place_id":"ChIJk1uS2eG7FkgRqzCcF1iDSMY","types":["locality","political"]}],"status":"OK"}';
            } else {
                HttpResponse response = http.send(request);

                if (response.getStatusCode() != 200){
                    throw new vertic_Structs.CommonException(response.getStatus());
                }

                responseBody = response.getBody();
            }

            MapsGeocodeResponse responseParsed = (MapsGeocodeResponse) JSON.deserialize(responseBody, MapsGeocodeResponse.class);

            Double latitude = null;
            Double longitude = null;
            String formatedAddress, streetNumber, route, subLocality, locality, administrativeAreaL1, country, postalCode;

            if (responseParsed != null && responseParsed.status == 'OK' && responseParsed.results != null && !responseParsed.results.isEmpty()) {
                formatedAddress = responseParsed.results[0].formatted_address;
                if (responseParsed.results[0].geometry != null && responseParsed.results[0].geometry.location != null) {
                    latitude = responseParsed.results[0].geometry.location.lat;
                    longitude = responseParsed.results[0].geometry.location.lng;
                }
                if (responseParsed.results[0].address_components != null && !responseParsed.results[0].address_components.isEmpty()) {
                    for (AddressComponent cmp : responseParsed.results[0].address_components) {
                        Set<String> typesSet = new Set<String>(cmp.types);
                        if (typesSet.contains('street_number')) streetNumber = cmp.long_name;
                        if (typesSet.contains('route')) route = cmp.long_name;
                        if (typesSet.contains('sublocality')) subLocality = cmp.long_name;
                        if (typesSet.contains('locality')) locality = cmp.long_name;
                        if (typesSet.contains('administrative_area_level_1')) administrativeAreaL1 = cmp.short_name;
                        if (typesSet.contains('country')) country = cmp.long_name;
                        if (typesSet.contains('postal_code')) postalCode = cmp.long_name;
                    }
                }
            }

            if (latitude == null || longitude == null){
                throw new vertic_Structs.InvalidDataException('Unable to geocode address.');
            }

            this.response.put('location', Location.newInstance(latitude, longitude));
            this.response.put('formatedAddress', formatedAddress);
            this.response.put('numberAndStreet', streetNumber + ' ' + route);
            this.response.put('city', locality);
            this.response.put('postcode', postalCode);
            this.response.put('country', country);
            if (String.isNotEmpty(subLocality)) this.response.put('suburb', subLocality);
            if (String.isNotEmpty(administrativeAreaL1) && administrativeAreaL1 != locality) this.response.put('state', administrativeAreaL1);
        } catch (Exception ex) {
            ex.setMessage('Error Geocoding Address - ' + ex.getMessage());

            this.response = new vertic_Response(ex);
        } finally {
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


    public class MapsGeocodeResponse {
        public List<GeocodeResult> results;
        public String status;
    }
    public class GeocodeResult {
        public List<AddressComponent> address_components;
        public String formatted_address;
        public Geometry geometry;
        public String place_id;
        public List<String> types;
    }
    public class AddressComponent {
        public String long_name;
        public String short_name;
        public List<String> types;
    }
    public class Geometry {
        public GeometryLocation location;
    }
    public class GeometryLocation {
        public Double lat;
        public Double lng;
    }
}