public without sharing class animalos_AnimalDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {

    private final Map<String, String> statusErrors = new Map<String, String>{
            'Adopted' => 'Start Adoption OR Start Referral > Record Type = Adoption',
            'Adopted – Offsite' => 'Start Adoption OR Start Referral > Record Type = Adoption',
            'Deceased' => 'Update To Deceased > Stage = Out > Status = Deceased > Deceased Date > Deceased Reason',
            'Emergency Boarding Returned to Owner' => 'Start Referral > Record Type = Outbound Animal > Outbound Type = Emergency Boarding Returned To Owner',
            'Euthanasia in Field' => 'Update To Deceased > Stage = Out > Status = Euthanasia in Field > Deceased Date > Euthanasia Reason',
            'Euthanised' => 'Update To Deceased > Stage = Out > Status = Euthanised > Deceased Date > Euthanasia Reason',
            'Euthanised by Offsite Vet' => 'Update To Deceased > Stage = Out > Status = Euthanised by Offsite Vet > Deceased Date > Euthanasia Reason',
            'Euthanised on Arrival' => 'Update To Deceased > Stage = Out > Status = Euthanised on Arrival > Deceased Date > Euthanasia Reason',
            'Post-Operative Death' => 'Update To Deceased > Stage = Out > Status = Unassisted Death > Deceased Date',
            'Reclaimed' => 'Start Referral > Record Type = Outbound Animal > Outbound Type = Reclaimed',
            'Returned Protective Custody Animal' => 'Start Referral > Record Type = Outbound Animal > Outbound Type = Returned Protective Custody Animal',
            'Returned Surrender' => 'Start Referral > Record Type = Outbound Animal > Outbound Type = Returned Surrender',
            'Returned to Habitat' => 'Start Referral > Record Type = Outbound Animal > Outbound Type = Returned to Habitat',
            'Transfer Out to Council' => 'Start Referral > Record Type = Outbound Animal > Outbound Type = Transfer Out to Council',
            'Transfer Out - To Rescue' => 'Start Referral > Record Type = Outbound Animal > Outbound Type = Transfer Out to Rescue',
            'Unassisted Death' => 'Update To Deceased > Stage = Out > Status = Unassisted Death > Deceased Date',
            'Unassisted Death In Foster' => 'Update To Deceased > Stage = Out > Status = Unassisted Death > Deceased Date',
            'Unassisted Death - In Foster' => 'Update To Deceased > Stage = Out > Status = Unassisted Death > Deceased Date'
    };

    public static Boolean triggeredFromRecordPage = false;
    public static Boolean uploadToPetRescueIgnoringUpdateConditions = false;

    public animalos_AnimalDomain(List <sObject> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new animalos_AnimalDomain(sObjectList);
        }
    }

    public override void onBeforeInsert() {
        this.populateAboutMeFields(this.Records, null);
    }

    public override void onAfterInsert() {
        this.createHEAAnimalAlert(this.Records, null);
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        this.handleAnimalReleasedFieldsChange(this.Records, existingRecords);
        this.validateProtectiveCustodyStatus(this.Records, existingRecords);
        this.populateAboutMeFields(this.Records, existingRecords);
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        this.postAnimalToPetRescue(this.Records, existingRecords);
        this.sendReadyForReleaseNotification(this.Records, existingRecords);
        this.createHEAAnimalAlert(this.Records, existingRecords);
    }

    private void handleAnimalReleasedFieldsChange(List<sObject> records, Map<Id, sObject> existingRecords) {
        for (animalos__Animal__c animal : (List<animalos__Animal__c>) records) {
            animalos__Animal__c existingAnimal = (animalos__Animal__c) existingRecords.get(animal.Id);
            if (animal.aos_Animal_Released__c && vertic_Utils.sObjects.isSomeFieldChanged(
                    animal, existingAnimal, new List<SObjectField>{
                            animalos__Animal__c.aos_Animal_Released__c
                    }
            )) {
                animal.aos_Animal_Released_By__c = UserInfo.getUserId();
            }
            if (animal.aos_Animal_is_Ready_for_Release__c && vertic_Utils.sObjects.isSomeFieldChanged(
                    animal, existingAnimal, new List<SObjectField>{
                            animalos__Animal__c.aos_Animal_is_Ready_for_Release__c
                    }
            )) {
                animal.aos_Declared_Ready_For_Release__c = UserInfo.getUserId();
            }
        }
    }

    private void createHEAAnimalAlert(List<sObject> records, Map<Id, sObject> existingRecords) {

        List<animalos__Alert__c> animalAlertsForUpsert = new List<animalos__Alert__c>();
        Set<String> animalIds = vertic_Utils.sObjects.getStringFieldValues(records, animalos__Animal__c.Id);

        Map<String, SObject> activeAnimalAlertByAnimalId = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, animalos__Target_Record_Id__c, animalos__Alert_Message__c
                FROM animalos__Alert__c
                WHERE animalos__Target_Record_Id__c IN :animalIds AND animalos__Alert_Message__c = 'This is a HEA/BEQUEST pet.  DO NOT EUTHANISE.  VETS, please read animal notes. Any concerns please contact Philanthropy on 07 3258 5645.'
                AND animalos__Start_Date_Time__c <= TODAY AND (animalos__End_Date_Time__c = NULL OR animalos__End_Date_Time__c > TODAY)
        ], animalos__Alert__c.animalos__Target_Record_Id__c);

        for (animalos__Animal__c animal : (List<animalos__Animal__c>) records) {

            Boolean isCreated = Trigger.isInsert && existingRecords == null;
            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && vertic_Utils.sObjects.isSomeFieldChanged(
                    animal, existingRecords.get(animal.Id), new List<SObjectField>{
                            animalos__Animal__c.aos_Opportunity__c
                    }
            );

            if ((isCreated || isUpdated) && animal.aos_Opportunity__c != null) {
                animalAlertsForUpsert.add(
                        new animalos__Alert__c(
                                animalos__Target_Record_Id__c = animal.Id,
                                animalos__Alert_Message__c = 'This is a HEA/BEQUEST pet.  DO NOT EUTHANISE.  VETS, please read animal notes. Any concerns please contact Philanthropy on 07 3258 5645.',
                                animalos__Message_Formatted__c = '<p><b>This is a HEA/BEQUEST pet.  DO NOT EUTHANISE.  VETS, please read animal notes. Any concerns please contact Philanthropy on 07 3258 5645.</b></p>',
                                animalos__Start_Date_Time__c = Datetime.now(),
                                animalos__Active__c = true,
                                animalos__Display_Created_Date__c = false,
                                animalos__Modal_Button_Label__c = 'Acknowledge',
                                animalos__Modal_Title__c = 'Alert',
                                animalos__Mode__c = 'Sticky',
                                animalos__Style__c = 'Alert',
                                animalos__Target_Object__c = 'animalos__animal__c',
                                animalos__Variant__c = 'Error'
                        )
                );
            } else if (isUpdated && animal.aos_Opportunity__c == null) {
                animalos__Alert__c activeAlert = (animalos__Alert__c) activeAnimalAlertByAnimalId.get(animal.Id);
                if (activeAlert != null) {
                    activeAlert.animalos__End_Date_Time__c = Datetime.now();
                    activeAlert.animalos__Active__c = false;
                    animalAlertsForUpsert.add(activeAlert);
                }
            }
        }

        upsert animalAlertsForUpsert;
    }


    private void postAnimalToPetRescue(List<sObject> records, Map<Id, sObject> existingRecords) {

        if ('true'.equalsIgnoreCase(vertic_SettingService.getValue('PETRESCUE_PROCESSING_DISABLED'))) {
            return;
        }

        vertic_AsyncProcess asyncProcess = new vertic_AsyncProcess();

        Map<String, Object> petRescueSettingsByLocationId = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(
                aos_PetRescue_Setting__mdt.getAll().values(),
                aos_PetRescue_Setting__mdt.aos_Location_Id__c
        );

        for (animalos__Animal__c animal : (List<animalos__Animal__c>) records) {
            animalos__Animal__c existingAnimal = (animalos__Animal__c) existingRecords?.get(animal.Id);

            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingAnimal != null &&
                    (vertic_Utils.sObjects.isSomeFieldChanged(
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

                    aos_Async_Process__c vap = vertic_AsyncProcess.create(
                            AnimalToPetRescueProc.class,
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

    private void sendReadyForReleaseNotification(List<sObject> records, Map<Id, sObject> existingRecords) {

        List<animalos__Animal__c> animalsReadyForRelease = new List<animalos__Animal__c>();

        for (animalos__Animal__c animal : (List<animalos__Animal__c>) records) {
            animalos__Animal__c existingAnimal = (animalos__Animal__c) existingRecords.get(animal.Id);
            if (animal.animalos__Current_Site__c != null && animal.aos_Animal_Released__c && vertic_Utils.sObjects.isSomeFieldChanged(
                    animal, existingAnimal, new List<SObjectField>{
                            animalos__Animal__c.aos_Animal_Released__c
                    }
            )) {
                animalsReadyForRelease.add(animal);
            }
        }

        if (!animalsReadyForRelease.isEmpty()) {

            EmailTemplate animalReadyForReleaseEmailTemplate = (EmailTemplate) vertic_Utils.arrays.firstOrNull([
                    SELECT Id, DeveloperName, Name
                    FROM EmailTemplate
                    WHERE DeveloperName = 'Animal_Released_Notification_1677242995294'
            ]);

            if (animalReadyForReleaseEmailTemplate == null) {
                return;
            }

            Set<Id> shelterIds = vertic_Utils.sObjects.getIdFieldValues(animalsReadyForRelease, animalos__Animal__c.animalos__Current_Site__c);

            Map<Id, animalos__Location__c> siteLocationsById = new Map<Id, animalos__Location__c>([
                    SELECT Id, aos_Shelter_Email__c
                    FROM animalos__Location__c
                    WHERE Id IN :shelterIds
            ]);

            if (UserInfo.getUserId() != null) {
                vertic_AsyncProcess asyncProcess = new vertic_AsyncProcess();

                for (animalos__Animal__c animal : animalsReadyForRelease) {
                    Messaging.SingleEmailMessage emailMessage = Messaging.renderStoredEmailTemplate(
                            animalReadyForReleaseEmailTemplate.Id,
                            UserInfo.getUserId(),
                            animal.Id
                    );

                    animalos__Location__c siteLocation = siteLocationsById.get(animal.animalos__Current_Site__c);

                    if (!String.isBlank(siteLocation.aos_Shelter_Email__c)) {
                        asyncProcess.add(
                                new vertic_SendEmailProc.EmailAsyncProcess(
                                        emailMessage.htmlBody,
                                        new List<String>{
                                                siteLocation.aos_Shelter_Email__c
                                        })
                                        .setSaveAsActivity(false)
                                        .setOrgWideEmail('events@rspcansw.org.au')
                                        .setSubject(emailMessage.getSubject())
                                        .toAsyncProcess());
                    }
                }

                asyncProcess.enqueue();
            }
        }
    }

    private void validateProtectiveCustodyStatus(List<SObject> records, Map<Id, sObject> existingRecords) {

        for (animalos__Animal__c animal : (List<animalos__Animal__c>) records) {
            animalos__Animal__c existingAnimal = (animalos__Animal__c) existingRecords?.get(animal.Id);

            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingAnimal != null
                    && vertic_Utils.sObjects.isSomeFieldChanged(
                    animal,
                    existingAnimal,
                    new List<SObjectField>{
                            animalos__Animal__c.animalos__Status__c
                    });
            Boolean existingStatusContainsProtectiveCustody = String.isNotBlank(existingAnimal?.animalos__Status__c) && existingAnimal?.animalos__Status__c?.containsIgnoreCase('Protective Custody');
            Boolean newStatusContainsProtectiveCustody = String.isNotBlank(animal.animalos__Status__c) && animal.animalos__Status__c?.containsIgnoreCase('Protective Custody');

            if (isUpdated && existingStatusContainsProtectiveCustody && !newStatusContainsProtectiveCustody && animal.aos_Animal_Released_By__c == null) {
                animal.addError('Animal status can\'t be changed to ' + animal.animalos__Status__c + ' because Animal Released By field is empty');
            }
        }
    }

    private void populateAboutMeFields(List<sObject> records, Map<Id, sObject> existingRecords) {
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


            if ((isCreated || isUpdated)) {
                animal.aos_About_Me_Adoptapet__c = this.generateAboutMeField(animal, 'Adoptapet');
                animal.aos_About_Me_PetRescue__c = this.generateAboutMeField(animal, 'PetRescue');
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