public class CalculateContactTotals extends vertic_LookupRollupSequentialProc.AbstractBatchableProcessor {

    public override void processScope(List<SObject> records) {

        List<Contact> contactsForUpdate = new List<Contact>();

        Map<String, Object> locationsByContact = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, Foster_Animal_Count_Total__c, Foster_Animal_Count_Last_5_Years__c, animalos__Contact__c,
                        Foster_Animal_Count_Last_Month__c, Foster_Animal_Count_Last_Year__c, Foster_Animal_Count_This_Year__c,
                        Foster_Animal_Count_This_Month__c, Foster_Animal_Special_Needs_Count__c, Foster_Days_Total__c,
                        Foster_Days_Last_5_Years__c, Foster_Days_Last_Year__c, Foster_Days_Last_Month__c,
                        Foster_Days_This_Year__c, Foster_Days_This_Month__c, Foster_Days_Special_Needs__c
                FROM animalos__Location__c
                WHERE RecordType.DeveloperName = 'Foster' AND animalos__Contact__c IN :records
        ], animalos__Location__c.animalos__Contact__c);

        Map<String, Object> movementsByContact = aggregateResultToMap([
                SELECT animalos__Location__r.animalos__Contact__c, COUNT_DISTINCT(animalos__Start_Date_Time__c) distinctStartDate
                FROM animalos__Movement__c
                WHERE animalos__Location__r.animalos__Contact__c != NULL
                AND animalos__Location__r.animalos__Contact__c IN :records
                GROUP BY animalos__Location__r.animalos__Contact__c
        ], 'animalos__Contact__c', 'distinctStartDate');

        Map<String, Object> adoptionsByContact = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, animalos__Scheduled_Date_Time__c, animalos__Contact__c
                FROM animalos__Referral__c
                WHERE animalos__Contact__c IN :records
                AND RecordType.DeveloperName = 'Adoption'
        ], animalos__Referral__c.animalos__Contact__c);


        for (Contact contact : (List<Contact>) records) {

            Contact contactForUpdate = contact.clone(true, true, false, false);

            contactForUpdate = this.calculateLocationMovements(contactForUpdate, (List<sObject>) locationsByContact.get(contactForUpdate.Id));
            contactForUpdate = this.calculateAdoptions(contactForUpdate, (List<sObject>) adoptionsByContact.get(contactForUpdate.Id));

            contactForUpdate.Foster_Instances__c = movementsByContact.get(contactForUpdate.Id) == null ? 0 : (Decimal) movementsByContact.get(contactForUpdate.Id);

            if (vertic_Utils.sObjects.isSomeFieldChanged(contactForUpdate, contact, new List<String>{
                    'Foster_Animal_Count_Total__c', 'Foster_Animal_Count_Last_5_Years__c', 'Foster_Animal_Count_Last_Month__c', 'Foster_Animal_Count_Last_Year__c',
                    'Foster_Animal_Count_This_Year__c', 'Foster_Animal_Count_This_Month__c', 'Foster_Animal_Special_Needs_Count__c', 'Foster_Days_Total__c', 'Foster_Days_Last_5_Years__c',
                    'Foster_Days_Last_Year__c', 'Foster_Days_Last_Month__c', 'Foster_Days_This_Year__c', 'Foster_Days_This_Month__c', 'Foster_Days_Special_Needs__c',
                    'Adoption_Count__c', 'Adoptions_This_Year__c', 'Adoptions_Last_5_Years__c', 'Adoptions_Last_10_Years__c',
                    'Foster_Instances__c', 'Adopter__c'
            })) {
                contactsForUpdate.add(contactForUpdate);
            }
        }

        update contactsForUpdate;
    }

    private Contact calculateAdoptions(Contact contactForUpdate, List<SObject> adoptions) {

        contactForUpdate.Adoption_Count__c = adoptions == null ? 0 : adoptions.size();
        contactForUpdate.Adoptions_This_Year__c = 0;
        contactForUpdate.Adoptions_Last_5_Years__c = 0;
        contactForUpdate.Adoptions_Last_10_Years__c = 0;

        if (adoptions != null) {
            for (animalos__Referral__c adoption : (List<animalos__Referral__c>) adoptions) {

                if (adoption.animalos__Scheduled_Date_Time__c >= Date.today().addYears(-1)) {
                    contactForUpdate.Adoptions_This_Year__c += 1;
                }

                if (adoption.animalos__Scheduled_Date_Time__c >= Date.today().addYears(-5)) {
                    contactForUpdate.Adoptions_Last_5_Years__c += 1;
                }

                if (adoption.animalos__Scheduled_Date_Time__c >= Date.today().addYears(-10)) {
                    contactForUpdate.Adoptions_Last_10_Years__c += 1;
                }

                contactForUpdate.First_Adoption_Date__c = contactForUpdate.First_Adoption_Date__c == null ? adoption.animalos__Scheduled_Date_Time__c?.date() :
                        contactForUpdate.First_Adoption_Date__c > adoption.animalos__Scheduled_Date_Time__c ? adoption.animalos__Scheduled_Date_Time__c?.date() :
                                contactForUpdate.First_Adoption_Date__c;

                contactForUpdate.Last_Adoption_Date__c = contactForUpdate.Last_Adoption_Date__c == null ? adoption.animalos__Scheduled_Date_Time__c?.date() :
                        contactForUpdate.Last_Adoption_Date__c > adoption.animalos__Scheduled_Date_Time__c ? contactForUpdate.Last_Adoption_Date__c :
                                adoption.animalos__Scheduled_Date_Time__c?.date();
            }
        }

        return contactForUpdate;
    }

    private Contact calculateLocationMovements(Contact contactForUpdate, List<SObject> locations) {

        contactForUpdate.Foster_Animal_Count_Total__c = 0;
        contactForUpdate.Foster_Animal_Count_Last_5_Years__c = 0;
        contactForUpdate.Foster_Animal_Count_Last_Month__c = 0;
        contactForUpdate.Foster_Animal_Count_Last_Year__c = 0;
        contactForUpdate.Foster_Animal_Count_This_Year__c = 0;
        contactForUpdate.Foster_Animal_Count_This_Month__c = 0;
        contactForUpdate.Foster_Animal_Special_Needs_Count__c = 0;

        contactForUpdate.Foster_Days_Total__c = 0;
        contactForUpdate.Foster_Days_Last_5_Years__c = 0;
        contactForUpdate.Foster_Days_Last_Year__c = 0;
        contactForUpdate.Foster_Days_Last_Month__c = 0;
        contactForUpdate.Foster_Days_This_Year__c = 0;
        contactForUpdate.Foster_Days_This_Month__c = 0;
        contactForUpdate.Foster_Days_Special_Needs__c = 0;

        if (locations != null) {
            for (animalos__Location__c location : (List<animalos__Location__c>) locations) {
                contactForUpdate.Foster_Animal_Count_Total__c += vertic_Utils.objects.defaultIfNull(location.Foster_Animal_Count_Total__c, 0);
                contactForUpdate.Foster_Animal_Count_Last_5_Years__c += vertic_Utils.objects.defaultIfNull(location.Foster_Animal_Count_Last_5_Years__c, 0);
                contactForUpdate.Foster_Animal_Count_Last_Month__c += vertic_Utils.objects.defaultIfNull(location.Foster_Animal_Count_Last_Month__c, 0);
                contactForUpdate.Foster_Animal_Count_Last_Year__c += vertic_Utils.objects.defaultIfNull(location.Foster_Animal_Count_Last_Year__c, 0);
                contactForUpdate.Foster_Animal_Count_This_Month__c += vertic_Utils.objects.defaultIfNull(location.Foster_Animal_Count_This_Month__c, 0);
                contactForUpdate.Foster_Animal_Count_This_Year__c += vertic_Utils.objects.defaultIfNull(location.Foster_Animal_Count_This_Year__c, 0);
                contactForUpdate.Foster_Animal_Special_Needs_Count__c += vertic_Utils.objects.defaultIfNull(location.Foster_Animal_Special_Needs_Count__c, 0);

                contactForUpdate.Foster_Days_Total__c += vertic_Utils.objects.defaultIfNull(location.Foster_Days_Total__c, 0);
                contactForUpdate.Foster_Days_Last_5_Years__c += vertic_Utils.objects.defaultIfNull(location.Foster_Days_Last_5_Years__c, 0);
                contactForUpdate.Foster_Days_Last_Year__c += vertic_Utils.objects.defaultIfNull(location.Foster_Days_Last_Year__c, 0);
                contactForUpdate.Foster_Days_Last_Month__c += vertic_Utils.objects.defaultIfNull(location.Foster_Days_Last_Month__c, 0);
                contactForUpdate.Foster_Days_This_Year__c += vertic_Utils.objects.defaultIfNull(location.Foster_Days_This_Year__c, 0);
                contactForUpdate.Foster_Days_This_Month__c += vertic_Utils.objects.defaultIfNull(location.Foster_Days_This_Month__c, 0);
                contactForUpdate.Foster_Days_Special_Needs__c += vertic_Utils.objects.defaultIfNull(location.Foster_Days_Special_Needs__c, 0);
            }
        }

        return contactForUpdate;
    }
    private Map<String, Object> aggregateResultToMap(List<AggregateResult> aggregateResults, String groupedBy, String resultName) {
        Map<String, Object> aggregateResultMap = new Map<String, Object>();

        for (AggregateResult aggregateResult : aggregateResults) {
            aggregateResultMap.put(
                    (String) aggregateResult.get(groupedBy),
                    aggregateResult.get(resultName)
            );
        }

        return aggregateResultMap;
    }

    public override Database.QueryLocator getLocator() {
        return Database.getQueryLocator(
                'SELECT Id, ' +
                        'First_Adoption_Date__c, Last_Adoption_Date__c, Adoption_Count__c, Adoptions_This_Year__c, Adoptions_Last_5_Years__c, Adoptions_Last_10_Years__c, ' +
                        'Foster_Animal_Count_Total__c, Foster_Animal_Count_Last_5_Years__c, Foster_Animal_Count_Last_Month__c, Foster_Animal_Count_Last_Year__c, Foster_Animal_Count_This_Month__c, Foster_Animal_Special_Needs_Count__c, ' +
                        'Foster_Days_Total__c, Foster_Days_Last_5_Years__c, Foster_Days_Last_Year__c, Foster_Days_Last_Month__c, Foster_Days_This_Year__c, Foster_Days_This_Month__c, Foster_Days_Special_Needs__c, Foster_Animal_Count_This_Year__c, ' +
                        'Foster_Instances__c, Adopter__c ' +
                        'FROM Contact'
        );
    }

}