@IsTest
global class MockWebServiceResponseGenerator implements WebServiceMock{

    private Object element;
    global MockWebServiceResponseGenerator(Object element){
        this.element = element;
    }

    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {

        response.put('response_x', this.element);
    }
}