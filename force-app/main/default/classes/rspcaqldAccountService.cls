public with sharing class rspcaqldAccountService {
    @AuraEnabled
    public static List<AccountWrapper> getLocationAccounts(String location) {
        List<AccountWrapper> accounts = new List<AccountWrapper>();
        List<Account> accountList = new rspcaqldAccountSelector().getLocationAccounts();
        for (Account accnt : accountList) {
            accounts.add(new AccountWrapper(accnt, location));
        }
        return accounts;
    }

    @AuraEnabled(cacheable=true)
    public static AccountWrapper getLocationAccount(String recordId) {
        Account accnt = new rspcaqldAccountSelector().getAccountById(recordId);
        return new AccountWrapper(accnt);
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> getAccountByIds(List<String> recordIds) {
        List<AccountWrapper> accounts = new List<AccountWrapper>();
        List<Account> accountList = new rspcaqldAccountSelector().getAccountByIds(recordIds);
        for (Account accnt : accountList) {
            accounts.add(new AccountWrapper(accnt));
        }
        return accounts;
    }

    public class AccountWrapper {
        @AuraEnabled public Account record;
        @AuraEnabled public String locationCard;
        @AuraEnabled public String locationSingle;
        @AuraEnabled public String link;
        @AuraEnabled public String name;
        @AuraEnabled public String services;
        @AuraEnabled public String locationTypesString;
        @AuraEnabled public Decimal distance;
        @AuraEnabled public Decimal defaultDistance;
        @AuraEnabled public Boolean isPetbarn;
        @AuraEnabled public List<LocationType> locationTypes;
        @AuraEnabled public List<String> imagesUrls;

        public AccountWrapper(Account record) {
            this.init(record);
        }

        public AccountWrapper(Account record, String coords) {
            this.init(record);
            this.initLocation(record, coords);
        }

        private void init(Account record) {
            this.record = record;
            this.name = record.Name;
            this.link = '/about-us/rspca-locations/rspca-location?id=' + this.record.Id;
            this.services = String.isNotEmpty(record.Services_Offered__c) ? record.Services_Offered__c.replaceAll(';', ', ') : '';
            this.initLocationString();
            this.initLocationTypes();
            this.initImages();
        }

        private void initLocation(Account record, String coords) {
            this.distance = 0;

            if (coords != null && record.Geolocation__c != null) {
                Map<String, Object> coordsMap = (Map<String, Object>) JSON.deserializeUntyped(coords);
                Location myLocation = Location.newInstance((Decimal) Double.valueOf(coordsMap.get('myLatitude')), (Decimal) Double.valueOf(coordsMap.get('myLongitude')));
                this.distance = Location.getDistance(myLocation, record.Geolocation__c, 'km');
                this.distance = this.distance.setScale(2);
            }
            this.defaultDistance = this.distance;
        }

        private void initLocationString() {
            this.locationCard = String.format('{0}, {1}, {2}, {3}', new List<String>{this.record.ShippingStreet, this.record.ShippingCity, this.record.ShippingState, this.record.ShippingPostalCode});
            this.locationSingle = String.format('{0},\n {1} {2} {3}', new List<String>{this.record.ShippingStreet, this.record.ShippingCity, this.record.ShippingState, this.record.ShippingPostalCode});
        }

        private void initLocationTypes() {
            this.isPetbarn = false;
            this.locationTypes = new List<LocationType>();
            this.locationTypesString = '';
            List<String> locationTypeList = String.isNotEmpty(this.record.Location_Type__c) ? this.record.Location_Type__c.split(';') : new List<String>();

            for (String locationType : locationTypeList) {
                if (locationType == 'Cat Adoption') this.isPetbarn = true;
                this.locationTypes.add(new LocationType(locationType));
                this.locationTypesString += locationType + ',';
            }
        }

        private void initImages() {
            this.imagesUrls = new List<String>();
            if (String.isNotEmpty(this.record.Location_Image__c)) this.imagesUrls.add(this.record.Location_Image__c);
            if (String.isNotEmpty(this.record.Other_Location_Images__c)) this.imagesUrls.addAll(this.record.Other_Location_Images__c.split(','));
        }
    }

    public class LocationType {
        @AuraEnabled public String label;
        @AuraEnabled public String icon;

        public LocationType(String label) {
            this.label = label;
            this.icon = 'normal fa-solid fa-map-marker-alt';
        }
    }
}