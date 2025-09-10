@isTest
public class HttpRequestProcTest {
    @isTest
    private static void test() {
        MockHttpResponseGenerator responseGenerator = new MockHttpResponseGenerator(
            new Map<String, String>{
                'callout:OneDrive/connections' => '[ { "id": "e82447cc-ce78-468f-b2c6-9af74c519ead", "tenantId": "83299b9e-5747-4a14-a18a-a6c94f824eb7", "tenantType": "ORGANISATION" } ]'
            }, 'GET', 200
        );

        Test.setMock(HttpCalloutMock.class, responseGenerator);

        Test.startTest();

        new vertic_HttpRequestProc().process(new vertic_Request(new Map<String, Object>{
            'endpoint' => 'callout:OneDrive/connections',
            'method' => 'GET',
            'headers' => new Map<String, Object>{
                'Content-Type' => 'application/json',
                'Accept' => 'application/json'
                 },
            'base64Encoded' => true
            }));

        Test.stopTest();
    }
}