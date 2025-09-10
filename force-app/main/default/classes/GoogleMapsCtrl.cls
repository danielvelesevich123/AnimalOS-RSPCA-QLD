public class GoogleMapsCtrl{
    public static String getGoogleMapsAPIKey() {
//		return 'AIzaSyAD6owjA4Gq7sVl5X0N8Vh7bSc4eiQlicA';
        return vertic_SettingService.getValue('GOOGLE_MAPS_API_KEY');

    }

    @AuraEnabled
    public static String getAddressAutoComplete(String input, String types) {
        String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='
            + EncodingUtil.urlEncode(input, 'UTF-8')
            + '&types=' + types
            + '&key=' + getGoogleMapsAPIKey()
            + '&components=country:AU';
        return getHttp(url);
    }

    @AuraEnabled
    public static String getAddressDetails(String placeId) {
        String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=' + placeId
            + '&key=' + getGoogleMapsAPIKey();
        return getHttp(url);
    }

    public static string getHttp(String strURL) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req);
        return res.getBody();
    }
}