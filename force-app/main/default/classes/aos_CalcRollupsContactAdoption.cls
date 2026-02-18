global class aos_CalcRollupsContactAdoption extends animalos.vertic_SequentialScheduledBatch {
    global override Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id,
                        aos_First_Adoption_Date__c, aos_Last_Adoption_Date__c, aos_Adoption_Count__c, aos_Adoptions_This_Year__c,
                        aos_Adoptions_Last_5_Years__c, aos_Adoptions_Last_10_Years__c, aos_Adopter__c
                FROM Contact
                WHERE Id IN (
                        SELECT animalos__Contact__c
                        FROM animalos__Referral__c
                        WHERE RecordType.DeveloperName = 'Adoption' AND LastModifiedDate >= :this.sequentialBatchSetting.animalos__Last_Calculation_Datetime__c
                )
        ]);
    }

    global override void process(List<SObject> records) {

        Map<String, Object> adoptionsByContact = aos_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, animalos__Scheduled_Date_Time__c, animalos__Contact__c
                FROM animalos__Referral__c
                WHERE animalos__Contact__c IN :records
                AND RecordType.DeveloperName = 'Adoption'
        ], animalos__Referral__c.animalos__Contact__c);

        for (Contact contact : (List<Contact>) records) {
            List<animalos__Referral__c> adoptions = (List<sObject>) adoptionsByContact.get(contact.Id);
            this.calculateAdoptions(contact, adoptions);
        }

        update records;
    }



    private void calculateAdoptions(Contact contactForUpdate, List<SObject> adoptions) {
        contactForUpdate.aos_Adoption_Count__c = adoptions == null ? 0 : adoptions.size();
        contactForUpdate.aos_Adoptions_This_Year__c = 0;
        contactForUpdate.aos_Adoptions_Last_5_Years__c = 0;
        contactForUpdate.aos_Adoptions_Last_10_Years__c = 0;

        if (adoptions != null) {
            for (animalos__Referral__c adoption : (List<animalos__Referral__c>) adoptions) {

                if (adoption.animalos__Scheduled_Date_Time__c >= Date.today().addYears(-1)) {
                    contactForUpdate.aos_Adoptions_This_Year__c += 1;
                }

                if (adoption.animalos__Scheduled_Date_Time__c >= Date.today().addYears(-5)) {
                    contactForUpdate.aos_Adoptions_Last_5_Years__c += 1;
                }

                if (adoption.animalos__Scheduled_Date_Time__c >= Date.today().addYears(-10)) {
                    contactForUpdate.aos_Adoptions_Last_10_Years__c += 1;
                }

                contactForUpdate.aos_First_Adoption_Date__c = contactForUpdate.aos_First_Adoption_Date__c == null ? adoption.animalos__Scheduled_Date_Time__c?.date() :
                        contactForUpdate.aos_First_Adoption_Date__c > adoption.animalos__Scheduled_Date_Time__c ? adoption.animalos__Scheduled_Date_Time__c?.date() :
                                contactForUpdate.aos_First_Adoption_Date__c;

                contactForUpdate.aos_Last_Adoption_Date__c = contactForUpdate.aos_Last_Adoption_Date__c == null ? adoption.animalos__Scheduled_Date_Time__c?.date() :
                        contactForUpdate.aos_Last_Adoption_Date__c > adoption.animalos__Scheduled_Date_Time__c ? contactForUpdate.aos_Last_Adoption_Date__c :
                                adoption.animalos__Scheduled_Date_Time__c?.date();
            }
        }
    }
}