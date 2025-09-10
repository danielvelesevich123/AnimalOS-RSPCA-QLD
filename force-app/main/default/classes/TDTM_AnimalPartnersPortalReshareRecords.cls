global class TDTM_AnimalPartnersPortalReshareRecords extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert, animalos.TDTM.AfterUpdate {
    public void onAfterInsert(List<SObject> records) {
        this.reshareRecords(records, null);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.reshareRecords(records, (Map<Id, animalos__Animal__c>) oldMap);
    }

    public void reshareRecords(List<animalos__Animal__c> animals, Map<Id, animalos__Animal__c> existingAnimals) {
        Set<Id> locationIdsToBeProceeded = new Set<Id>();

        for (animalos__Animal__c animalVar : animals) {
            Boolean isInsert = Trigger.isInsert;
            Boolean isUpdate = Trigger.isUpdate && existingAnimals != null &&
                    existingAnimals.containsKey(animalVar.Id);
            Boolean isCurrentSiteUpdated = isUpdate &&
                    vertic_Utils.sObjects.isSomeFieldChanged(animalVar, existingAnimals.get(animalVar.Id), new List<SObjectField>{
                            animalos__Animal__c.animalos__Current_Site__c
                    });
            Boolean isCurrentBlockUpdated = isUpdate &&
                    vertic_Utils.sObjects.isSomeFieldChanged(animalVar, existingAnimals.get(animalVar.Id), new List<SObjectField>{
                            animalos__Animal__c.animalos__Current_Block__c
                    });
            Boolean isCurrentUnitUpdated = isUpdate &&
                    vertic_Utils.sObjects.isSomeFieldChanged(animalVar, existingAnimals.get(animalVar.Id), new List<SObjectField>{
                            animalos__Animal__c.animalos__Current_Unit__c
                    });

            //either inserted or updated to new location
            if (isInsert || isCurrentSiteUpdated) {
                if (String.isNotBlank(animalVar.animalos__Current_Site__c)) {
                    locationIdsToBeProceeded.add(animalVar.animalos__Current_Site__c);
                }
                if (isCurrentSiteUpdated && String.isNotBlank(existingAnimals.get(animalVar.Id).animalos__Current_Site__c)) {
                    locationIdsToBeProceeded.add(existingAnimals.get(animalVar.Id).animalos__Current_Site__c);
                }
            }

            if (isInsert || isCurrentBlockUpdated) {
                if (String.isNotBlank(animalVar.animalos__Current_Block__c)) {
                    locationIdsToBeProceeded.add(animalVar.animalos__Current_Block__c);
                }
                if (isCurrentBlockUpdated && String.isNotBlank(existingAnimals.get(animalVar.Id).animalos__Current_Block__c)) {
                    locationIdsToBeProceeded.add(existingAnimals.get(animalVar.Id).animalos__Current_Block__c);
                }
            }

            if (isInsert || isCurrentUnitUpdated) {
                if (String.isNotBlank(animalVar.animalos__Current_Unit__c)) {
                    locationIdsToBeProceeded.add(animalVar.animalos__Current_Unit__c);
                }
                if (isCurrentUnitUpdated && String.isNotBlank(existingAnimals.get(animalVar.Id).animalos__Current_Unit__c)) {
                    locationIdsToBeProceeded.add(existingAnimals.get(animalVar.Id).animalos__Current_Unit__c);
                }
            }
        }

        if (!locationIdsToBeProceeded.isEmpty()) {
            Set<Id> userIds = vertic_Utils.sObjects.getIdFieldValues([
                    SELECT Id,User__c
                    FROM Location_Volunteer__c
                    WHERE Location__c IN :locationIdsToBeProceeded
            ], Location_Volunteer__c.User__c);

            if(!userIds.isEmpty()) {
                PartnersPortalReshareRecordsProc.submitVAPsByUserIds(userIds);
            }
        }
    }
}