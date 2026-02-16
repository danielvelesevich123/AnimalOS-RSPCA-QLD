global class TDTM_aos_JobSetPostcodeByAddress extends animalos.TDTM.Handler implements animalos.TDTM.BeforeInsert, animalos.TDTM.BeforeUpdate {
    public void onBeforeInsert(List<SObject> records) {
        this.setPostcodeByAddress(records, null);
    }

    public void onBeforeUpdate(List<SObject> records, Map<Id, SObject> existingRecords) {
        this.setPostcodeByAddress(records, existingRecords);
    }

    private void setPostcodeByAddress(List<SObject> records, Map<Id, SObject> existingRecords) {

        Set<String> postcodesSet = aos_Utils.sObjects.getStringFieldValues(records, animalos__Job__c.animalos__Address__PostalCode__s);
        Set<String> cities = aos_Utils.sObjects.getStringFieldValues(records, animalos__Job__c.animalos__Address__City__s);

        List<aos_Postcode__c> postcodes = [
                SELECT Id, aos_Postcode__c, aos_Suburb__c
                FROM aos_Postcode__c
                WHERE aos_Postcode__c IN :postcodesSet AND aos_Suburb__c IN :cities
                AND aos_Postcode__c != NULL AND aos_Suburb__c != NULL
        ];

        Map<String, aos_Postcode__c> postcodesBySuburbAndPostcode = new Map<String, aos_Postcode__c>();

        for (aos_Postcode__c postcode : postcodes) {
            postcodesBySuburbAndPostcode.put(postcode.aos_Suburb__c.toLowerCase() + ' ' + postcode.aos_Postcode__c.toLowerCase(), postcode);
        }

        for (animalos__Job__c job : (List<animalos__Job__c>) records) {

            Boolean isCreated = Trigger.isInsert && existingRecords == null;
            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingRecords.get(job.Id) != null
                    && aos_Utils.sObjects.isSomeFieldChanged(
                    job,
                    existingRecords.get(job.Id),
                    new List<SObjectField>{
                            animalos__Job__c.animalos__Address__City__s,
                            animalos__Job__c.animalos__Address__PostalCode__s
                    }
            );

            if ((isCreated || isUpdated) && String.isNotBlank(job.animalos__Address__City__s) && String.isNotBlank(job.animalos__Address__PostalCode__s)) {
                aos_Postcode__c postcode = (aos_Postcode__c) postcodesBySuburbAndPostcode.get(job.animalos__Address__City__s.toLowerCase() + ' ' + job.animalos__Address__PostalCode__s.toLowerCase());

                if (postcode == null) {
                    continue;
                }

                job.aos_Postcode__c = postcode.Id;
            }
        }
    }
}