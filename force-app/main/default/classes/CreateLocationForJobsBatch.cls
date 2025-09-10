global class CreateLocationForJobsBatch extends vertic_AbstractProcessor implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
                'SELECT Id, animalos__Address__CountryCode__s, animalos__Address__StateCode__s, animalos__Address__City__s,' +
                        'animalos__Address__Street__s, animalos__Address__PostalCode__s, animalos__Full_Address__c, animalos__Address__Latitude__s, animalos__Address__Longitude__s ' +
                        'FROM animalos__Job__c ' +
                        'WHERE animalos__Location_Of_Interest__c = NULL LIMIT 25000');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        this.run(scope);
    }

    global void finish(Database.BatchableContext BC) {
    }

    private void run(List<SObject> scope) {
        for (animalos__Job__c job : (List<animalos__Job__c>) scope) {
            Map<String, Object> fullAddressDetails = animalos.PolygonUtils.getFullAddressDetailsByAddress(job.animalos__Full_Address__c);
            vertic_DTO fullAddressDetailsDTO = new vertic_DTO(fullAddressDetails);

            if (fullAddressDetailsDTO.getBoolean('success') == true) {
                job.animalos__Address__Latitude__s = fullAddressDetailsDTO.getDecimal('data.position.lat');
                job.animalos__Address__Longitude__s = fullAddressDetailsDTO.getDecimal('data.position.lng');
            }

            if (job.animalos__Address__Latitude__s != null && job.animalos__Address__Longitude__s != null) {
                job.animalos__Area__c = animalos.PolygonUtils.getAreaIdByPolygons(job.animalos__Address__Longitude__s, job.animalos__Address__Latitude__s);
            }
        }

        Set<Id> locationIds = new Set<Id>();
        List<animalos__Location_Of_Interest__c> locations = new List<animalos__Location_Of_Interest__c>();

        for (animalos__Job__c job : (List<animalos__Job__c>) scope) {
            animalos__Location_Of_Interest__c locationVar = (animalos__Location_Of_Interest__c) vertic_Utils.arrays.firstOrNull([
                    SELECT Id
                    FROM animalos__Location_Of_Interest__c
                    WHERE (
                            animalos__Address__Street__s = :job.animalos__Address__Street__s
                            AND animalos__Address__PostalCode__s = :job.animalos__Address__PostalCode__s
                            AND animalos__Address__City__s = :job.animalos__Address__City__s
                            AND animalos__Address__StateCode__s = :job.animalos__Address__StateCode__s
                    ) OR (
                            animalos__Address__Latitude__s != NULL
                            AND animalos__Address__Longitude__s != NULL
                            AND animalos__Address__Street__s != NULL
                            AND animalos__Address__Latitude__s = :job.animalos__Address__Latitude__s
                            AND animalos__Address__Longitude__s = :job.animalos__Address__Longitude__s
                            AND animalos__Address__Street__s = :job.animalos__Address__Street__s
                    )
            ]);

            if (locationVar == null) {
                locationVar = new animalos__Location_Of_Interest__c(
                        animalos__Address__CountryCode__s = job.animalos__Address__CountryCode__s,
                        animalos__Address__Street__s = job.animalos__Address__Street__s,
                        animalos__Address__PostalCode__s = job.animalos__Address__PostalCode__s,
                        animalos__Address__City__s = job.animalos__Address__City__s,
                        animalos__Address__StateCode__s = job.animalos__Address__StateCode__s,
                        animalos__Address__Latitude__s = job.animalos__Address__Latitude__s,
                        animalos__Address__Longitude__s = job.animalos__Address__Longitude__s,
                        Name = job.animalos__Full_Address__c?.left(80)
                );
                insert locationVar;
            }

            locationIds.add(locationVar.Id);
            job.animalos__Location_Of_Interest__c = locationVar.Id;
        }

        animalos.TDTM.getTriggerSObjectTypeEvent(animalos__Job__c.SObjectType).disableAll();
        update scope;
    }

    public override vertic_Response process(vertic_Request request) {
        this.request = request;
        String recordId = this.request.getRequiredString('recordId');
        animalos__Job__c job = (animalos__Job__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, animalos__Address__CountryCode__s, animalos__Address__StateCode__s, animalos__Address__City__s,
                        animalos__Address__Street__s, animalos__Address__PostalCode__s
                FROM animalos__Job__c
                WHERE Id = :recordId
        ]);
        this.run(new List<animalos__Job__c>{
                job
        });
        return null;
    }
}