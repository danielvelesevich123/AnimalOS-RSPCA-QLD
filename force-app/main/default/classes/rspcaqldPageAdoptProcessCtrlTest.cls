@IsTest
private class rspcaqldPageAdoptProcessCtrlTest {
    @IsTest
    static void rspcaqldPageAdoptProcessCtrlTest() {
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

        Map<String, Object> adoptionMap = new Map<String, Object>{
            'generalEnquiry' => 'I have a specific animal in mind',
            'animalLocation' => 'Bundaberg',
            'animalType' => 'Dog',
            'preferredAnimalType' => 'Dog',
            'shelterbuddyID' => '1234512345',
            'animalName' => 'Pet',
            'identificationType' => 'Driver\'s license',
            'secondContactName' => 'Martin',
            'secondContactPhone' => '0412341234',
            'adoptionTimeframe' => '24-48hrs',
            'adoptionReason' => 'Companion for me',
            'aloneHours' => 'Someone is usually home full time',
            'hasChildren' => 'Yes',
            'childrenDetails' => 'Children Details',
            'homeLifestyle' => 'Test test',
            'companionImportance' => 'Test test',
            'openToSuggest' => 'Yes',
            'residentialStatus' => 'Renter',
            'residenceType' => 'Test test',
            'animalHousing' => 'Test test',
            'fencing' => 'Test test',
            'hasOtherPets' => 'Yes',
            'otherPetsDetails' => 'Pets Details',
            'hasVisitPets' => 'Yes',
            'otherVisitDetails' => 'Test test',
            'previousPets' => 'Test test',
            'previousSurrended' => 'Yes',
            'previouslySurrendedDetails' => 'Test test'
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
        rspcaqldPageAdoptProcessCtrl.doSubmit(JSON.serialize(contactMap), JSON.serialize(caseMap), JSON.serialize(adoptionMap), JSON.serialize(fwList));
        Test.stopTest();
    }
}