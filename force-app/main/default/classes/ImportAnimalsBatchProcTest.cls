@IsTest
private class ImportAnimalsBatchProcTest {

    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{ "LastUpdateDateTimeUtc": "2023-07-21T17:57:41.2172461Z","contact": {\n' +
                '        "firstName": "test",\n' +
                '        "lastName": "TestF",\n' +
                '        "email": "test@test.test",\n' +
                '        "phone": "0404123123",\n' +
                '        "Person_of_Interest__c": true,\n' +
                '        "MailingCountry": "AU",\n' +
                '        "ShelterBuddy_ID_PID__c": "176999",\n' +
                '        "Last_ShelterBuddy_Sync_String__c": "2023-04-17"\n' +
                '    }}';



            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    static testMethod void testBehavior() {
        Test.setMock(HttpCalloutMock.class, new RestMock());

        Test.startTest();

        vertic_Response verticResponse = new ImportAnimalsBatchProc().process(
            new Map<String, Object>{
                'page' => 1,
                'pageSize' => 10,
                'startIndex' => 0
            }
        );

        Test.stopTest();
    }

}