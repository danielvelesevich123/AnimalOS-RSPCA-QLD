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
                SELECT Id, Label, Information__c, Animal_Type__c
                FROM Animal_Type_Information__mdt
        ], Animal_Type_Information__mdt.Animal_Type__c);
        List<Animal_Type_Information__mdt> includedAnimalTypes = new List<Animal_Type_Information__mdt>();


        List<animalos__Animal__c> animals = [
                SELECT
                        Id,
                        Name,
                        animalos__Animal_Name__c,
                        Heartworm_Test_Outcome__c,
                        Last_Heartworm_Test_Date__c,
                        animalos__Type__c,
                        animalos__Microchip_Number__c,
                        animalos__Gender__c,
                        animalos__Primary_Colour__c,
                        Tag_Number__c,
                        animalos__Primary_Breed__r.Name,
                        animalos__Secondary_Breed__r.Name,
                        animalos__Neutered_Spayed__c,
                        animalos__Secondary_Colour__c,
                        Unknown_People_offlead__c,
                        Veterinary_handling__c,
                        Unknown_People_on_lead__c,
                        Being_alone_initially__c,
                        Visitors_to_the_home__c,
                        Being_alone_once_settled_in__c,
                        Handling_with_unknown_people__c,
                        Behaviour_around_food_and_other_resource__c,
                        Handling_with_known_people__c,
                        Adoption_People_Summary__c,
                        Age_Restriction__c,
                        Home_Requirements__c,
                        Separation_Isolation_Behaviours__c,
                        Meeting_an_unknown_dog_on_lead__c,
                        Play_interactions__c,
                        Off_lead_with_other_dogs_i_e_dog_parks__c,
                        Adoption_Dogs_Summary__c,
                        Dog_Sociability__c,
                        Walking_on_leash__c,
                        Travelling_in_the_car__c,
                        Food__c,
                        Breed_traits__c,
                        Toys__c,
                        Predatory_behaviour__c,
                        Noise_sensitivity__c,
                        House_Training__c,
                        Adoption_General_Summary__c,
                        Indoors_Outdoors_Preference__c,
                        Adopter_Experience__c,
                        Fencing_Requirements__c,
                        Lifestyle__c,
                        Other_Animals__c,
                        Adaptability__c,
                        Life_Experience__c,
                        Adoption_Level__c,
                        General_Requirements__c,
                        FIV_FeLV_Test_Outcome__c,
                        FIV_Date_Administered__c,
                        General_interactions_with_dogs__c,
                        Crossbreed__c,
                        animalos__Neutered_Spayed_Date_Time__c,
                        animalos__Current_Site__c,
                        animalos__Current_Site__r.Name,
                        animalos__Current_Site__r.Street_Address__c,
                        animalos__Current_Site__r.Suburb__c,
                        animalos__Current_Site__r.State__c,
                        animalos__Current_Site__r.Postcode__c,
                        animalos__Current_Site__r.Site_Phone__c,
                        Microchip_Company__c,
                        animalos__Current_Weight__c,
                        Neutered_Spayed_By__c,
                        Neutered_Spayed_By__r.Name,
                        (
                                SELECT Id, Name, animalos__Animal__r.animalos__Animal_Name__c, Specific_Animal__c, animalos__Active__c,
                                        animalos__Action_Plan__r.Name, animalos__Action_Plan__r.animalos__Frequency_Interval__c,
                                        animalos__Action_Plan__r.animalos__Frequency__c, animalos__Start_Date__c,
                                        animalos__Next_Scheduled_Date__c, Frequency__c,
                                        Frequency_Interval__c, animalos__End_Date__c
                                FROM animalos__Animal_Action_Plans__r
                                WHERE Specific_Animal__c = TRUE AND animalos__Active__c = TRUE
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
                                        Indemnity_Waiver_Title__c
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
                        Signature_URL__c,
                        Signing_Date__c,
                        Additional_Signature_URL__c,
                        Additional_Signing_Date__c,
                        Third_Party_Marketing_Opt_Out__c,
                        Royal_Canin_s_Healthy_Pets_Club_Opt_In__c,
                        animalos__Contact__r.Name,
                        animalos__Contact__r.MailingStreet,
                        animalos__Contact__r.MailingCity,
                        animalos__Contact__r.MailingState,
                        animalos__Contact__r.MailingPostalCode,
                        animalos__Contact__r.MobilePhone,
                        Address__c,
                        Home_Phone__c,
                        Contact_Code__c,
                        Work_Phone__c,
                        Referral_ID__c,
                        Mobile__c,
                        Email__c,
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
                        includedAnimalTypes.add((Animal_Type_Information__mdt) animalTypeInformationByLabel.get(key));
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