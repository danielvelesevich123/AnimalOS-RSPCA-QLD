@isTest
public with sharing class ContactPhoneFormatComponentTest {
    
    @isTest
    static void testInsert() {
        Contact record = new Contact(
            FirstName = 'Jimmy',
            LastName = 'Reeve',
            MobilePhone = '0418333444',
            HomePhone = '0395607824'
        );
        
        ContactPhoneFormatComponent.ContactPhoneFormatRequest request = new ContactPhoneFormatComponent.ContactPhoneFormatRequest();
        request.record = record;

        Test.startTest();
        List<ContactPhoneFormatComponent.ContactPhoneFormatResponse> responseList =
            ContactPhoneFormatComponent.process(new List<ContactPhoneFormatComponent.ContactPhoneFormatRequest>{ request });
        Test.stopTest();
        
        ContactPhoneFormatComponent.ContactPhoneFormatResponse response = responseList[0];
        System.AssertEquals('0418 333 444', response.record.MobilePhone);
        System.AssertEquals('03 9560 7824', response.record.HomePhone);
    }
    
    @isTest
    static void testInsertInternationalMobile() {
        Contact record = new Contact(
            FirstName = 'Jimmy',
            LastName = 'Reeve',
            MobilePhone = '+61418333444'
        );
        
        ContactPhoneFormatComponent.ContactPhoneFormatRequest request = new ContactPhoneFormatComponent.ContactPhoneFormatRequest();
        request.record = record;

        Test.startTest();
        List<ContactPhoneFormatComponent.ContactPhoneFormatResponse> responseList =
            ContactPhoneFormatComponent.process(new List<ContactPhoneFormatComponent.ContactPhoneFormatRequest>{ request });
               
        ContactPhoneFormatComponent.ContactPhoneFormatResponse response = responseList[0];
        System.AssertEquals('0418 333 444', response.record.MobilePhone);
        
        request = new ContactPhoneFormatComponent.ContactPhoneFormatRequest();
        request.record = record;

        responseList =
            ContactPhoneFormatComponent.process(new List<ContactPhoneFormatComponent.ContactPhoneFormatRequest>{ request });
        Test.stopTest();
        
        response = responseList[0];
        System.AssertEquals('0418 333 444', response.record.MobilePhone);

    }
}