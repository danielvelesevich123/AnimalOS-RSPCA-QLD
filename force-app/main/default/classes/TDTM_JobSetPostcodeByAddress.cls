global class TDTM_JobSetPostcodeByAddress extends animalos.TDTM.Handler implements animalos.TDTM.BeforeInsert, animalos.TDTM.BeforeUpdate {
    public void onBeforeInsert(List<SObject> records) {
        this.setPostcodeByAddress(records, null);
    }

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> existingRecords) {
        this.setPostcodeByAddress(records, existingRecords);
    }

    private void setPostcodeByAddress(List<SObject> records, Map<Id, SObject> existingRecords) {

        Set<String> postcodesSet = vertic_Utils.sObjects.getStringFieldValues(records, animalos__Job__c.animalos__Address__PostalCode__s);
        Set<String> cities = vertic_Utils.sObjects.getStringFieldValues(records, animalos__Job__c.animalos__Address__City__s);

        List<Postcode__c> postcodes = [
                SELECT Id, Postcode__c, Suburb__c
                FROM Postcode__c
                WHERE Postcode__c IN :postcodesSet AND Suburb__c IN :cities
                AND Postcode__c != NULL AND Suburb__c != NULL
        ];

        Map<String, Postcode__c> postcodesBySuburbAndPostcode = new Map<String, Postcode__c>();

        for (Postcode__c postcode : postcodes) {
            postcodesBySuburbAndPostcode.put(postcode.Suburb__c.toLowerCase() + ' ' + postcode.Postcode__c.toLowerCase(), postcode);
        }

        for (animalos__Job__c job : (List<animalos__Job__c>) records) {

            Boolean isCreated = Trigger.isInsert && existingRecords == null;
            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingRecords.get(job.Id) != null
                    && vertic_Utils.sObjects.isSomeFieldChanged(
                    job,
                    existingRecords.get(job.Id),
                    new List<SObjectField>{
                            animalos__Job__c.animalos__Address__City__s,
                            animalos__Job__c.animalos__Address__PostalCode__s
                    }
            );

            if ((isCreated || isUpdated) && String.isNotBlank(job.animalos__Address__City__s) && String.isNotBlank(job.animalos__Address__PostalCode__s)) {
                Postcode__c postcode = (Postcode__c) postcodesBySuburbAndPostcode.get(job.animalos__Address__City__s.toLowerCase() + ' ' + job.animalos__Address__PostalCode__s.toLowerCase());

                if (postcode == null) {
                    continue;
                }

                job.Postcode__c = postcode.Id;
            }
        }
    }
}