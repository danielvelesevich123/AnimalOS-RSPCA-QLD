global class TDTM_aos_AnimalPartnersPortalReshare extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert, animalos.TDTM.AfterUpdate {
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
                    aos_Utils.sObjects.isSomeFieldChanged(animalVar, existingAnimals.get(animalVar.Id), new List<SObjectField>{
                            animalos__Animal__c.animalos__Current_Site__c
                    });
            Boolean isCurrentBlockUpdated = isUpdate &&
                    aos_Utils.sObjects.isSomeFieldChanged(animalVar, existingAnimals.get(animalVar.Id), new List<SObjectField>{
                            animalos__Animal__c.animalos__Current_Block__c
                    });
            Boolean isCurrentUnitUpdated = isUpdate &&
                    aos_Utils.sObjects.isSomeFieldChanged(animalVar, existingAnimals.get(animalVar.Id), new List<SObjectField>{
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
            Set<Id> userIds = aos_Utils.sObjects.getIdFieldValues([
                    SELECT Id,aos_User__c
                    FROM aos_Location_Volunteer__c
                    WHERE aos_Location__c IN :locationIdsToBeProceeded
            ], aos_Location_Volunteer__c.aos_User__c);

            if(!userIds.isEmpty()) {
                aos_PartnersPortalReshareRecordsProc.submitVAPsByUserIds(userIds);
            }
        }
    }
}