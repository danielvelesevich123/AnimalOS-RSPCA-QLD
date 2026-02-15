global class TDTM_LocationCreateVolunteer extends animalos.TDTM.Handler implements animalos.TDTM.AfterInsert, animalos.TDTM.AfterUpdate {
    public void onAfterInsert(List<SObject> records) {
        this.createLocationVolunteer(records, null);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.createLocationVolunteer(records, (Map<Id, animalos__Location__c>) oldMap);
    }

    public void createLocationVolunteer(List<animalos__Location__c> locations, Map<Id, animalos__Location__c> existingLocations) {
        List<animalos__Location__c> locationsToBeProceeded = new List<animalos__Location__c>();
        Id fosterRecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Location__c.SObjectType, 'Foster');

        for (animalos__Location__c locationVar : locations) {
            Boolean isInsert = Trigger.isInsert;
            Boolean isUpdate = Trigger.isUpdate && existingLocations != null &&
                    existingLocations.containsKey(locationVar.Id) &&
                    vertic_Utils.sObjects.isSomeFieldChanged(locationVar, existingLocations.get(locationVar.Id), new List<SObjectField>{
                            animalos__Location__c.animalos__Contact__c
                    });

            if ((isUpdate || (isInsert && String.isNotBlank(locationVar.animalos__Contact__c))) && fosterRecordTypeId.equals(locationVar.RecordTypeId)) {
                locationsToBeProceeded.add(locationVar);
            }
        }

        if (!locationsToBeProceeded.isEmpty()) {
            List<aos_Location_Volunteer__c> locationVolunteersToUpsert = new List<aos_Location_Volunteer__c>();
            List<aos_Location_Volunteer__c> locationVolunteersToDelete = new List<aos_Location_Volunteer__c>();
            Map<String, SObject> existingLocationVolunteersByLocationIds = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                    SELECT Id, aos_Location__c
                    FROM aos_Location_Volunteer__c
                    WHERE aos_Location__c IN :locationsToBeProceeded
            ], aos_Location_Volunteer__c.aos_Location__c);

            for (animalos__Location__c fosterLocation : locationsToBeProceeded) {
                if (Trigger.isInsert) {
                    locationVolunteersToUpsert.add(new aos_Location_Volunteer__c(
                            aos_Volunteer__c = fosterLocation.animalos__Contact__c,
                            aos_Location__c = fosterLocation.Id
                    ));
                }

                if (Trigger.isUpdate) {
                    if (String.isNotBlank(fosterLocation.animalos__Contact__c)) {
                        //upsert Location Volunteer if Contact value is updated from other value or from null.
                        locationVolunteersToUpsert.add(new aos_Location_Volunteer__c(
                                Id = existingLocationVolunteersByLocationIds.get(fosterLocation.Id)?.Id,
                                aos_Volunteer__c = fosterLocation.animalos__Contact__c,
                                aos_Location__c = fosterLocation.Id
                        ));
                    }

                    //delete Location Volunteer if Contact value is updated to null.
                    if (String.isBlank(fosterLocation.animalos__Contact__c) &&
                            String.isNotBlank(existingLocations.get(fosterLocation.Id).animalos__Contact__c) &&
                            existingLocationVolunteersByLocationIds.get(fosterLocation.Id) != null) {
                        locationVolunteersToDelete.add(new aos_Location_Volunteer__c(
                                Id = existingLocationVolunteersByLocationIds.get(fosterLocation.Id).Id
                        ));
                    }
                }
            }

            //upsert new/updated Location Volunteer records.
            if (!locationVolunteersToUpsert.isEmpty()) {
                upsert locationVolunteersToUpsert;
            }

            //delete for null values.
            if (!locationVolunteersToDelete.isEmpty()) {
                delete locationVolunteersToDelete;
            }
        }
    }
}