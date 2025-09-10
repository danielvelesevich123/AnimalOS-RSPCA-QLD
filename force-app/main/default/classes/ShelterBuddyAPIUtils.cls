public with sharing class ShelterBuddyAPIUtils {
    private String endpoint;
    private String token;
    private String username;
    private String password;

    private static final String documentName = 'SB_AUTH_TOKEN';


    public ShelterBuddyAPIUtils() {

        Shelter_Buddy__mdt shelterBuddy = (Shelter_Buddy__mdt) vertic_SettingService.getMetadataType(Shelter_Buddy__mdt.SObjectType, 'Default');
        this.endpoint = shelterBuddy.Endpoint__c;
        this.token = shelterBuddy.Token__c;
        this.username = shelterBuddy.Username__c;
        this.password = shelterBuddy.Password__c;

        if(Test.isRunningTest()){
            this.token = 'test';
        } else{
            this.token = [SELECT Id, Body FROM Document WHERE DeveloperName = :documentName LIMIT 1].Body.toString();
        }

        System.debug(this.token);

    }

    public HttpResponse commonRequest(String callMethod, String requestBody) {
        return commonRequest(callMethod, new List<String>{
        }, requestBody);
    }

    public HttpResponse commonRequest(String callMethod, List<String> endpointParams, String requestBody) {
        return commonRequest(callMethod, endpointParams, requestBody, true);
    }

    public HttpResponse commonRequest(String callMethod, List<String> endpointParams, String requestBody, Boolean isSaveToken) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('sb-auth-token', this.token);

        HttpResponse response = new HttpResponse();
        switch on callMethod {
            when 'getPerson' {
                response = getPerson(request, endpointParams);
            }
            when 'getPersonList' {
                response = personList(request, endpointParams);
            }
            when 'getAnimalList' {
                response = animalList(request, endpointParams, requestBody);
            }
            when 'getPhotosList'{
                response = photosList(request, endpointParams, requestBody);
            }
            when 'getAnimal' {
                response = getAnimal(request, endpointParams);
            }
            when 'postPerson' {
                response = postPerson(request, requestBody);
            }
            when 'putPerson' {
                response = putPerson(request, requestBody);
            }
            when 'getOwnerHistory' {
                response = getOwnerHistory(request, requestBody);
            }
            when 'getDispatchPerson' {
                response = getDispatchPerson(request, endpointParams);
            }
            when 'deletePerson' {
                response = deletePerson(request, endpointParams);
            }
        }

        System.debug(request.getHeader('Accept'));
        System.debug(request.getHeader('Content-Type'));
        System.debug(request.getHeader('sb-auth-token'));
        System.debug(request);
        System.debug(response.getStatus());
        System.debug(response.getBody());

        if (response.getStatusCode() != 200
            && response.getBody() != ''
            && ((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('Message') == 'Authorization has been denied for this request.') {
            this.token = getAuthToken();
            return commonRequest(callMethod, endpointParams, requestBody, isSaveToken);
        } else {
            Map<String, Object> tokenMap = new Map<String, Object>();
            tokenMap.put('Token__c', this.token);
            if (!Test.isRunningTest() && isSaveToken == true) {
//                vertic_SettingService.setMetadataTypeAsync(Shelter_Buddy__mdt.SObjectType, 'Default', 'Default', tokenMap);
            }
        }
        return response;
    }

    private String getAuthToken() {
        HttpRequest request = new HttpRequest();
        Shelter_Buddy__mdt shelterBuddy = (Shelter_Buddy__mdt) vertic_SettingService.getMetadataType(Shelter_Buddy__mdt.SObjectType, 'Default');

        request.setMethod('GET');
        request.setEndpoint(this.endpoint + '/authenticate?username=' + this.username + '&password=' + this.password);
        request.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml');
        request.setHeader('Content-Type', 'application/json');

        HttpResponse response = new Http().send(request);
        return (String) JSON.deserializeUntyped(response.getBody());
    }

    private HttpResponse getPerson(HttpRequest request, List<String> params) {
        request.setMethod('GET');
        request.setEndpoint(this.endpoint + '/person/' + params[0]);

        HttpResponse response = new Http().send(request);

        return response;
    }

    private HttpResponse personList(HttpRequest request, List<String> params) {
        request.setMethod('GET');
        request.setEndpoint(String.format('{0}/person/list?page={1}&pageSize={2}&startIndex={3}', new List<String>{
            this.endpoint,
            params[0],
            params[1],
            params[2]
        }));

        HttpResponse response = new Http().send(request);

        return response;
    }

    private HttpResponse animalList(HttpRequest request, List<String> params, String requestBody) {
        request.setMethod('POST');
        request.setEndpoint(String.format('{0}/animal/list?page={1}&pageSize={2}&startIndex={3}', new List<String>{
            this.endpoint,
            params[0],
            params[1],
            params[2]
        }));

        if (String.isNotBlank(requestBody)) {
            request.setBody(requestBody);
        }

        request.setTimeout(120000);

        HttpResponse response = new Http().send(request);

        return response;
    }

    private HttpResponse photosList(HttpRequest request, List<String> params, String requestBody) {
        request.setMethod('POST');
        request.setEndpoint(String.format('{0}/animal/photo/list?page={1}&pageSize={2}&startIndex={3}', new List<String>{
                this.endpoint,
                params[0],
                params[1],
                params[2]
        }));

        if (String.isNotBlank(requestBody)) {
            request.setBody(requestBody);
        }

        HttpResponse response = new Http().send(request);

        return response;
    }

    private HttpResponse getAnimal(HttpRequest request, List<String> params) {
        request.setMethod('GET');
        request.setEndpoint(this.endpoint + '/animal/' + params[0]);

        HttpResponse response = new Http().send(request);

        return response;
    }

    public HttpResponse postPerson(HttpRequest request, String requestBody) {
        request.setMethod('POST');
        request.setEndpoint(this.endpoint + '/person');
        request.setBody(requestBody);

        HttpResponse response = new Http().send(request);

        System.debug(response);

        return response;
    }

    public HttpResponse putPerson(HttpRequest request, String requestBody) {
        request.setMethod('PUT');
        request.setEndpoint(this.endpoint + '/person');
        request.setBody(requestBody);

        HttpResponse response = new Http().send(request);

        System.debug(response);

        return response;
    }

    public HttpResponse getOwnerHistory(HttpRequest request, String requestBody) {
        request.setMethod('POST');
        request.setEndpoint(this.endpoint + '/animal/ownerhistory/list?page=1&pageSize=30&startIndex=0');
        request.setBody(requestBody);

        HttpResponse response = new Http().send(request);

        System.debug(response);

        return response;
    }

    private HttpResponse getDispatchPerson(HttpRequest request, List<String> params) {
        request.setMethod('GET');
        request.setEndpoint(this.endpoint + '/dispatch/person/' + params[0]);

        HttpResponse response = new Http().send(request);

        return response;
    }

    public void saveAccessToken(){
        if(!Test.isRunningTest()){
            Document tokenDocument = [SELECT Id, Body FROM Document WHERE DeveloperName = :documentName LIMIT 1];
            tokenDocument.Body = Blob.valueOf(this.token);
            update tokenDocument;
        }
    }

    private HttpResponse deletePerson(HttpRequest request, List<String> params) {
        request.setMethod('DELETE');
        request.setEndpoint(this.endpoint + '/person/' + params[0]);

        HttpResponse response = new Http().send(request);

        return response;
    }

//    public HttpResponse getJurisdiction(List<String> params){
//        HttpRequest request = new HttpRequest();
//
//        request.setMethod('GET');
//        request.setEndpoint(this.endpoint + '/jurisdiction/' + params[0]);
//        request.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml');
//        request.setHeader('Content-Type', 'application/json');
//        request.setHeader('sb-auth-token', this.token);
//
//        HttpResponse response = new Http().send(request);
//
//        return response;
//    }
//
//    public HttpResponse getSpecies(List<String> params){
//        HttpRequest request = new HttpRequest();
//
//        request.setMethod('GET');
//        request.setEndpoint(this.endpoint + 'animal/species/' + params[0]);
//        request.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml');
//        request.setHeader('Content-Type', 'application/json');
//        request.setHeader('sb-auth-token', this.token);
//
//        HttpResponse response = new Http().send(request);
//
//        return response;
//    }
}