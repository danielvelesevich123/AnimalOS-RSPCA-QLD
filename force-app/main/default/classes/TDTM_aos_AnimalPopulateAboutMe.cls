global class TDTM_aos_AnimalPopulateAboutMe extends animalos.TDTM.Handler implements animalos.TDTM.BeforeInsert, animalos.TDTM.BeforeUpdate {

    public void onBeforeInsert(List<SObject> records) {
        populateAboutMeFields(records, null);
    }

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        populateAboutMeFields(records, oldMap);
    }

    private void populateAboutMeFields(List<SObject> records, Map<Id, SObject> existingRecords) {
        for (animalos__Animal__c animal : (List<animalos__Animal__c>) records) {
            animalos__Animal__c existingAnimal = (animalos__Animal__c) existingRecords?.get(animal.Id);

            Boolean isCreated = Trigger.isInsert && existingRecords == null;
            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingAnimal != null && vertic_Utils.sObjects.isSomeFieldChanged(
                animal, existingAnimal, new List<SObjectField>{
                    animalos__Animal__c.animalos__Adoption_Profile__c,
                    animalos__Animal__c.aos_Age_Restriction__c,
                    animalos__Animal__c.aos_Dog_Sociability__c,
                    animalos__Animal__c.aos_Adopter_Experience__c,
                    animalos__Animal__c.aos_Fencing_Requirements__c,
                    animalos__Animal__c.aos_Indoors_Outdoors_Preference__c,
                    animalos__Animal__c.aos_Lifestyle__c,
                    animalos__Animal__c.aos_Activity_level_playfulness__c,
                    animalos__Animal__c.aos_General_Requirements__c,
                    animalos__Animal__c.aos_Cat_Home_Requirements__c,
                    animalos__Animal__c.animalos__Adoption_Fee__c,
                    animalos__Animal__c.aos_Adoption_EOI_Required__c
                }
            );

            if (isCreated || isUpdated) {
                animal.aos_About_Me_Adoptapet__c = generateAboutMeField(animal, 'Adoptapet');
                animal.aos_About_Me_PetRescue__c = generateAboutMeField(animal, 'PetRescue');
            }
        }
    }

    private String generateAboutMeField(animalos__Animal__c animal, String type) {
        String aboutMe = String.isNotBlank(animal.animalos__Adoption_Profile__c) ? animal.animalos__Adoption_Profile__c + '<br><br>' : '';
        aboutMe += String.isNotBlank(animal.aos_Age_Restriction__c) ? '<p><b>Best with Children Aged:</b> ' + animal.aos_Age_Restriction__c + '</p>' : '';

        if ('Dog'.equals(animal.animalos__Type__c) || 'Puppy'.equals(animal.animalos__Type__c)) {
            aboutMe += String.isNotBlank(animal.aos_Dog_Sociability__c) ? '<p><b>Compatibility with Other Dogs:</b> ' + animal.aos_Dog_Sociability__c + '</p>' : '';
            aboutMe += String.isNotBlank(animal.aos_Adopter_Experience__c) ? '<p><b>Training and Behaviour Needs:</b> ' + animal.aos_Adopter_Experience__c + '</p>' : '';
            aboutMe += String.isNotBlank(animal.aos_Fencing_Requirements__c) ? '<p><b>Fencing Needs:</b> ' + animal.aos_Fencing_Requirements__c + '</p>' : '';
            aboutMe += String.isNotBlank(animal.aos_Indoors_Outdoors_Preference__c) ? '<p><b>Indoors/Outdoors Living Preference:</b> ' + animal.aos_Indoors_Outdoors_Preference__c + '</p>' : '';
            aboutMe += String.isNotBlank(animal.aos_Lifestyle__c) ? '<p><b>Energy Level of Household:</b> ' + animal.aos_Lifestyle__c + '</p>' : '';
        }

        if ('Cat'.equals(animal.animalos__Type__c) || 'Kitten'.equals(animal.animalos__Type__c)) {
            aboutMe += String.isNotBlank(animal.aos_Activity_level_playfulness__c) ? '<p><b>Energy Level of Household:</b> ' + animal.aos_Activity_level_playfulness__c + '</p>' : '';

            List<String> requirements = new List<String>();
            if (String.isNotBlank(animal.aos_General_Requirements__c)) {
                requirements.add(animal.aos_General_Requirements__c.replaceAll(';', '; '));
            }
            if (String.isNotBlank(animal.aos_Cat_Home_Requirements__c)) {
                requirements.add(animal.aos_Cat_Home_Requirements__c);
            }
            String requirementsString = String.join(requirements, '. ');

            aboutMe += String.isNotBlank(requirementsString) ? '<p><b>Additional Needs:</b> ' + requirementsString + '</p>' : '';
        }

        if (!'Cat'.equals(animal.animalos__Type__c) && !'Kitten'.equals(animal.animalos__Type__c)) {
            aboutMe += String.isNotBlank(animal.aos_General_Requirements__c) ? '<p><b>Additional Needs:</b> ' + animal.aos_General_Requirements__c.replaceAll(';', '; ') + '</p>' : '';
        }

        if (!'PetRescue'.equals(type)) {
            aboutMe += animal.animalos__Adoption_Fee__c != null ? '<p><b>Adoption Fee:</b> $' + animal.animalos__Adoption_Fee__c.setScale(0) + '</p>' : '';
        }

        if (animal.aos_Adoption_EOI_Required__c) {
            aboutMe += '<br><p><a style="color: #0000EE;" href="https://www.rspcansw.org.au/standalone-eoi-form">If you are interested in giving this wonderful pet a home, please <b>CLICK HERE</b> to visit our website and complete an expression of interest.</a></p>';
        }
        return aboutMe;
    }
}
