@isTest
public without sharing class AnimalUpsertWebhookInvocableTest {
    @isTest
    static void testInsert() {
        Test.startTest();
        process();
        Test.stopTest();

        List<Animal__c> animalList = [
            SELECT Sub_Status__c
            FROM Animal__c
        ];
        System.assertEquals(1, animalList.size(), '1 animal should be inserted');
        System.assertEquals('Test', animalList[0].Sub_Status__c, 'Sub_Status__c should be populated from invocable');
    }

    @isTest
    static void testUpdate() {
        List<Animal__c> animalList = new List<Animal__c>();
        for(Integer i = 0; i < 2; i++) {
            animalList.add(TestDataFactory.getAnimal('' + i));
        }
        insert animalList;
        Test.startTest();
        process();
        Test.stopTest();

        animalList = [
            SELECT Sub_Status__c
            FROM Animal__c
        ];
        System.assertEquals(2, animalList.size(), '2 animals should be in database');
        Boolean hasContactWithSubStatus = false;
        for(Animal__c animalVar : animalList) {
            if(animalVar.Sub_Status__c == 'Test') {
                hasContactWithSubStatus = true;
                break;
            }
        }
        System.assert(hasContactWithSubStatus, 'Email should be populated from invocable');
    }

    private static void process() {
        AnimalUpsertWebhookInvocable.InvocableRequest request = new AnimalUpsertWebhookInvocable.InvocableRequest();
        request.requestJSON = '{"dto":{"Id":1,"DueDateOutUtc":null,"DistinguishingFeatures":"owner describes the colour as tan brindle. white on the paws. dog is chipped (number unknown) wearing a black pink collar.","Media":null,"Behaviour":null,"RelatedAnimals":null,"MetaData":[],"Weight":"","Icons":null,"IsDeleted":false,"DateLostUtc":"2013-12-10T14:00:00Z","DateFoundUtc":"2014-12-10T14:00:00Z","LostFoundAddress":{"Id":4970823,"Line4":null,"Line3":null,"Line2":null,"Line1":"mcfar","IsApiValidated":false,"DeliveryNumber":"","UnitNumber":"","StreetNumber":"15","StreetName":"Test StreetName","PostcodeSuffix":null,"Postcode":"4504","ExtraAddressDetails":"mcfar","DirectionTwo":"","DirectionOne":"","CrossStreet":"","MetaData":[],"PrintableStreetAddressString":"mcfar, NARANGBA, QLD, 4504, Australia","PrintableString":"mcfar, NARANGBA, QLD, 4504, Australia","DeliveryType":null,"Suburb":{"Id":4085,"Uri":"/api/v2/location/suburb/4085","Name":"NARANGBA"},"StreetType":null,"State":{"Id":1,"Uri":"/api/v2/location/state/1","Name":"Queensland","Abbreviation":"QLD"},"Jurisdiction":{"Id":188,"Uri":"/api/v2/jurisdiction/188","Name":"Moreton Bay Regional - Caboolture District"},"Country":{"Id":3,"Uri":"/api/v2/location/country/3","Name":"Australia"}},"DangerousAnimalInformation":null,"Origin":null,"RabiesTag":null,"Litters":null,"CurrentRabiesVaccination":null,"DateOfWeighingUtc":null,"AvailableForAdoptionDateUtc":"1900-01-01T00:00:00Z","Type":{"Id":3,"Uri":"/api/v2/animal/species/type/3","Name":"Dog"},"SubStatuses":[],"SubStatus":{"Name":"Test"},"Status":{"Id":47,"Uri":"/api/v2/animal/status/47","Name":"Lost","DateUtc":"2013-12-11T05:34:00Z"},"Size":"Medium","Sex":{"Id":2,"Uri":"/api/v2/animal/gender/2","Name":"Female"},"Pattern":null,"Owner":{"Id":1065236,"Uri":"/api/v2/person/1065236","Name":"Bing Rohlf"},"Medical":{"PreviousMedicalDetails":null,"PreferredFood":null,"DateSpayedNeuteredUtc":null,"SpayedNeutered":"Yes","IsVaccinated":true,"IsDeclawed":false},"Location":{"MostRecentPhysicalLocation":{"Id":49,"Uri":"/api/v2/location/physicallocation/49","Name":"Wacol Animal Care Campus"},"Shelter":null,"Kennel":null,"PhysicalLocation":null},"LastUpdatedUtc":"2022-08-23T23:24:16.477Z","Intake":{"EmergencyBoardingReason":null,"BehaviourCondition":null,"SurrenderReason":null,"Received":null,"ExtendedDetails":null,"Source":null,"Region":null,"DateUtc":null},"Identification":{"OldDatabaseNumber":null,"CollarColour":"Black","CustomTag":null,"ShelterTag":null,"Barcode":null,"CollarType":{"Id":297,"Name":"Leather"},"TagColour":null,"AcoNumber":null,"OtherIdentification":null,"SecondaryMicrochipImplantDateUtc":null,"SecondaryMicrochipBrand":null,"SecondaryMicrochipNumber":null,"PrimaryMicrochipImplantDateUtc":null,"PrimaryMicrochipBrand":null,"PrimaryMicrochipNumber":null,"HasMicrochip":false},"Features":{"EyeColour":{"Id":2,"Name":"Brown"},"TailType":{"Id":2136,"Uri":"/api/v2/animal/tailtype/2136","Name":"Full"},"EarType":null,"CoatType":"Short","SecondaryColour":"White","PrimaryColour":"Tan","CoatLength":"Short"},"ContactLocation":{"Id":49,"Uri":"/api/v2/location/physicallocation/49","Name":"Wacol Animal Care Campus"},"BreederRegistrationNumber":null,"Breed":{"IsCrossBreed":true,"SecondarySpecies":{"Id":175,"Uri":"/api/v2/animal/species/175"},"Secondary":{"Id":197,"Uri":"/api/v2/animal/species/breed/197","Name":"Staffordshire Bull Terrier"},"PrimarySpecies":{"Id":122,"Uri":"/api/v2/animal/species/122"},"Primary":{"Id":140,"Uri":"/api/v2/animal/species/breed/140","Name":"Kelpie"}},"Age":{"AgeGroup":null,"Years":9,"Weeks":1,"Months":9,"IsApproximate":false},"AdoptionSummary":"","AdoptionFee":null,"OtherEuthanasiaReason":null,"EuthanasiaAuthorisedBy":null,"DoNotEuthaniseReason":{"Name":"Test DoNotEuthaniseReason"},"DoNotEuthanise":false,"IsOwnerPresentForEuthanasia":false,"IsApprovedForEuthanasia":false,"EuthanasiaType":null,"SecondaryEuthanasiaReason":null,"EuthanasiaReason":null,"License":{"Issuer":null,"Tag":null},"DateOfBirthUtc":"2013-09-10T14:00:00Z","Name":"Tara"}}';
        List<AnimalUpsertWebhookInvocable.InvocableRequest> requests = new List<AnimalUpsertWebhookInvocable.InvocableRequest> {
            request
        };
        AnimalUpsertWebhookInvocable.process(requests);
    }
}
