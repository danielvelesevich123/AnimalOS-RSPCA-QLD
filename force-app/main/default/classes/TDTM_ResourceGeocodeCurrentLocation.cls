global class TDTM_ResourceGeocodeCurrentLocation extends animalos.TDTM.Handler implements animalos.TDTM.AfterUpdate, animalos.TDTM.AfterInsert {
    public void onAfterUpdate(List<SObject> record, Map<Id, SObject> existingRecords) {
        this.geocodeCurrentLocation(record, existingRecords);
    }

    public void onAfterInsert(List<SObject> record) {
        this.geocodeCurrentLocation(record, new Map<Id, SObject>());
    }

    private void geocodeCurrentLocation(List<SObject> records, Map<Id, SObject> existingRecords) {
        List<animalos__Log__c> logs = new List<animalos__Log__c>();

        for (animalos__Resource__c resourceVar : (List<animalos__Resource__c>) records) {
            Boolean isCreatedWithPopulatedAddress = Trigger.isInsert && String.isNotBlank(resourceVar.aos_Current_Location__Street__s);
            Boolean isAddressUpdated = Trigger.isUpdate && existingRecords != null && existingRecords.containsKey(resourceVar.Id) && vertic_Utils.sObjects.isSomeFieldChanged(
                    resourceVar, existingRecords.get(resourceVar.Id), new List<SObjectField>{
                            animalos__Resource__c.aos_Current_Location__City__s,
                            animalos__Resource__c.aos_Current_Location__CountryCode__s,
                            animalos__Resource__c.aos_Current_Location__PostalCode__s,
                            animalos__Resource__c.aos_Current_Location__StateCode__s,
                            animalos__Resource__c.aos_Current_Location__Street__s
                    });

            if ((isCreatedWithPopulatedAddress || isAddressUpdated)) {
                //Area, Location and Coordinates will be updated by PopulateJobScheduledBatch
                logs.add(new animalos.Logging()
                        .setProcess(ResourceGeocodeProc.class.getName())
                        .addPayload('recordId', resourceVar.Id)
                        .setGroup('Resource Geocoding - ' + resourceVar.Id)
                        .setType('Scheduled')
                        .build());
            }
        }

        insert logs;
        //runtime sync to EzyVet
        System.enqueueJob(new ResourceGeocodeProc(vertic_Utils.sObjects.getIdFieldValues(logs, animalos__Log__c.Id)));
    }
}