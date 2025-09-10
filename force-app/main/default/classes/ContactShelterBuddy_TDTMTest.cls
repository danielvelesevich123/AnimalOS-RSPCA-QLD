@isTest
public without sharing class ContactShelterBuddy_TDTMTest {

    @TestSetup
    static void makeData() {
        TDTM_Manager.init();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(
            new Map<String, String>{
                '/authenticate' => 'token',
                '/person' => '{"LastUpdatedUtc":"2023-07-21T17:57:41.2172461Z","Salutations":[{"Text":"Austin Reeves","Type":{"Name":"Envelope individual","Uri":"/api/v2/person/salutation/type/1","Id":1},"Id":4837741},{"Text":"Reeves","Type":{"Name":"Dear formal individual","Uri":"/api/v2/person/salutation/type/2","Id":2},"Id":4837742},{"Text":"Austin","Type":{"Name":"Dear informal individual","Uri":"/api/v2/person/salutation/type/3","Id":3},"Id":4837743}],"MailingLists":[],"Categories":[],"BPayNumbers":[{"IsHistory":false,"Number":"1017685130"}],"Emails":[{"EmailAddress":"austin.reeves@vertic.com.au","IsPrimary":true,"IsVolunteerEmail":false,"Id":767560}],"ExternalIds":[],"OptInChoices":[],"Fax":{"PhoneNumber":null,"Type":null,"Extension":null,"IsPrimary":false,"Id":0},"HomePhone":{"PhoneNumber":"(03) 9560 7824","Type":{"Name":"Home","Id":1},"Extension":null,"IsPrimary":false,"Id":4643961},"MailingAddress":{"Country":{"Name":"Australia","Uri":"/api/v2/location/country/3","Id":3},"Jurisdiction":null,"State":{"Abbreviation":"QLD","Name":"Queensland","Uri":"/api/v2/location/state/1","Id":1},"StreetType":{"Name":"Street","Uri":"/api/v2/location/streetType/2","Id":2},"Suburb":{"Name":"NEWTOWN","Uri":"/api/v2/location/suburb/4114","Id":4114},"DeliveryType":null,"PrintableString":"5 Rothesay Avenue Street, NEWTOWN, QLD, 3184, Australia","PrintableStreetAddressString":"5 Rothesay Avenue Street, NEWTOWN, QLD, 3184, Australia","MetaData":[],"CrossStreet":null,"DirectionOne":null,"DirectionTwo":null,"ExtraAddressDetails":null,"Postcode":"3184","PostcodeSuffix":null,"StreetName":"Rothesay Avenue","StreetNumber":"5","UnitNumber":null,"DeliveryNumber":null,"IsApiValidated":false,"Line1":"5 Rothesay Avenue Street","Line2":null,"Line3":null,"Line4":null,"Id":7203824},"MatchedPhoneNumber":{"PhoneNumber":"(03) 9560 7824","Type":{"Name":"Home","Id":1},"Extension":null,"IsPrimary":false,"Id":4643961},"MobileNetwork":null,"MobilePhone":{"PhoneNumber":null,"Type":null,"Extension":null,"IsPrimary":false,"Id":0},"PhysicalAddress":{"Country":{"Name":"Australia","Uri":"/api/v2/location/country/3","Id":3},"Jurisdiction":null,"State":{"Abbreviation":"QLD","Name":"Queensland","Uri":"/api/v2/location/state/1","Id":1},"StreetType":{"Name":"Street","Uri":"/api/v2/location/streetType/2","Id":2},"Suburb":{"Name":"NEWTOWN","Uri":"/api/v2/location/suburb/4114","Id":4114},"DeliveryType":null,"PrintableString":"Rothesay Avenue Street, NEWTOWN, QLD, 3184, Australia","PrintableStreetAddressString":"Rothesay Avenue Street, NEWTOWN, QLD, 3184, Australia","MetaData":[],"CrossStreet":null,"DirectionOne":null,"DirectionTwo":null,"ExtraAddressDetails":null,"Postcode":"3184","PostcodeSuffix":null,"StreetName":"Rothesay Avenue","StreetNumber":null,"UnitNumber":null,"DeliveryNumber":null,"IsApiValidated":false,"Line1":"Rothesay Avenue Street","Line2":null,"Line3":null,"Line4":null,"Id":7203825},"RecordType":{"Name":"Person","Uri":"/api/v2/person/type/1","Id":1},"Relationships":[],"WorkPhone":{"PhoneNumber":null,"Type":null,"Extension":null,"IsPrimary":false,"Id":0},"PreferredMailingList":null,"InactiveReason":{"Name":"Made Inactive In Crm","Uri":"/api/v2/person/inactiveReason/17","Id":17},"AcquiredFrom":null,"MergedPersonIds":[],"MetaData":[{"Key":"Key1","Value":"Value1","Id":2473203}],"MajorDonorDetails":{"Notes":null},"DoNotAdopt":false,"IsDeleted":false,"Spouse":null,"Identification":{"IdNumber":null},"CanMail":false,"MailingListOptIn":{"Name":"No","Id":0},"CanSms":false,"CompanyName":null,"DateOfBirthUtc":"2022-10-10T14:00:00Z","DoNotCall":false,"DoNotEmail":false,"FirstName":"Austin","Gender":"Male","HonoraryTitle":null,"IsActive":false,"IsHeadOfHousehold":false,"IsProspectiveDonor":false,"LastName":"Reeves","MiddleName":null,"Nickname":null,"SmallNotes":null,"SpecialMessage":null,"Suffix":null,"Title":null,"WebAddress":null,"AllowPublicDisclosureOfContactInfo":true,"LastUpdateDateTimeUtc":"2023-07-21T17:57:41.2172461Z","Id":1768513}'
            },
            'POST',
            200
        ));
    }

    @isTest
    static void testInsert() {

        insert new Suburb__c(
            StateName__c = 'test',
            SuburbName__c = 'test',
            StateId__c = '1111',
            SuburbId__c = '1111'
        );

        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            contactList.add(new Contact(
                LastName = i + 'test',
                FirstName = i + 'test',
                Email = i + 'test@test.com',
                HomePhone = i + '12312312',
                Gender__c = 'Male',
                MailingStreet = 'test',
                MailingPostalCode = '1111',
                Birthdate = Date.today()
            ));
        }
        Test.startTest();
        insert contactList;
        Test.stopTest();

        System.assertEquals(contactList.size(), [SELECT COUNT() FROM Vertic_Async_Process__c WHERE Processor__c = 'ShelterBuddySyncPersonProc' AND Status__c = 'Pending']);
    }
}