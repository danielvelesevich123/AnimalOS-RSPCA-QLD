@IsTest
private class rspcaqldAccountTest {
    @IsTest
    static void rspcaqldAccountTest() {
        List<Account> accntList = new List<Account>();
        Account accntOne = new Account(
            Name = 'Test Location',
            Phone = '0112341234',
            Services_Offered__c = 'Adoption',
            Location_Type__c = 'Op Shop',
            ShippingStreet = 'Test Street',
            ShippingCity = 'Test City',
            ShippingPostalCode = '4040',
            ShippingState = 'QLD',
            Geolocation__Latitude__s = -27.9329555,
            Geolocation__Longitude__s = 153.3803177,
            RecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Location').getRecordTypeId()
        );
        accntList.add(accntOne);

        Account accntTwo = new Account(
            Name = 'Test Location 2',
            Phone = '0112341234',
            Services_Offered__c = 'Cat Adoption',
            Location_Type__c = 'Pet Training',
            ShippingStreet = 'Test Street',
            ShippingCity = 'Test City',
            ShippingPostalCode = '4040',
            ShippingState = 'QLD',
            Geolocation__Latitude__s = -27.9329555,
            Geolocation__Longitude__s = 153.3803177,
            RecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Location').getRecordTypeId()
        );
        accntList.add(accntTwo);

        insert accntList;

        Test.startTest();
        Map<String, Double> coordsMap = new Map<String, Double> {
            'myLatitude' => -27.9329555,
            'myLongitude' => 153.3803177
        };
        List<rspcaqldAccountService.AccountWrapper> locationList = rspcaqldAccountService.getLocationAccounts(JSON.serialize(coordsMap));
        System.assertEquals(2, locationList.size());

        rspcaqldAccountService.AccountWrapper location = rspcaqldAccountService.getLocationAccount(accntOne.Id);
        System.assertEquals(accntOne.Id, location.record.Id);

        List<String> recordIds = new List<String>();
        for (Account accnt : accntList) {
            recordIds.add(accnt.Id);
        }
        List<rspcaqldAccountService.AccountWrapper> accountList = rspcaqldAccountService.getAccountByIds(recordIds);
        System.assertEquals(2, accountList.size());

        Test.stopTest();
    }
}