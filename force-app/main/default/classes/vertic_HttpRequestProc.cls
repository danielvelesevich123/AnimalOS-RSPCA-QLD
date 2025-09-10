public class vertic_HttpRequestProc extends vertic_AbstractProcessor {

    @AuraEnabled
    public static void test(Blob b) {

    }

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.sendRequest();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void sendRequest() {

        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint(this.request.getString('endpoint'));
        req.setMethod(vertic_Utils.objects.defaultIfNull(this.request.getString('method'), 'GET'));

        String body = (String) this.request.getMap().get('body');
        if (body != null) {
            req.setBody(body);
            System.debug(body);
            System.debug(body.length());
        } else if (this.request.has('base64Encoded')) {
            String base64Data = EncodingUtil.urlDecode(this.request.getString('base64Encoded'), 'UTF-8');
            Blob blobBody = EncodingUtil.base64Decode(base64Data);
            req.setBodyAsBlob(blobBody);

            System.debug('BlobBody');
            System.debug(blobBody);
        }

        Map<String, Object> headers = (Map<String, Object>) this.request.get('headers');
        if (headers != null) {
            for (String header : headers.keySet()) {
                req.setHeader(header, '' + headers.get(header));
            }
        }
        HttpResponse resp = new Http().send(req);


//
//        Map<String, Object> responseHeaders = (Map<String, Object>) resp.getHeaderKeys();
//        if (responseHeaders != null) {
//            for (String responseHeader : responseHeaders.keySet()) {
//                this.response.getMapper().mapAnyValue('headers', responseHeaders.get(responseHeader));
//            }
//        }


        Map<String, Object> responseHeadersMap = new Map<String, Object>();
        for (String responseHeader : resp.getHeaderKeys()) {
            responseHeadersMap.put(responseHeader, resp.getHeader(responseHeader));
        }
        this.response.getMapper().mapAnyValue('headers', responseHeadersMap);

        this.response.getMapper().mapAnyValue('response', resp.getBody());

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