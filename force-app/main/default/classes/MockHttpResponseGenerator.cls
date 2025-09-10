@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    private Map<String, String> endpointResponseMap;
    private String method;
    private Integer statusCode;
    global MockHttpResponseGenerator(Map<String, String> endpointResponseMap, String method, Integer statusCode){
        this.endpointResponseMap = endpointResponseMap;
        this.method = method;
        this.statusCode = statusCode;
    }
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        for (String endpoint : endpointResponseMap.keySet()) {
            if(req.getEndpoint().containsIgnoreCase(endpoint)){
                res.setBody(endpointResponseMap.get(endpoint));
                res.setStatusCode(statusCode);
                return res;
            }
        }
        throw new vertic_Structs.ProcessException('No Mock endpoint: ' + req.getEndpoint());
    }
}