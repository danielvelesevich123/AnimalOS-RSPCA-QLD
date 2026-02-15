public inherited sharing class AnimalUpsertProc extends vertic_AbstractProcessor {

    public static Map<SObjectField, String> SF_TO_SHELTER_BUDDY_MAP = new Map<SObjectField, String> {
        Animal__c.Date_Lost__c => 'DateLostUtc',
        Animal__c.Date_Found__c => 'DateFoundUtc',
        Animal__c.Lost_Found_Postcode__c => 'LostFoundAddress.Postcode',
        Animal__c.Lost_Found_City__c => 'LostFoundAddress.Suburb.Name',
        Animal__c.Lost_Found_State__c => 'LostFoundAddress.State.Abbreviation',
        Animal__c.Lost_Found_Street__c => 'LostFoundAddress.Line1',
        Animal__c.Jurisdiction__c => 'LostFoundAddress.Jurisdiction.Name',
        Animal__c.Do_Not_Euthanise_Reason__c => 'DoNotEuthaniseReason.Name',
        Animal__c.Do_Not_Euthanise__c => 'DoNotEuthanise',

        Animal__c.Distinguishing_Features__c => 'DistinguishingFeatures',
        Animal__c.Available_For_Adoption_Date__c => 'AvailableForAdoptionDateUtc',
        Animal__c.Animal_Type__c => 'Type.Name',
        Animal__c.Status__c => 'Status.Name',
        Animal__c.Status_Date__c => 'Status.DateUtc',
        Animal__c.Size__c => 'Size',
        Animal__c.Gender__c => 'Sex.Name',
        Animal__c.Preferred_Food__c => 'Medical.PreferredFood',
        Animal__c.Spayed_Neutered__c => 'Medical.SpayedNeutered',
        Animal__c.Vaccinated__c => 'Medical.IsVaccinated',
        Animal__c.Declawed__c => 'Medical.IsDeclawed',
        Animal__c.Current_Physical_Location__c => 'ContactLocation.Name',
        Animal__c.Source__c => 'Intake.Source.Name',
        Animal__c.Shelter_Tag__c => 'Identification.ShelterTag',
        Animal__c.Barcode__c => 'Identification.Barcode',
        Animal__c.Secondary_Microchip_Date__c => 'Identification.SecondaryMicrochipImplantDateUtc',
        Animal__c.Secondary_Microchip_Number__c => 'Identification.SecondaryMicrochipNumber',
        Animal__c.Primary_Microchip_Date__c => 'Identification.PrimaryMicrochipImplantDateUtc',
        Animal__c.Primary_Microchip_Number__c => 'Identification.PrimaryMicrochipNumber',
        Animal__c.Eye_Colour__c => 'Features.EyeColour.Name',
        Animal__c.Tail_Type__c => 'Features.TailType.Name',
        Animal__c.Ear_Type__c => 'Features.EarType.Name',
        Animal__c.Coat_Type__c => 'Features.CoatType',
        Animal__c.Secondary_Colour__c => 'Features.SecondaryColour',
        Animal__c.Primary_Colour__c => 'Features.PrimaryColour',
        Animal__c.Coat_Length__c => 'Features.CoatLength',
        Animal__c.Breeder_Registration_Number__c => 'BreederRegistrationNumber',
        Animal__c.Crossbreed__c => 'Breed.IsCrossBreed',
        Animal__c.Age_Group__c => 'Age.AgeGroup.Name',
        Animal__c.Age_Years__c => 'Age.Years',
        Animal__c.Age_Months__c => 'Age.Months',
        Animal__c.Age_Weeks__c => 'Age.Weeks',
        Animal__c.Age_Estimated__c => 'Age.IsApproximate',
        Animal__c.Adoption_Summary__c => 'AdoptionSummary',
        Animal__c.Adoption_Fee__c => 'AdoptionFee',
        Animal__c.Euthanasia_Type__c => 'EuthanasiaType.Name',
        Animal__c.Euthanasia_Reason__c => 'EuthanasiaReason.Name',
        Animal__c.Date_of_Birth__c => 'DateOfBirthUtc',
        Animal__c.Animal_Name__c => 'Name'
     };

    public override vertic_Response process(vertic_Request request) {

        this.request = request;

        String animalJSON = this.request.getString('animalJSON');

        System.debug(animalJSON);

        vertic_DTO dto = new vertic_DTO(animalJSON);
        Animal__c animalVar = new Animal__c();

        System.debug(JSON.serializePretty(dto.getMap()));

        mapAnimal(animalVar, dto);

        if(String.isNotBlank(animalVar.Shelterbuddy_ID__c)) {
            Animal__c existingAnimalVar = (Animal__c) vertic_Utils.arrays.firstOrNull([
                SELECT Id
                FROM Animal__c
                WHERE Shelterbuddy_ID__c = :animalVar.Shelterbuddy_ID__c
            ]);
            if(existingAnimalVar != null) {
                animalVar.Id = existingAnimalVar.Id;
            }
        }
        if(animalVar.Id == null) {
            vertic_Utils.sObjects.deduplicate(animalVar);
        }

        upsert animalVar;

        insert new aos_Async_Process__c(
                aos_Processor__c = '' + AnimalUpsertProc.class,
                aos_Payload__c = JSON.serializePretty(new Map<String, Object>{
                'animalJSON' => animalJSON,
                'animalDTO' => dto.getMap()
            }),
                aos_Details__c = JSON.serializePretty(animalVar),
                aos_Autorun__c = false,
                aos_Status__c = 'Completed',
                aos_Description__c = 'Animal Webhook',
                aos_Group_Key__c = animalVar.Id
        );

        this.response.put('animal', animalVar);

        return this.response;
    }

    private static void mapAnimal(Animal__c animalVar, vertic_DTO dto){
        System.debug(dto);

        ShelterBuddyService.mapShelterBuddyToSobject(SF_TO_SHELTER_BUDDY_MAP, dto, animalVar);

        animalVar.Shelterbuddy_ID__c = dto.getString('Id');

        String ownerId = dto.getString('Owner.Id');
        Contact ownerVar = (Contact)vertic_Utils.arrays.firstOrNull([SELECT Id, ShelterBuddy_ID_PID__c FROM Contact WHERE ShelterBuddy_ID_PID__c = :ownerId]);
        if(ownerVar != null){
            animalVar.Animal_Owner__c = ownerVar.Id;
        }

        Animal_Breed__c primaryAnimalBreedVar = findOrCreateAnimalBreed(dto.getString('Breed.Primary.Name'), dto.getString('Breed.PrimarySpecies.Id'));
        Animal_Breed__c secondaryAnimalBreedVar = findOrCreateAnimalBreed(dto.getString('Breed.Secondary.Name'), dto.getString('Breed.SecondarySpecies.Id'));

        if(primaryAnimalBreedVar != null){
            animalVar.Animal_Breed__c = primaryAnimalBreedVar.Id;
        }

        if(secondaryAnimalBreedVar != null){
            animalVar.Secondary_Breed__c = secondaryAnimalBreedVar.Id;
        }

        animalVar.Microchipped__c = dto.getBoolean('Identification.HasMicrochip') == true ? 'Yes' : 'No';

        String shelterBuddyLocation = dto.getString('Location.MostRecentPhysicalLocation.Name');

        Animal_Location__mdt animalLocation = (Animal_Location__mdt) vertic_Utils.arrays.firstOrNull([SELECT Id, Salesforce_Value__c FROM Animal_Location__mdt WHERE ShelterBuddy_Value__c = :shelterBuddyLocation LIMIT 1]);


        if (animalLocation != null) {
            Account accountVar = (Account) vertic_Utils.arrays.firstOrNull([
                SELECT
                        Id, Name
                FROM Account
                WHERE Name = :animalLocation.Salesforce_Value__c
                LIMIT 1
        ]);
            if (accountVar != null) {
                animalVar.Location__c = accountVar.Id;
            }
        }

        setSubStatuses(animalVar, dto.getList('SubStatuses'), dto.getString('SubStatus.Name'));
    }

    private static Animal_Breed__c findOrCreateAnimalBreed(String animalBreedName, String animalBreedId) {
        Animal_Breed__c animalBreedVar;
        if (String.isNotBlank(animalBreedName)) {
            animalBreedVar = (Animal_Breed__c) vertic_Utils.arrays.firstOrNull(
                [SELECT Id, Name FROM Animal_Breed__c WHERE Species_ID__c = :animalBreedId]
            );
            if (animalBreedVar == null) {
                animalBreedVar = (Animal_Breed__c) vertic_Utils.arrays.firstOrNull(
                    [SELECT Id, Name FROM Animal_Breed__c WHERE Name = :animalBreedName]
                );
            }
            if (animalBreedVar == null) {
                animalBreedVar = new Animal_Breed__c(
                    Name = animalBreedName,
                    Species_ID__c = animalBreedId
                );
                insert animalBreedVar;
            }
        }
        return animalBreedVar;
    }

    public static void setSubStatuses(Animal__c animalVar, List<Object> subStatusList, String subStatus) {
        if(String.isNotBlank(subStatus)) {
            animalVar.Sub_Status__c = subStatus;
            return;
        }

        if(subStatusList == null || subStatusList.isEmpty()) {
            return;
        }

        List<String> concatSubStatusList = new List<String>();
        for(Object subStatusObj : subStatusList) {
            vertic_DTO dto = new vertic_DTO((Map<String, Object>)subStatusObj);
            String subStatusInList = dto.getString('Name');
            if(String.isNotBlank(subStatusInList)) {
                concatSubStatusList.add(subStatusInList);
            }
        }
        if(!concatSubStatusList.isEmpty()) {
            animalVar.Sub_Status__c = String.join(concatSubStatusList, ';');
        }
    }

    public static void setLostFoundStreet(Animal__c animalVar, vertic_DTO dto) {
        List<String> keyList = new List<String> {
            'Line1'
        };
        List<String> concatStreetList = new List<String>();
        for(String key : keyList) {
            String value = dto.getString('LostFoundAddress.' + key);
            if(String.isNotBlank(value)) {
                concatStreetList.add(value);
            }
        }
        if(!concatStreetList.isEmpty()) {
            animalVar.Lost_Found_Street__c = String.join(concatStreetList, ', ');
        }
    }
}
