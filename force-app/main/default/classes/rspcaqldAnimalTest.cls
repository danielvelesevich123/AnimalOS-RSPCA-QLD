@IsTest
private class rspcaqldAnimalTest {
    @IsTest
    static void rspcaqldAnimalTest() {
        Account accnt = new Account(
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
        insert accnt;

        Animal_Breed__c animalBreed = new Animal_Breed__c(
            Name = 'Dog Breed'
        );
        insert animalBreed;

        Animal__c animalOne = new Animal__c(
            Animal_Name__c = 'Lucky Dog',
            Location__c = accnt.Id,
            Animal_Type__c = 'Dog',
            Animal_Breed__c = animalBreed.Id,
            Gender__c = 'Male',
            Web_Hero_Image_URL__c = 'test.com',
            Status__c = 'Available For Adoption',
            Date_of_Birth__c = Date.today()
        );
        insert animalOne;

        Animal__c animalTwo = new Animal__c(
            Featured__c = TRUE,
            Animal_Name__c = 'Lucky Dog',
            Location__c = accnt.Id,
            Animal_Type__c = 'Dog',
            Animal_Breed__c = animalBreed.Id,
            Gender__c = 'Male',
            Web_Hero_Image_URL__c = 'test.com',
            Status__c = 'Available For Adoption',
            Date_of_Birth__c = Date.today()
        );
        insert animalTwo;

        Test.startTest();

        rspcaqldAnimalService.Animal animal = rspcaqldAnimalService.getAnimalById(animalOne.Id);
        System.assertEquals(animalOne.Id, animal.record.Id);

        List<Animal__c> locationAnimals = rspcaqldAnimalService.getLocationAnimals(accnt.Id);
        System.assertEquals(2, locationAnimals.size());

        List<rspcaqldAnimalService.Animal> portalAnimals = rspcaqldAnimalService.getPortalActiveAnimals();
        System.assertEquals(2, portalAnimals.size());

        rspcaqldAnimalService.getAnimalBreeds();

        Test.stopTest();
    }
}