@IsTest
private class rspcaqldPageWelfareComplaintCtrlTest {
    @IsTest
    static void rspcaqldPageWelfareComplaintCtrlTest() {
        Map<String, Object> contactMap = new Map<String, Object>{
            'firstName' => 'Test',
            'lastName' => 'Contact',
            'email' => 'test@email.com',
            'phone' => '0112341234',
            'alternatePhone' => '0112341234',
            'street' => 'Test Street',
            'state' => 'QLD',
            'city' => 'Brisbane',
            'postalCode' => '1234',
            'country' => 'Australia',
            'birthdate' => '2000-02-02'
        };

        Map<String, Object> caseMap = new Map<String, Object>{
            'marketingOptIn' => true
        };

        Map<String, Object> welfareMap = new Map<String, Object>{
            'poiAgeDeclaration' => 'Yes',
            'firstName' => 'First',
            'lastName' => 'Last',
            'establishmentName' => 'Test test',
            'personOfInterest' => 'Family member',
            'locationHouseNumber' => '10',
            'locationStreet' => 'Street',
            'locationCity' => 'Brisbane',
            'locationState' => 'QLD',
            'locationPostcode' => '1234',
            'geolocation' => '123456',
            'poiDescription' => 'Test test',
            'inspectorHazard' => 'Test test',
            'directions' => 'Test test',
            'observations' => 'Test test',
            'animalsNumber' => '10',
            'animalDescription' => 'Test test',
            'injuries' => 'Test test',
            'date' => '2000-02-02',
            'time' => '12:30am',
            'lastSeenDate' => '2000-02-02',
            'lastSeenTime' => '12:30am'
        };

        ContentVersion cv = new ContentVersion(
            VersionData = Blob.valueOf('test'),
            PathOnClient = 'test.jpeg',
            Title = 'test.jpeg'
        );
        insert cv;
        List<rspcaqldPageWelfareComplaintCtrl.FileWrapper> fwList = new List<rspcaqldPageWelfareComplaintCtrl.FileWrapper>{};
        rspcaqldPageWelfareComplaintCtrl.FileWrapper fw = new rspcaqldPageWelfareComplaintCtrl.FileWrapper();
        fw.name = 'test.jpeg';
        fw.contentVersionId = cv.Id;
        fwList.add(fw);

        Test.startTest();
        rspcaqldPageWelfareComplaintCtrl.doSubmit(JSON.serialize(contactMap), JSON.serialize(caseMap), JSON.serialize(welfareMap), JSON.serialize(fwList), JSON.serialize(fwList));
        Test.stopTest();
    }
}