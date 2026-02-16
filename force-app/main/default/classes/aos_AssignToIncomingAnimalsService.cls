public class aos_AssignToIncomingAnimalsService {


    public static void handleAssignToIncomingAnimals(List<SObject> records) {
        handleAssignToIncomingAnimals(records, null);
    }

    public static void handleAssignToIncomingAnimals(List<SObject> records, Map<Id, sObject> existingRecords) {

        Set<String> animalsIds = new Set<String>();

        Map<String, List<animalos__Animal__c>> animalTypesMap = new Map<String, List<animalos__Animal__c>>();

        for (animalos__Animal__c animalItem : (List<animalos__Animal__c>) records) {
            if (animalItem.animalos__Stage__c != 'Pre-Intake' && animalItem.animalos__Stage__c != 'Out') {

                if (animalTypesMap.containsKey(animalItem.animalos__Type__c)) {
                    animalTypesMap.get(animalItem.animalos__Type__c).add(animalItem);
                } else {
                    animalTypesMap.put(animalItem.animalos__Type__c, new List<animalos__Animal__c> { animalItem });
                }

                animalsIds.add(animalItem.Id);
            }
        }

        if (animalTypesMap.isEmpty()) {
            return;
        }


        String animalTypesMultiSelectStr = String.join(new List<String>(animalTypesMap.keySet()), ',');

        Map<String, animalos__Action_Plan__c> actionPlansMap = new Map<String, animalos__Action_Plan__c>([
            SELECT Id, animalos__Animal_Type__c
            FROM animalos__Action_Plan__c
            WHERE animalos__Animal_Type__c INCLUDES (:animalTypesMultiSelectStr)
                AND aos_Assign_To_Incoming_Animals__c = TRUE
                AND animalos__Status__c = 'Active'
        ]);

        Map<String, List<SObject>> actionPlansByAnimalType = aos_Utils.sObjects.getSObjectsListByAnyFieldMap(
            actionPlansMap.values(),
            animalos__Action_Plan__c.animalos__Animal_Type__c
        );

        Map<String, Set<String>> existingAnimalActionPlansIdsByAnimal = new Map<String, Set<String>>();

        for (animalos__Animal_Action_Plan__c animalActionPlanItem : [
            SELECT animalos__Animal__c, animalos__Action_Plan__c
            FROM animalos__Animal_Action_Plan__c
            WHERE animalos__Animal__c IN :animalsIds
                AND animalos__Action_Plan__c IN :actionPlansMap.keySet()
                AND animalos__Active__c = TRUE
        ]) {

            if (existingAnimalActionPlansIdsByAnimal.containsKey(animalActionPlanItem.animalos__Animal__c)) {
                existingAnimalActionPlansIdsByAnimal.get(animalActionPlanItem.animalos__Animal__c).add(animalActionPlanItem.animalos__Action_Plan__c);
            } else {
                existingAnimalActionPlansIdsByAnimal.put(animalActionPlanItem.animalos__Animal__c, new Set<String> { animalActionPlanItem.animalos__Action_Plan__c });
            }
        }


        List<animalos__Animal_Action_Plan__c> animalActionPlansForCreate = new List<animalos__Animal_Action_Plan__c>();

        for (String actionPlanAnimalType : actionPlansByAnimalType.keySet()) {
            List<animalos__Action_Plan__c> actionPlans = (List<animalos__Action_Plan__c>) actionPlansByAnimalType.get(actionPlanAnimalType);

            List<String> actionPlanAnimalTypeList = actionPlanAnimalType.split(';');

            for (animalos__Action_Plan__c actionPlanItem : actionPlans) {

                for (String animalTypeItem : actionPlanAnimalTypeList) {

                    if (!animalTypesMap.containsKey(animalTypeItem)) continue;

                    for (animalos__Animal__c animalItem : animalTypesMap.get(animalTypeItem)) {

                        if (
                            isExcludeExistingAnimalActionPlans(existingAnimalActionPlansIdsByAnimal, animalItem.Id, actionPlanItem.Id) == true
                        ) continue;

                        animalActionPlansForCreate.add(
                            new animalos__Animal_Action_Plan__c(
                                animalos__Animal__c = animalItem.Id,
                                animalos__Action_Plan__c = actionPlanItem.Id,
                                animalos__Active__c = true,
                                animalos__Start_Date__c = Date.today()
                            )
                        );
                    }
                }
            }
        }

        if (!animalActionPlansForCreate.isEmpty()) {
            insert animalActionPlansForCreate;
        }
    }


    private static Boolean isExcludeExistingAnimalActionPlans(Map<String, Set<String>> existingAnimalActionPlansIdsByAnimal, String animalId, String actionPlanId) {

        return existingAnimalActionPlansIdsByAnimal != null
                && existingAnimalActionPlansIdsByAnimal.containsKey(animalId)
                && !existingAnimalActionPlansIdsByAnimal.get(animalId).isEmpty()
                && existingAnimalActionPlansIdsByAnimal.get(animalId).contains(actionPlanId);
    }
}