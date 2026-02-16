global class aos_CalcRollupsContactLocation extends animalos.vertic_SequentialScheduledBatch {
    global override Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id, Foster_Animal_Count_Total__c,
                        Foster_Animal_Count_Last_5_Years__c, Foster_Animal_Count_Last_Month__c,
                        Foster_Animal_Count_Last_Year__c, Foster_Animal_Count_This_Month__c,
                        Foster_Animal_Special_Needs_Count__c, Foster_Days_Total__c, Foster_Days_Last_5_Years__c,
                        Foster_Days_Last_Year__c, Foster_Days_Last_Month__c, Foster_Days_This_Year__c,
                        Foster_Days_This_Month__c, Foster_Days_Special_Needs__c, Foster_Animal_Count_This_Year__c,
                        Foster_Instances__c
                FROM Contact
                WHERE Id IN (
                        SELECT animalos__Contact__c
                        FROM animalos__Location__c
                        WHERE LastModifiedDate >= :this.sequentialBatchSetting.animalos__Last_Calculation_Datetime__c
                )
        ]);
    }

    global override void process(List<SObject> records) {

        Map<String, Object> locationsByContact = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, aos_Foster_Animal_Count_Total__c, aos_Foster_Animal_Count_Last_5_Years__c, animalos__Contact__c,
                        aos_Foster_Animal_Count_Last_Month__c, aos_Foster_Animal_Count_Last_Year__c, aos_Foster_Animal_Count_This_Year__c,
                        aos_Foster_Animal_Count_This_Month__c, aos_Foster_Animal_Special_Needs_Count__c, aos_Foster_Days_Total__c,
                        aos_Foster_Days_Last_5_Years__c, aos_Foster_Days_Last_Year__c, aos_Foster_Days_Last_Month__c,
                        aos_Foster_Days_This_Year__c, aos_Foster_Days_This_Month__c, aos_Foster_Days_Special_Needs__c
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


        for (Contact contact : (List<Contact>) records) {

            List<animalos__Location__c> locations = (List<sObject>) locationsByContact.get(contact.Id);

            contact.Foster_Instances__c = movementsByContact.get(contact.Id) == null ? 0 : (Decimal) movementsByContact.get(contact.Id);
            this.calculateLocationMovements(contact, locations);
        }

        update records;
    }


    private void calculateLocationMovements(Contact contactForUpdate, List<SObject> locations) {

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
                contactForUpdate.Foster_Animal_Count_Total__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Animal_Count_Total__c, 0);
                contactForUpdate.Foster_Animal_Count_Last_5_Years__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Animal_Count_Last_5_Years__c, 0);
                contactForUpdate.Foster_Animal_Count_Last_Month__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Animal_Count_Last_Month__c, 0);
                contactForUpdate.Foster_Animal_Count_Last_Year__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Animal_Count_Last_Year__c, 0);
                contactForUpdate.Foster_Animal_Count_This_Month__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Animal_Count_This_Month__c, 0);
                contactForUpdate.Foster_Animal_Count_This_Year__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Animal_Count_This_Year__c, 0);
                contactForUpdate.Foster_Animal_Special_Needs_Count__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Animal_Special_Needs_Count__c, 0);

                contactForUpdate.Foster_Days_Total__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Days_Total__c, 0);
                contactForUpdate.Foster_Days_Last_5_Years__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Days_Last_5_Years__c, 0);
                contactForUpdate.Foster_Days_Last_Year__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Days_Last_Year__c, 0);
                contactForUpdate.Foster_Days_Last_Month__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Days_Last_Month__c, 0);
                contactForUpdate.Foster_Days_This_Year__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Days_This_Year__c, 0);
                contactForUpdate.Foster_Days_This_Month__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Days_This_Month__c, 0);
                contactForUpdate.Foster_Days_Special_Needs__c += vertic_Utils.objects.defaultIfNull(location.aos_Foster_Days_Special_Needs__c, 0);
            }
        }
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

}