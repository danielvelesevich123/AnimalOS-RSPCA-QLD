@isTest
public without sharing class PersonUpsertWebhookInvocableTest {
    @isTest
    static void testInsert() {
        Test.startTest();
        process();
        Test.stopTest();

        List<Contact> contactList = [
            SELECT LastName
            FROM Contact
        ];
        System.assertEquals(1, contactList.size(), '1 contact should be inserted');
        System.assertEquals('test', contactList[0].LastName, 'LastName should be populated from invocable');
    }

    @isTest
    static void testUpdate() {
        List<Contact> contactList = new List<Contact>();
        for(Integer i = 0; i < 2; i++) {
            contactList.add(TestDataFactory.getContact('' + i, '' + i));
        }
        insert contactList;
        Test.startTest();
        process();
        Test.stopTest();

        contactList = [
            SELECT Email
            FROM Contact
        ];
        System.assertEquals(2, contactList.size(), '2 contacts should be in database');
        Boolean hasContactWithEmail = false;
        for(Contact contactVar : contactList) {
            if(contactVar.Email == 'test@test.com') {
                hasContactWithEmail = true;
                break;
            }
        }
        System.assert(hasContactWithEmail, 'Email should be populated from invocable');
    }

    private static void process() {
        PersonUpsertWebhookInvocable.InvocableRequest request = new PersonUpsertWebhookInvocable.InvocableRequest();
        request.requestJSON = '{"dto":{"LastUpdatedUtc":"2013-03-15T22:35:47.02Z","Salutations":[{"Text":"Miss Thomasina Schonewille","Type":{"Name":"Envelope individual","Uri":"/api/v2/person/salutation/type/1","Id":1},"Id":471850},{"Text":"MissSchonewille","Type":{"Name":"Dear formal individual","Uri":"/api/v2/person/salutation/type/2","Id":2},"Id":471851},{"Text":"Schonewille","Type":{"Name":"Dear informal individual","Uri":"/api/v2/person/salutation/type/3","Id":3},"Id":471852}],"MailingLists":[],"Categories":[{"Name":"Surrender","Uri":"/api/v2/person/category/5","Id":5},{"Name":"Wildlife","Uri":"/api/v2/person/category/22","Id":22},{"Name":"Adoption","Uri":"/api/v2/person/category/21","Id":21},{"Name":"Special Adoption","Uri":"/api/v2/person/category/30","Id":30},{"Name":"Stray","Uri":"/api/v2/person/category/41","Id":41}],"BPayNumbers":[{"IsHistory":false,"Number":"1001207974"}],"Emails":[{"EmailAddress":"test@test.com","IsPrimary":true}],"ExternalIds":[],"OptInChoices":[],"Fax":{"PhoneNumber":null,"Type":null,"Extension":null,"IsPrimary":false,"Id":0},"HomePhone":{"PhoneNumber":"07 0426 6241","Type":{"Name":"Home","Id":1},"Extension":null,"IsPrimary":false,"Id":393473},"MailingAddress":{"Country":{"Name":"Australia","Uri":"/api/v2/location/country/3","Id":3},"Jurisdiction":null,"State":{"Abbreviation":"QLD","Name":"Queensland","Uri":"/api/v2/location/state/1","Id":1},"StreetType":{"Name":"Street","Uri":"/api/v2/location/streetType/2","Id":2},"Suburb":{"Name":"THE GAP","Uri":"/api/v2/location/suburb/4581","Id":4581},"DeliveryType":null,"PrintableString":"15 Georganne Street, THE GAP, QLD, 4061, Australia","PrintableStreetAddressString":"15 Georganne Street, THE GAP, QLD, 4061, Australia","MetaData":[],"CrossStreet":null,"DirectionOne":"","DirectionTwo":"","ExtraAddressDetails":"","Postcode":"4061","PostcodeSuffix":null,"StreetName":"Georganne","StreetNumber":"15 ","UnitNumber":"","DeliveryNumber":"","IsApiValidated":false,"Line1":"15 Georganne Street","Line2":null,"Line3":null,"Line4":null,"Id":1328839},"MatchedPhoneNumber":{"PhoneNumber":"07 0426 6241","Type":{"Name":"Home","Id":1},"Extension":null,"IsPrimary":false,"Id":393473},"MobileNetwork":null,"MobilePhone":{"PhoneNumber":"04 0339 9844","Type":{"Name":"Mobile","Id":2},"Extension":null,"IsPrimary":false,"Id":981642},"PhysicalAddress":{"Country":{"Name":"Australia","Uri":"/api/v2/location/country/3","Id":3},"Jurisdiction":null,"State":{"Abbreviation":"QLD","Name":"Queensland","Uri":"/api/v2/location/state/1","Id":1},"StreetType":{"Name":"Street","Uri":"/api/v2/location/streetType/2","Id":2},"Suburb":{"Name":"THE GAP","Uri":"/api/v2/location/suburb/4581","Id":4581},"DeliveryType":null,"PrintableString":"15 Georganne Street, THE GAP, QLD, 4061, Australia","PrintableStreetAddressString":"15 Georganne Street, THE GAP, QLD, 4061, Australia","MetaData":[],"CrossStreet":null,"DirectionOne":"","DirectionTwo":"","ExtraAddressDetails":"","Postcode":"4061","PostcodeSuffix":null,"StreetName":"Georganne","StreetNumber":"15 ","UnitNumber":"","DeliveryNumber":"","IsApiValidated":false,"Line1":"15 Georganne Street","Line2":null,"Line3":null,"Line4":null,"Id":1328839},"RecordType":{"Name":"Person","Uri":"/api/v2/person/type/1","Id":1},"Relationships":[],"WorkPhone":{"PhoneNumber":"07 0066 7856","Type":{"Name":"Work","Id":3},"Extension":"","IsPrimary":false,"Id":1258786},"PreferredMailingList":null,"InactiveReason":null,"AcquiredFrom":null,"MergedPersonIds":[{"Id":126400}],"MetaData":[{"Key":"SalesforceId","Value":"0033B00000ByjAeQAJ","Id":1105807},{"Key":"SalesforceUpdatedTimestamp","Value":"2017-05-15T13:00:23.0000000Z","Id":1105815}],"MajorDonorDetails":{"Notes":null},"DoNotAdopt":false,"IsDeleted":false,"Spouse":{"Title":"","FirstName":"","LastName":""},"Identification":{"IdNumber":"12 900 464"},"CanMail":true,"MailingListOptIn":{"Name":"Yes","Id":1},"CanSms":false,"CompanyName":"","DateOfBirthUtc":"1969-03-10T14:00:00Z","DoNotCall":false,"DoNotEmail":true,"FirstName":"Thomasina","Gender":"Female","HonoraryTitle":"","IsActive":true,"IsHeadOfHousehold":false,"IsProspectiveDonor":false,"LastName":"test","MiddleName":"Therese","Nickname":"","SmallNotes":"","SpecialMessage":"","Suffix":"","Title":"Miss","WebAddress":"","AllowPublicDisclosureOfContactInfo":true,"LastUpdateDateTimeUtc":"2013-03-15T22:35:47.02Z","Id":1}}';
        List<PersonUpsertWebhookInvocable.InvocableRequest> requests = new List<PersonUpsertWebhookInvocable.InvocableRequest> {
            request
        };
        PersonUpsertWebhookInvocable.process(requests);
    }
}