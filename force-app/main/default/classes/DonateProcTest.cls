@IsTest
private class DonateProcTest {

    @IsTest
    static void testMetaProc() {
        Test.startTest();

        vertic_Response verticResponse = new DonateMetaProc().process(
            new Map<String, Object>{

            }
        );

        Test.stopTest();
    }

    public with sharing class RestMock implements HttpCalloutMock {

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

    @IsTest
    static void testSubmitProc() {

//        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        new DonateSubmitProc().process(
            new vertic_Request(
                new Map<String, Object>{
                    'amount' => 12,
                    'paymentMethodId' => 'Credit Card',
                    'campaignName' => 'Test',
                    'addressData' => new Map<String, Object>{
                        'name' => 'Test Name',
                        'email' => 'test@gmail.com',
                        'address' => new Map<String, Object>{
                            'city'=> 'Canberra',
                            'line1' => '17 Cave',
                            'line2' => 'Place',
                            'country' => 'Australia',
                            'postal_code' => '4523',
                            'state' => 'NSW'
                        }
                    }

                }
            )
        );

//        test.stopTest();

    }
}