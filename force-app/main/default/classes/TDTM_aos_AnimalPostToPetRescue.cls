global class TDTM_aos_AnimalPostToPetRescue extends animalos.TDTM.Handler implements animalos.TDTM.AfterUpdate {

    public static Boolean uploadToPetRescueIgnoringUpdateConditions = false;

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        postAnimalToPetRescue(records, oldMap);
    }

    private void postAnimalToPetRescue(List<SObject> records, Map<Id, SObject> existingRecords) {

        if ('true'.equalsIgnoreCase(aos_SettingService.getValue('PETRESCUE_PROCESSING_DISABLED'))) {
            return;
        }

        aos_AsyncProcess asyncProcess = new aos_AsyncProcess();

        Map<String, Object> petRescueSettingsByLocationId = aos_Utils.sObjects.getSObjectsByAnyFieldMap(
            aos_PetRescue_Setting__mdt.getAll().values(),
            aos_PetRescue_Setting__mdt.aos_Location_Id__c
        );

        for (animalos__Animal__c animal : (List<animalos__Animal__c>) records) {
            animalos__Animal__c existingAnimal = (animalos__Animal__c) existingRecords?.get(animal.Id);

            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingAnimal != null &&
                (aos_Utils.sObjects.isSomeFieldChanged(
                    animal,
                    existingAnimal,
                    new List<SObjectField>{
                        animalos__Animal__c.animalos__Animal_Name__c,
                        animalos__Animal__c.animalos__Adoption_Fee__c,
                        animalos__Animal__c.animalos__Stage__c,
                        animalos__Animal__c.animalos__Status__c,
                        animalos__Animal__c.animalos__Current_Site__c,
                        animalos__Animal__c.aos_Crossbreed__c,
                        animalos__Animal__c.animalos__Date_of_Birth__c,
                        animalos__Animal__c.animalos__Neutered_Spayed__c,
                        animalos__Animal__c.animalos__Microchip_Number__c,
                        animalos__Animal__c.animalos__Adoption_Profile__c,
                        animalos__Animal__c.animalos__Primary_Breed__c,
                        animalos__Animal__c.animalos__Gender__c,
                        animalos__Animal__c.animalos__Type__c,
                        animalos__Animal__c.aos_Age_Restriction__c,
                        animalos__Animal__c.aos_Home_Requirements__c,
                        animalos__Animal__c.aos_Senior_Pet__c
                    }));

            Boolean availableForAdoption = String.isNotBlank(animal.animalos__Status__c) && animal.animalos__Status__c.containsIgnoreCase('Available For Adoption');
            Boolean notAvailableForAdoption = String.isNotBlank(animal.animalos__Status__c) && !animal.animalos__Status__c.containsIgnoreCase('Available For Adoption');
            Boolean noWebPresence = String.isNotBlank(animal.animalos__Status__c) && animal.animalos__Status__c?.containsIgnoreCase('No Web Presence');

            if ((((animal.aos_PetRescue_Sync__c || String.isNotBlank(animal.aos_PetRescue_Id__c)) && isUpdated) || uploadToPetRescueIgnoringUpdateConditions)
                && ((animal.animalos__Current_Site__c != null && petRescueSettingsByLocationId.get(animal.animalos__Current_Site__c) != null)
                || (animal.aos_PetRescue_Location__c != null && petRescueSettingsByLocationId.get(animal.aos_PetRescue_Location__c) != null))) {
                String status = '';

                if (availableForAdoption) {
                    status = 'active';
                }

                if ((notAvailableForAdoption || noWebPresence) && String.isNotBlank(animal.aos_PetRescue_Id__c)) {
                    status = 'removed';
                }

                if (String.isNotBlank(animal.animalos__Status__c) &&
                    animal.animalos__Status__c?.containsIgnoreCase('Adopted') &&
                    String.isNotBlank(animal.aos_PetRescue_Id__c)) {
                    status = 'rehomed';
                }

                if (String.isNotBlank(status)) {
                    String petRescueLocationKey = ((aos_PetRescue_Setting__mdt) petRescueSettingsByLocationId.get(animal.aos_PetRescue_Location__c))?.aos_API_Key__c;
                    String currentSiteKey = ((aos_PetRescue_Setting__mdt) petRescueSettingsByLocationId.get(animal.animalos__Current_Site__c))?.aos_API_Key__c;
                    String locationId = '';

                    if (String.isBlank(currentSiteKey) && String.isBlank(petRescueLocationKey)) {
                        continue;
                    }

                    if (String.isNotBlank(petRescueLocationKey) && String.isNotBlank(currentSiteKey) && !petRescueLocationKey.equals(currentSiteKey)) {
                        locationId = animal.animalos__Current_Site__c;
                    }

                    if (String.isNotBlank(petRescueLocationKey) && String.isNotBlank(currentSiteKey) && petRescueLocationKey.equals(currentSiteKey)) {
                        locationId = animal.aos_PetRescue_Location__c;
                    }

                    if (String.isNotBlank(petRescueLocationKey) && String.isBlank(currentSiteKey)) {
                        locationId = animal.aos_PetRescue_Location__c;
                    }

                    if (String.isBlank(petRescueLocationKey) && String.isNotBlank(currentSiteKey)) {
                        locationId = animal.animalos__Current_Site__c;
                    }

                    aos_Async_Process__c vap = aos_AsyncProcess.create(
                        aos_AnimalToPetRescueProc.class,
                        new Map<String, Object>{
                            'recordId' => animal.Id,
                            'status' => status,
                            'locationId' => locationId
                        }
                    );
                    vap.aos_Group_Key__c = animal.Id;
                    vap.aos_Description__c = 'Creation on PetRescue';
                    asyncProcess.add(vap);
                }
            }
        }
        asyncProcess.enqueue();
    }
}