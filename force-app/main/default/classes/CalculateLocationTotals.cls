public without sharing class CalculateLocationTotals extends vertic_LookupRollupSequentialProc.AbstractBatchableProcessor {

    public override void processScope(List<SObject> records) {
        List<animalos__Location__c> locationsForUpdate = new List<animalos__Location__c>();

        Map<String, Object> movementsByLocationId = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, animalos__Location__c, animalos__Start_Date_Time__c,
                        animalos__End_Date_Time__c, animalos__Current__c,
                        animalos__Total_Time_Days__c
                FROM animalos__Movement__c
                WHERE animalos__Location__c IN :records
        ], animalos__Movement__c.animalos__Location__c);

        for (SObject sObj : records) {
            animalos__Location__c locationVar = (animalos__Location__c) sObj;
            animalos__Location__c locationClone = locationVar.clone();

            locationVar.aos_Foster_Animal_Count_Total__c = 0;
            locationVar.aos_Foster_Animal_Count_Last_5_Years__c = 0;
            locationVar.aos_Foster_Animal_Count_Last_Month__c = 0;
            locationVar.aos_Foster_Animal_Count_Last_Year__c = 0;
            locationVar.aos_Foster_Animal_Count_This_Year__c = 0;
            locationVar.aos_Foster_Animal_Count_This_Month__c = 0;
            locationVar.aos_Foster_Animal_Special_Needs_Count__c = 0;
            locationVar.aos_Foster_Days_Total__c = 0;
            locationVar.aos_Foster_Days_Last_5_Years__c = 0;
            locationVar.aos_Foster_Days_Last_Year__c = 0;
            locationVar.aos_Foster_Days_Last_Month__c = 0;
            locationVar.aos_Foster_Days_This_Year__c = 0;
            locationVar.aos_Foster_Days_This_Month__c = 0;
            locationVar.aos_Foster_Days_Special_Needs__c = 0;

            if (movementsByLocationId.get(locationVar.Id) != null) {

                List<animalos__Movement__c> locationMovements = (List<animalos__Movement__c>) movementsByLocationId.get(locationVar.Id);

                locationVar.aos_Foster_Animal_Count_Total__c = locationMovements.size();

                for (animalos__Movement__c movementVar : locationMovements) {
                    locationVar.aos_Foster_Days_Total__c += movementVar.animalos__Total_Time_Days__c;
                    if (movementVar.animalos__Start_Date_Time__c >= Date.today().addYears(-5) || movementVar.animalos__End_Date_Time__c >= Date.today().addYears(-5)) {
                        locationVar.aos_Foster_Animal_Count_Last_5_Years__c++;
                        locationVar.aos_Foster_Days_Last_5_Years__c += movementVar.animalos__Total_Time_Days__c;
                    }

                    if (movementVar.animalos__Start_Date_Time__c?.year() == Date.today().year() - 1 || movementVar.animalos__End_Date_Time__c?.year() == Date.today().year() - 1) {
                        locationVar.aos_Foster_Animal_Count_Last_Year__c++;
                        locationVar.aos_Foster_Days_Last_Year__c += movementVar.animalos__Total_Time_Days__c;
                    }

                    if ((movementVar.animalos__Start_Date_Time__c?.year() == Date.today().year())
                            || movementVar.animalos__End_Date_Time__c?.year() == Date.today().year()) {
                        locationVar.aos_Foster_Animal_Count_This_Year__c++;
                        locationVar.aos_Foster_Days_This_Year__c += movementVar.animalos__Total_Time_Days__c;
                        if (movementVar.animalos__Start_Date_Time__c?.month() == Date.today().month()
                                || movementVar.animalos__End_Date_Time__c?.month() == Date.today().month()) {
                            locationVar.aos_Foster_Animal_Count_This_Month__c++;
                            locationVar.aos_Foster_Days_This_Month__c += movementVar.animalos__Total_Time_Days__c;
                        }
                    }

                    if ((movementVar.animalos__Start_Date_Time__c?.year() == Date.today().year()
                            && movementVar.animalos__Start_Date_Time__c?.month() == Date.today().month() - 1)
                            || (movementVar.animalos__End_Date_Time__c?.year() == Date.today().year()
                            && movementVar.animalos__End_Date_Time__c?.month() == Date.today().month() - 1)
                            || (movementVar.animalos__Start_Date_Time__c?.year() == Date.today().year() - 1
                            && movementVar.animalos__Start_Date_Time__c?.month() == Date.today().addMonths(-1).month())
                            || (movementVar.animalos__End_Date_Time__c?.year() == Date.today().year() - 1
                            && movementVar.animalos__End_Date_Time__c?.month() == Date.today().addMonths(-1).month())) {
                        locationVar.aos_Foster_Animal_Count_Last_Month__c++;
                        locationVar.aos_Foster_Days_Last_Month__c += movementVar.animalos__Total_Time_Days__c;
                    }
                }
            }
            if (vertic_Utils.sObjects.isSomeFieldChanged(locationVar, locationClone, new List<String>{
                    'aos_Foster_Animal_Count_Total__c', 'aos_Foster_Animal_Count_Last_5_Years__c', 'aos_Foster_Animal_Count_Last_Month__c', 'aos_Foster_Animal_Count_Last_Year__c',
                    'aos_Foster_Animal_Count_This_Year__c', 'aos_Foster_Animal_Count_This_Month__c', 'aos_Foster_Animal_Special_Needs_Count__c'
            })) {
                locationsForUpdate.add(locationVar);
            }
        }

        update locationsForUpdate;
    }

    public override Database.QueryLocator getLocator() {
        return Database.getQueryLocator(
                'SELECT Id, aos_Foster_Animal_Count_Total__c, aos_Foster_Animal_Count_Last_5_Years__c, aos_Foster_Animal_Count_Last_Month__c, aos_Foster_Animal_Count_Last_Year__c, aos_Foster_Animal_Count_This_Year__c, ' +
                        'aos_Foster_Animal_Count_This_Month__c, aos_Foster_Animal_Special_Needs_Count__c, aos_Foster_Days_Total__c, aos_Foster_Days_Last_5_Years__c, aos_Foster_Days_Last_Year__c, aos_Foster_Days_Last_Month__c, aos_Foster_Days_This_Year__c, ' +
                        'aos_Foster_Days_This_Month__c, aos_Foster_Days_Special_Needs__c ' +
                        'FROM animalos__Location__c WHERE RecordType.DeveloperName = \'Foster\''
        );
    }
}