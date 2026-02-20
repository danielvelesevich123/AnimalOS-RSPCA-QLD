global class aos_CalcRollupsAnimalReferralStatusTrack extends animalos.vertic_SequentialScheduledBatch {

    public override Database.QueryLocator getLocator() {
        List<String> conditions = new List<String>();

        if (String.isNotBlank(this.sequentialBatchSetting.animalos__Conditions__c)) {
            conditions.add('(' + sequentialBatchSetting.animalos__Conditions__c + ')');
        }

        return Database.getQueryLocator(
                new aos_QueryFactory(((SObject) Type.forName(this.sequentialBatchSetting.animalos__SObject_Type__c).newInstance()).getSObjectType())
                        .selectFields(
                                animalos__Animal_Referral__c.SObjectType.getDescribe().fields.getMap().keySet()
                        )
                        .setCondition(String.join(conditions, ' AND ')).toSOQL()
        );
    }

    global override void process(List<SObject> records) {
        try {
            Set<Id> animalIds = aos_Utils.sObjects.getIdFieldValues(records, 'animalos__Animal__c');
            Set<Id> referralIds = aos_Utils.sObjects.getIdFieldValues(records, 'animalos__Referral__c');
            List<animalos__Animal_Referral__c> animalReferralsToUpdate = new List<animalos__Animal_Referral__c>();

            List<animalos__Status_Tracking__c> statusTrackingRecords = [
                    SELECT Id, animalos__Days_in_Status__c, animalos__Referral__c, animalos__Animal__c
                    FROM animalos__Status_Tracking__c
                    WHERE animalos__Animal__c IN :animalIds AND animalos__Referral__c IN :referralIds
                    AND animalos__Animal__c != NULL AND animalos__Referral__c != NULL
                    AND animalos__Stage__c != 'Out'
                    AND RecordType.DeveloperName = 'Generic'
            ];

            Map<String, List<animalos__Status_Tracking__c>> statusTrackingRecordsByAnimalReferralIds = new Map<String, List<animalos__Status_Tracking__c>>();

            for (animalos__Status_Tracking__c statusTrackingRecord : statusTrackingRecords) {
                if (!statusTrackingRecordsByAnimalReferralIds.containsKey('' + statusTrackingRecord.animalos__Referral__c + statusTrackingRecord.animalos__Animal__c)) {
                    statusTrackingRecordsByAnimalReferralIds.put('' + statusTrackingRecord.animalos__Referral__c + statusTrackingRecord.animalos__Animal__c, new List<animalos__Status_Tracking__c>());
                }
                statusTrackingRecordsByAnimalReferralIds.get('' + statusTrackingRecord.animalos__Referral__c + statusTrackingRecord.animalos__Animal__c).add(statusTrackingRecord);
            }

            for (animalos__Animal_Referral__c animalReferral : (List<animalos__Animal_Referral__c>) records) {
                List<animalos__Status_Tracking__c> relatedStatusTrackingRecords = statusTrackingRecordsByAnimalReferralIds.get('' + animalReferral.animalos__Referral__c + animalReferral
                        .animalos__Animal__c);

                if (relatedStatusTrackingRecords == null || relatedStatusTrackingRecords.isEmpty()) {
                    continue;
                }

                Decimal daysInStatus = 0;
                for (animalos__Status_Tracking__c statusTrackingRecord : relatedStatusTrackingRecords) {
                    daysInStatus += aos_Utils.objects.defaultIfNull(statusTrackingRecord.animalos__Days_in_Status__c, 0);
                }

                animalReferral.aos_Days_in_Care__c = daysInStatus;
                animalReferralsToUpdate.add(animalReferral);
            }

            if(!animalReferralsToUpdate.isEmpty()) {
                update animalReferralsToUpdate;
            }
        } catch(Exception ex) {
            insert new animalos__Log__c(
                    animalos__Type__c = 'Error',
                    animalos__Log_Details__c = ex.getMessage() + '\n' + ex.getStackTraceString(),
                    animalos__Process__c = 'CalcRollupsAnimalReferralStatusTracking'
            );
        }
    }
}