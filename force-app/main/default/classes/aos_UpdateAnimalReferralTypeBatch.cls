global class aos_UpdateAnimalReferralTypeBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, animalos__Animal__r.animalos__Type__c, animalos__Animal__r.animalos__Date_of_Birth__c, ' +
                'aos_Scheduled_Date_Time__c ' +
                'FROM animalos__Animal_Referral__c ' +
                'WHERE animalos__Animal__c != NULL AND animalos__Animal__r.animalos__Type__c != NULL AND aos_Type__c = NULL'
        );
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        for (animalos__Animal_Referral__c animalReferral : (List<animalos__Animal_Referral__c>) scope) {
            animalos__Animal__c animal = animalReferral.animalos__Animal__r;

            animalReferral.aos_Type__c = animal.animalos__Type__c;

            Boolean isDogOrCat = 'Dog'.equals(animal.animalos__Type__c) || 'Cat'.equals(animal.animalos__Type__c);
            Boolean enteredLessThanInSixMonths = animal.animalos__Date_of_Birth__c != null && animalReferral.aos_Scheduled_Date_Time__c != null
                    && animal.animalos__Date_of_Birth__c.monthsBetween(animalReferral.aos_Scheduled_Date_Time__c.date()) < 6;

            if (isDogOrCat && enteredLessThanInSixMonths) {
                animalReferral.aos_Type__c = 'Dog'.equals(animal.animalos__Type__c) ? 'Puppy' : 'Kitten';
            }
        }

        update scope;
    }

    global void finish(Database.BatchableContext BC) {
    }

}