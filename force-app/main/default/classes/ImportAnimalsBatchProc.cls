public inherited sharing class ImportAnimalsBatchProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {

        this.request = request;

        Integer page = this.request.getInteger('page');
        Integer pageSize = this.request.getInteger('pageSize');
        String filter = this.request.getString('filter');

        ShelterBuddyAPIUtils shelterBuddyAPIUtils = new ShelterBuddyAPIUtils();
        HttpResponse animalListResponse = new HttpResponse();

        try{
            animalListResponse = shelterBuddyAPIUtils.commonRequest('getAnimalList', new List<String>{
                    '' + page,
                    '' + pageSize,
                    '' + 0
            }, filter);
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        finally{
            shelterBuddyAPIUtils.saveAccessToken();
        }

        if (animalListResponse.getStatusCode() != 200) {
            throw new vertic_Structs.ProcessException(animalListResponse.getStatusCode() + '\n\n\n' + animalListResponse.getStatus() + animalListResponse.getBody());
        }

        vertic_DTO responseDTO = new vertic_DTO(animalListResponse.getBody());
        List<vertic_DTO> animalDTOs = responseDTO.getListAsDTONonNull('Data');

        Map<String, vertic_DTO> shelterbuddyIdToDTOMap = new Map<String, vertic_DTO> ();
        Set<String> ownerIdSet = new Set<String>();

        for (vertic_DTO dto : animalDTOs) {

            String shelterbuddyId = dto.getString('Id');
            String ownerId = dto.getString('Owner.Id');

            if (String.isNotBlank(shelterbuddyId)) {
                shelterbuddyIdToDTOMap.put(shelterbuddyId, dto);
            }

            ownerIdSet.add(ownerId);
        }

        Map<String, SObject> existingAnimalsMap = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
            SELECT Id, Shelterbuddy_ID__c
            FROM Animal__c
            WHERE Shelterbuddy_ID__c IN :shelterbuddyIdToDTOMap.keySet() AND Shelterbuddy_ID__c != NULL
        ], Animal__c.Shelterbuddy_ID__c);

        Map<String, SObject> ownersMap = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
            SELECT Id, ShelterBuddy_ID_PID__c
            FROM Contact
            WHERE ShelterBuddy_ID_PID__c IN :ownerIdSet AND ShelterBuddy_ID_PID__c != NULL
        ], Contact.ShelterBuddy_ID_PID__c);

        List<Animal_Breed__c> animalBreeds = [SELECT Id, Species_ID__c, Name FROM Animal_Breed__c];
        Map<String, SObject> breedsBySpeciesIdMap = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(animalBreeds, Animal_Breed__c.Species_ID__c);
        Map<String, SObject> breedsByNameMap = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(animalBreeds, Animal_Breed__c.Name);

        vertic_UnitOfWork uow = new vertic_UnitOfWork(
            new List<SObjectType>{
                Animal_Breed__c.SObjectType,
                Animal__c.SObjectType
            }
        );

        for (String shelterBuddyId : shelterbuddyIdToDTOMap.keySet()) {
            vertic_DTO dto = shelterbuddyIdToDTOMap.get(shelterBuddyId);

            String ownerId = dto.getString('Owner.Id');
            String primaryId = dto.getString('Breed.PrimarySpecies.Id');
            String primaryName = dto.getString('Breed.Primary.Name');
            String secondaryId = dto.getString('Breed.SecondarySpecies.Id');
            String secondaryName = dto.getString('Breed.Secondary.Name');

            Animal__c animalVar = new Animal__c(
                Id = existingAnimalsMap.get(shelterBuddyId)?.Id,
                Animal_Owner__c = ownersMap.get(ownerId)?.Id,
                Import_JSON__c = JSON.serializePretty(dto.getMap())
            );
            mapAnimal(animalVar, dto);
            uow.registerUpsert(animalVar);

//            System.debug('animalVar: ' + animalVar);

            Animal_Breed__c primaryBreed = findOrCreateBreed(primaryId, primaryName, breedsBySpeciesIdMap, breedsByNameMap, uow);
            Animal_Breed__c secondaryBreed = findOrCreateBreed(secondaryId, secondaryName, breedsBySpeciesIdMap, breedsByNameMap, uow);

            if (primaryBreed != null) {
                uow.registerRelationship(animalVar, Animal__c.Animal_Breed__c, primaryBreed);
//                System.debug('primaryBreed: ' + primaryBreed);
            }

            if (secondaryBreed != null) {
                uow.registerRelationship(animalVar, Animal__c.Secondary_Breed__c, secondaryBreed);
//                System.debug('secondaryBreed: ' + secondaryBreed);
            }
        }

        uow.commitWork();

        return this.response;
    }

    private Animal_Breed__c findOrCreateBreed(String breedId, String breedName, Map<String, SObject> breedsBySpeciesIdMap, Map<String, SObject> breedsByNameMap, vertic_UnitOfWork uow) {
        Animal_Breed__c breedVar;
        if (String.isNotBlank(breedId) && String.isNotBlank(breedName)) {
            breedVar = (Animal_Breed__c) breedsBySpeciesIdMap.get(breedId);
            if (breedVar == null) {
                breedVar = (Animal_Breed__c) breedsByNameMap.get(breedName);
            }
            if (breedVar == null) {
                breedVar = new Animal_Breed__c(
                    Species_ID__c = breedId,
                    Name = breedName
                );
                uow.registerNew(breedVar);
                breedsBySpeciesIdMap.put(breedId, breedVar);
                breedsByNameMap.put(breedName, breedVar);
            }
        }
        return breedVar;
    }

    private void mapAnimal(Animal__c animalVar, vertic_DTO dto) {
        Map<SObjectField, String> SFToShelterBuddyMap = AnimalUpsertProc.SF_TO_SHELTER_BUDDY_MAP;

        ShelterBuddyService.mapShelterBuddyToSobject(SFToShelterBuddyMap, dto, animalVar);

        animalVar.Shelterbuddy_ID__c = dto.getString('Id');
        animalVar.Microchipped__c = dto.getBoolean('Identification.HasMicrochip') == true ? 'Yes' : 'No';

        AnimalUpsertProc.setSubStatuses(animalVar, dto.getList('SubStatuses'), dto.getString('SubStatus.Name'));
    }
}