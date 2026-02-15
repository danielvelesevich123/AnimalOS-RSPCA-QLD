public without sharing class AdoptionAgreementMetaProc extends vertic_MetadataProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
        };
        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        String referralId = this.request.getRequiredString('recordId');

        Map<String, SObject> animalTypeInformationByLabel = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, Label, aos_Information__c, aos_Animal_Type__c
                FROM aos_Animal_Type_Information__mdt
        ], aos_Animal_Type_Information__mdt.aos_Animal_Type__c);
        List<aos_Animal_Type_Information__mdt> includedAnimalTypes = new List<aos_Animal_Type_Information__mdt>();


        List<animalos__Animal__c> animals = [
                SELECT
                        Id,
                        Name,
                        animalos__Animal_Name__c,
                        aos_Heartworm_Test_Outcome__c,
                        aos_Last_Heartworm_Test_Date__c,
                        animalos__Type__c,
                        animalos__Microchip_Number__c,
                        animalos__Gender__c,
                        animalos__Primary_Colour__c,
                        aos_Tag_Number__c,
                        animalos__Primary_Breed__r.Name,
                        animalos__Secondary_Breed__r.Name,
                        animalos__Neutered_Spayed__c,
                        animalos__Secondary_Colour__c,
                        aos_Unknown_People_offlead__c,
                        aos_Veterinary_handling__c,
                        aos_Unknown_People_on_lead__c,
                        aos_Being_alone_initially__c,
                        aos_Visitors_to_the_home__c,
                        aos_Being_alone_once_settled_in__c,
                        aos_Handling_with_unknown_people__c,
                        aos_Behaviour_around_food_and_other__c,
                        aos_Handling_with_known_people__c,
                        aos_Adoption_People_Summary__c,
                        aos_Age_Restriction__c,
                        aos_Home_Requirements__c,
                        aos_Separation_Isolation_Behaviours__c,
                        aos_Meeting_an_unknown_dog_on_lead__c,
                        aos_Play_interactions__c,
                        aos_Off_lead_with_other_dogs_i_e_dog__c,
                        aos_Adoption_Dogs_Summary__c,
                        aos_Dog_Sociability__c,
                        aos_Walking_on_leash__c,
                        aos_Travelling_in_the_car__c,
                        aos_Food__c,
                        aos_Breed_traits__c,
                        aos_Toys__c,
                        aos_Predatory_behaviour__c,
                        aos_Noise_sensitivity__c,
                        aos_House_Training__c,
                        aos_Adoption_General_Summary__c,
                        aos_Indoors_Outdoors_Preference__c,
                        aos_Adopter_Experience__c,
                        aos_Fencing_Requirements__c,
                        aos_Lifestyle__c,
                        aos_Other_Animals__c,
                        aos_Adaptability__c,
                        aos_Life_Experience__c,
                        aos_Adoption_Level__c,
                        aos_General_Requirements__c,
                        aos_FIV_FeLV_Test_Outcome__c,
                        aos_FIV_Date_Administered__c,
                        aos_General_interactions_with_dogs__c,
                        aos_Crossbreed__c,
                        animalos__Neutered_Spayed_Date_Time__c,
                        animalos__Current_Site__c,
                        animalos__Current_Site__r.Name,
                        animalos__Current_Site__r.aos_Street_Address__c,
                        animalos__Current_Site__r.aos_Suburb__c,
                        animalos__Current_Site__r.aos_State__c,
                        animalos__Current_Site__r.aos_Postcode__c,
                        animalos__Current_Site__r.aos_Site_Phone__c,
                        aos_Microchip_Company__c,
                        animalos__Current_Weight__c,
                        aos_Neutered_Spayed_By__c,
                        aos_Neutered_Spayed_By__r.Name,
                        (
                                SELECT Id, Name, animalos__Animal__r.animalos__Animal_Name__c, aos_Specific_Animal__c, animalos__Active__c,
                                        animalos__Action_Plan__r.Name, animalos__Action_Plan__r.animalos__Frequency_Interval__c,
                                        animalos__Action_Plan__r.animalos__Frequency__c, animalos__Start_Date__c,
                                        animalos__Next_Scheduled_Date__c, aos_Frequency__c,
                                        aos_Frequency_Interval__c, animalos__End_Date__c
                                FROM animalos__Animal_Action_Plans__r
                                WHERE aos_Specific_Animal__c = TRUE AND animalos__Active__c = TRUE
                                AND (NOT animalos__Action_Plan__r.Name LIKE '%Nutrition Plan%') AND animalos__Action_Plan__r.animalos__Type__c != 'Nutrition'
                                ORDER BY animalos__Next_Scheduled_Date__c
                        ),
                        (
                                SELECT
                                        Id,
                                        animalos__Animal__c,
                                        animalos__Animal_Indemnity_Waiver_Content__c,
                                        animalos__Indemnity_Waiver__c,
                                        animalos__Indemnity_Waiver__r.animalos__Type__c,
                                        aos_Indemnity_Waiver_Title__c
                                FROM animalos__Animal_Indemnity_Waivers__r
                        ),
                        (
                                SELECT
                                        Id,
                                        animalos__Animal__c,
                                        animalos__Description__c,
                                        animalos__Date_Time_Action_Completed__c
                                FROM animalos__Animal_Actions__r
                                WHERE RecordType.Name = 'Treatment'
                                    AND animalos__Date_Time_Action_Completed__c != NULL
                                    AND animalos__Date_Time_Action_Completed__c <= TODAY
                                    AND Id IN (SELECT animalos__Animal_Action__c FROM animalos__Medicine_Used__c)
                                ORDER BY animalos__Date_Time_Action_Completed__c ASC
                        )
                FROM animalos__Animal__c
                WHERE Id
                        IN (
                                SELECT animalos__Animal__c
                                FROM animalos__Animal_Referral__c
                                WHERE animalos__Referral__c = :referralId
                        )
        ];

        animalos__Referral__c referralVar = (animalos__Referral__c) vertic_Utils.arrays.firstOrException([
                SELECT Id,
                        Name,
                        aos_Signature_URL__c,
                        aos_Signing_Date__c,
                        aos_Additional_Signature_URL__c,
                        aos_Additional_Signing_Date__c,
                        aos_Third_Party_Marketing_Opt_Out__c,
                        aos_Royal_Canin_s_Healthy_Pets_Club_Opt__c,
                        animalos__Contact__r.Name,
                        animalos__Contact__r.MailingStreet,
                        animalos__Contact__r.MailingCity,
                        animalos__Contact__r.MailingState,
                        animalos__Contact__r.MailingPostalCode,
                        animalos__Contact__r.MobilePhone,
                        aos_Address__c,
                        aos_Home_Phone__c,
                        aos_Contact_Code__c,
                        aos_Work_Phone__c,
                        aos_Referral_ID__c,
                        aos_Mobile__c,
                        aos_Email__c,
                        animalos__Scheduled_Date_Time__c
                FROM animalos__Referral__c
                WHERE Id = :referralId
        ], 'There is no Referral with Id = ' + referralId);

        List<animalos__Animal__c> dogs = new List<animalos__Animal__c>();

        for (animalos__Animal__c animal : animals) {
            if ('Dog'.equals(animal.animalos__Type__c) || 'Puppy'.equals(animal.animalos__Type__c)) {
                dogs.add(animal);
            }

            if (String.isNotBlank(animal.animalos__Type__c)) {
                for (String key : animalTypeInformationByLabel.keySet()) {
                    if (key.containsIgnoreCase(animal.animalos__Type__c)) {
                        includedAnimalTypes.add((aos_Animal_Type_Information__mdt) animalTypeInformationByLabel.get(key));
                        break;
                    }
                }
            }
        }


        this.response.getMapper()
                .mapFromSObject('referral', referralVar)
                .mapFromListSObjects('animals', animals)
                .mapFromListSObjects('dogs', dogs)
                .mapFromListSObjects('animalTypesInformation', includedAnimalTypes);

        if (this.request.getBoolean('isPdf') == true) {
            new vertic_AutoMapper(this.response)
                    .getOptions()
                    .setIsVisualforce(true)
                    .setIsAllFields(true)
                    .setDefaultFieldValue(' ')
                    .getMapper()
                    .mapFromSObject('referral', referralVar)
                    .mapFromListSObjects('animals', animals)
                    .mapFromListSObjects('dogs', dogs)
                    .mapAnyValue('animalTypesInformation', includedAnimalTypes)
                    .mapAnyValue('hasAnimalTypeInformation', includedAnimalTypes.size() > 0)
                    .mapFromSObject('lastAnimal', dogs.isEmpty() ? null : dogs[dogs.size() - 1]);

            this.response.put('hasDogs', dogs.size() > 0);
            List<Map<String, Object>> animalsMap = (List<Map<String, Object>>) this.response.get('animals');
            for (Map<String, Object> animalMap : animalsMap) {
                animalMap.put('hasActions', animalMap.containsKey('animalos__Animal_Actions__r') ? true : false);
                animalMap.put('hasTreatments', animalMap.containsKey('animalos__Animal_Action_Plans__r') ? true : false);
                animalMap.put('hasWaivers', animalMap.containsKey('animalos__Animal_Indemnity_Waivers__r') ? true : false);
            }
        }

        this.response.put('isGuest', 'Guest'.equalsIgnoreCase(UserInfo.getUserType()));
    }
}
