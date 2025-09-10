@IsTest
private class ShelterBuddyTest {
    static testMethod void testShelterBuddyAPIUtils() {


    }

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

    static testMethod void testShelterBuddyDispatchPersonProc() {


        Account accountVar = new Account(
            Name = 'test'
        );
        insert accountVar;

        Contact contactVar = new Contact(
            LastName='test',
            FirstName = 'TestF',
            Email='test@test.test',
            AccountId = accountVar.Id,
            Person_of_Interest__c = true,
            ShelterBuddy_ID_PID__c = '3twet32',
            POI_Updated_Date__c = Datetime.newInstance(2020,02,17)
        );
        insert contactVar;

        Test.setMock(HttpCalloutMock.class, new RestMock());

        Test.startTest();

        vertic_Response verticResponse = new ShelterBuddyDispatchPersonProc().process(
            new Map<String, Object>{
                'recordId' => contactVar.Id
            }
        );

        Test.stopTest();

    }

    static testMethod void testShelterBuddyGetAnimalsProc() {


        Test.setMock(HttpCalloutMock.class, new RestMock());

        Test.startTest();

        vertic_Response verticResponse = new ShelterBuddyGetAnimalsProc().process(
            new Map<String, Object>{
                'page' => 1,
                'pageSize' => 10,
                'startIndex' => 0
            }
        );

        Test.stopTest();
    }

    static testMethod void testShelterBuddyGetPersonsProc() {


        Test.setMock(HttpCalloutMock.class, new RestMock());

        Test.startTest();

        vertic_Response verticResponse = new ShelterBuddyGetPersonsProc().process(
            new Map<String, Object>{
                'page' => 1,
                'pageSize' => 10,
                'startIndex' => 0
            }
        );

        Test.stopTest();
    }

    static testMethod void testShelterBuddySyncPersonProc() {


        Account accountVar = new Account(
            Name = 'test'
        );
        insert accountVar;

        Contact contactVar = new Contact(
            LastName='test',
            FirstName = 'TestF',
            Email='test@test.test',
            AccountId = accountVar.Id,
            Person_of_Interest__c = true,
            ShelterBuddy_ID_PID__c = '176999',
            POI_Updated_Date__c = Datetime.newInstance(2020,02,17),
            Last_ShelterBuddy_Sync_String__c =  '2023-04-17',
            MailingPostalCode = '22515'
        );
        insert contactVar;

        Suburb__c suburbVar = new  Suburb__c(
            StateId__c = 'Queensland',
            Postcode__c = '22515'
        );
        insert suburbVar;

        Test.setMock(HttpCalloutMock.class, new RestMock());

        Test.startTest();

        vertic_Response verticResponse = new ShelterBuddySyncPersonProc().process(
            new Map<String, Object>{
                'recordId' => contactVar.Id
            }
        );

        Test.stopTest();

    }


}