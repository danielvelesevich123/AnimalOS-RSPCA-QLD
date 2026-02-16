public inherited sharing class aos_ResourceGeocodeProc extends aos_AbstractProcessor implements Queueable, Database.AllowsCallouts {

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        animalos__Resource__c resourceVar = (animalos__Resource__c) aos_Utils.arrays.firstOrException([
                SELECT Id, aos_Current_Location__Longitude__s, aos_Current_Location__Latitude__s, aos_Current_Location__Street__s,
                        aos_Current_Location__PostalCode__s, aos_Current_Location__City__s, aos_Current_Location__CountryCode__s,
                        aos_Current_Location__StateCode__s, aos_Full_Current_Location__c
                FROM animalos__Resource__c
                WHERE Id = :this.request.getRequiredString('recordId')
        ], 'There is no Resource with Id ' + this.request.getRequiredString('recordId'));

        if (String.isNotBlank(resourceVar.aos_Full_Current_Location__c)) {
            Map<String, Object> fullAddressDetails = animalos.PolygonUtils.getFullAddressDetailsByAddress(resourceVar.aos_Full_Current_Location__c);
            aos_DTO fullAddressDetailsDTO = new aos_DTO(fullAddressDetails);

            if (fullAddressDetailsDTO.getBoolean('success') == true) {
                resourceVar.aos_Current_Location__Latitude__s = fullAddressDetailsDTO.getDecimal('data.position.lat');
                resourceVar.aos_Current_Location__Longitude__s = fullAddressDetailsDTO.getDecimal('data.position.lng');
            }
        }

        update resourceVar;
    }

    //QUEUEABLE
    Set<Id> logIds = new Set<Id>();

    public void execute(QueueableContext param1) {
        if (logIds != null && !logIds.isEmpty()) {
            Id logId = new List<Id>(this.logIds).get(0);

            animalos__Log__c logVar = (animalos__Log__c) aos_Utils.arrays.firstOrException([
                    SELECT Id, animalos__Payload__c, animalos__Process__c
                    FROM animalos__Log__c
                    WHERE Id = :logId
            ]);

            try {
                new aos_ResourceGeocodeProc().process((Map<String, Object>) JSON.deserializeUntyped(logVar.animalos__Payload__c));
                update new animalos.Logging()
                        .setId(logVar.Id)
                        .addPayload((Map<String, Object>) JSON.deserializeUntyped(logVar.animalos__Payload__c))
                        .setType('Success')
                        .build();
            } catch (Exception ex) {
                update new animalos.Logging()
                        .setId(logVar.Id)
                        .addDetails(ex)
                        .addPayload((Map<String, Object>) JSON.deserializeUntyped(logVar.animalos__Payload__c))
                        .setType('Error')
                        .build();
            }

            this.logIds.remove(logId);
            if (!this.logIds.isEmpty()) {
                System.enqueueJob(new aos_ResourceGeocodeProc(this.logIds));
            }
        }
    }

    public aos_ResourceGeocodeProc(Set<Id> logIds) {
        this.logIds = logIds;
    }

    public aos_ResourceGeocodeProc() {
    }

}