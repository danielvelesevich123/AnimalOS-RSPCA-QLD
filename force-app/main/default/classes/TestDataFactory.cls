public without sharing class TestDataFactory {

    public static Contact getContact(String lastName) {
        return new Contact(FirstName = 'test', lastName = lastName);
    }

    public static Contact getContact(String lastName, String shetterBuddyId) {
        return new Contact(
            FirstName = 'Test',
            LastName = lastName,
            ShelterBuddy_ID_PID__c = shetterBuddyId
        );
    }

    public static Contact getContactWithPhones(String lastName, String mobilePhone) {
        return new Contact(
            FirstName = 'Test',
            LastName = lastName,
            MobilePhone = mobilePhone,
            npe01__WorkPhone__c = '0500000000'
        );
    }

    public static Opportunity getOpportunity(Id primaryContactId, String name, String stage, Date closeDate) {
        return new Opportunity(
            npsp__Primary_Contact__c = primaryContactId,
            Name = name,
            StageName = stage,
            CloseDate = closeDate
        );
    }

    public static Animal__c getAnimal(String shetterBuddyId) {
        return new Animal__c(Shelterbuddy_ID__c = shetterBuddyId);
    }
}