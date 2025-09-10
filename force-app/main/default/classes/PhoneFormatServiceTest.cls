@isTest
private class PhoneFormatServiceTest {

    @isTest
    static void testFormatPhone() {
        List<String> mobilePhoneList = new List<String> {
            '412345678'
            , '012345678'
            , '0123456789'
            , '0412345678'
            , '1300123456'
            , '1800123456'
            , '61123456789'
            , '01234567890'
        };

        List<String> outputList = new List<String>();

        for (String phoneItem : mobilePhoneList) {
            outputList.add(PhoneFormatService.formatPhone(phoneItem));
        }

        System.assertEquals(mobilePhoneList.size(), outputList.size());
    }
}