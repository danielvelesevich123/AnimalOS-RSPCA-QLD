global class TDTM_aos_AnimalHEAAlert extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert, animalos.TDTM.AfterUpdate {

    public void onAfterInsert(List<SObject> records) {
        createHEAAnimalAlert(records, null);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        createHEAAnimalAlert(records, oldMap);
    }

    private void createHEAAnimalAlert(List<SObject> records, Map<Id, SObject> existingRecords) {
        List<animalos__Alert__c> animalAlertsForUpsert = new List<animalos__Alert__c>();
        Set<String> animalIds = aos_Utils.sObjects.getStringFieldValues(records, animalos__Animal__c.Id);

        Map<String, SObject> activeAnimalAlertByAnimalId = aos_Utils.sObjects.getSObjectsByAnyFieldMap([
            SELECT Id, animalos__Target_Record_Id__c, animalos__Alert_Message__c
            FROM animalos__Alert__c
            WHERE animalos__Target_Record_Id__c IN :animalIds AND animalos__Alert_Message__c = 'This is a HEA/BEQUEST pet.  DO NOT EUTHANISE.  VETS, please read animal notes. Any concerns please contact Fundraising on 1300 777 221.'
            AND animalos__Start_Date_Time__c <= TODAY AND (animalos__End_Date_Time__c = NULL OR animalos__End_Date_Time__c > TODAY)
        ], animalos__Alert__c.animalos__Target_Record_Id__c);

        for (animalos__Animal__c animal : (List<animalos__Animal__c>) records) {

            Boolean isCreated = Trigger.isInsert && existingRecords == null;
            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && aos_Utils.sObjects.isSomeFieldChanged(
                animal, existingRecords.get(animal.Id), new List<SObjectField>{
                    animalos__Animal__c.aos_Opportunity__c
                }
            );

            if ((isCreated || isUpdated) && animal.aos_Opportunity__c != null) {
                animalAlertsForUpsert.add(
                    new animalos__Alert__c(
                        animalos__Target_Record_Id__c = animal.Id,
                        animalos__Alert_Message__c = 'This is a HEA/BEQUEST pet.  DO NOT EUTHANISE.  VETS, please read animal notes. Any concerns please contact Fundraising on 1300 777 221.',
                        animalos__Message_Formatted__c = '<p><b>This is a HEA/BEQUEST pet.  DO NOT EUTHANISE.  VETS, please read animal notes. Any concerns please contact Fundraising on 1300 777 221.</b></p>',
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
}