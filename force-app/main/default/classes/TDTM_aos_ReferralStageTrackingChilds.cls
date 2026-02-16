global class TDTM_aos_ReferralStageTrackingChilds extends animalos.TDTM.Handler implements animalos.TDTM.AfterUpdate, animalos.TDTM.AfterInsert, animalos.TDTM.BeforeDelete {

    public void onAfterInsert(List<SObject> records) {
        this.createChildRecords(records);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.updateChildRecords((List<aos_Referral_Stage_Tracking__c>) records, (Map<Id, aos_Referral_Stage_Tracking__c>) oldMap);
    }

    public void onBeforeDelete(List<SObject> records) {
        this.deleteChildRecords((List<aos_Referral_Stage_Tracking__c>) records);

    }

    private void createChildRecords(List<aos_Referral_Stage_Tracking__c> referralStageTrackingRecords) {
        Set<Id> referralIds = vertic_Utils.sObjects.getIdFieldValues(referralStageTrackingRecords, aos_Referral_Stage_Tracking__c.aos_Referral__c);
        List<aos_Referral_Stage_Tracking__c> childReferralStageTrackingToInsert = new List<aos_Referral_Stage_Tracking__c>();

        Map<String, List<SObject>> animalReferralsByReferralIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, animalos__Referral__c
                FROM animalos__Animal_Referral__c
                WHERE animalos__Referral__c IN :referralIds
        ], animalos__Animal_Referral__c.animalos__Referral__c);

        for (aos_Referral_Stage_Tracking__c referralStageTracking : referralStageTrackingRecords) {
            List<animalos__Animal_Referral__c> relatedAnimalReferrals = animalReferralsByReferralIds.get(referralStageTracking.aos_Referral__c);

            if (String.isBlank(referralStageTracking.aos_Parent_Referral_Stage_Tracking__c) && relatedAnimalReferrals != null && !relatedAnimalReferrals.isEmpty()) {
                for (animalos__Animal_Referral__c animalReferral : relatedAnimalReferrals) {
                    aos_Referral_Stage_Tracking__c childRecord = referralStageTracking.clone(false, true, false, false);
                    childRecord.aos_Parent_Referral_Stage_Tracking__c = referralStageTracking.Id;
                    childRecord.aos_Animal_Referral__c = animalReferral.Id;
                    childReferralStageTrackingToInsert.add(childRecord);
                }
            }
        }

        if (!childReferralStageTrackingToInsert.isEmpty()) {
            insert childReferralStageTrackingToInsert;
        }
    }

    private void updateChildRecords(List<aos_Referral_Stage_Tracking__c> records, Map<Id, aos_Referral_Stage_Tracking__c> oldMap) {
        List<aos_Referral_Stage_Tracking__c> parentsToBeChecked = new List<aos_Referral_Stage_Tracking__c>();
        for (aos_Referral_Stage_Tracking__c record : records) {
            if (Trigger.isUpdate &&
                    oldMap != null &&
                    oldMap.containsKey(record.Id) &&
                    record.aos_Parent_Referral_Stage_Tracking__c == null) {
                parentsToBeChecked.add(record);
            }
        }

        if (!parentsToBeChecked.isEmpty()) {
            Set<Id> referralIds = vertic_Utils.sObjects.getIdFieldValues(parentsToBeChecked, aos_Referral_Stage_Tracking__c.aos_Referral__c);
            List<aos_Referral_Stage_Tracking__c> childsToBeUpserted = new List<aos_Referral_Stage_Tracking__c>();
            Map<String, List<SObject>> childsByParentIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                    SELECT Id, aos_Parent_Referral_Stage_Tracking__c
                    FROM aos_Referral_Stage_Tracking__c
                    WHERE aos_Parent_Referral_Stage_Tracking__c IN :parentsToBeChecked
            ], aos_Referral_Stage_Tracking__c.aos_Parent_Referral_Stage_Tracking__c);

            Map<String, List<SObject>> animalReferralsByReferralIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                    SELECT Id, animalos__Referral__c
                    FROM animalos__Animal_Referral__c
                    WHERE animalos__Referral__c IN :referralIds
            ], animalos__Animal_Referral__c.animalos__Referral__c);

            for (aos_Referral_Stage_Tracking__c record : records) {
                List<aos_Referral_Stage_Tracking__c> childRecords = childsByParentIds.get(record.Id);
                List<animalos__Animal_Referral__c> relatedAnimalReferrals = animalReferralsByReferralIds.get(record.aos_Referral__c);
                if (childRecords != null && !childRecords.isEmpty()) {
                    for (aos_Referral_Stage_Tracking__c childRecord : childRecords) {
                        childRecord.aos_Stage__c = record.aos_Stage__c;
                        childRecord.aos_Start_Date_Time__c = record.aos_Start_Date_Time__c;
                        childRecord.aos_End_Date_Time__c = record.aos_End_Date_Time__c;
                    }

                    childsToBeUpserted.addAll(childRecords);
                } else if (relatedAnimalReferrals != null && !relatedAnimalReferrals.isEmpty()) {
                    for (animalos__Animal_Referral__c animalReferral : relatedAnimalReferrals) {
                        aos_Referral_Stage_Tracking__c childRecord = record.clone(false, true, false, false);
                        childRecord.aos_Parent_Referral_Stage_Tracking__c = record.Id;
                        childRecord.aos_Animal_Referral__c = animalReferral.Id;
                        childsToBeUpserted.add(childRecord);
                    }

                }
            }

            if (!childsToBeUpserted.isEmpty()) {
                upsert childsToBeUpserted;
            }
        }
    }

    private void deleteChildRecords(List<aos_Referral_Stage_Tracking__c> records) {
        delete [
                SELECT Id
                FROM aos_Referral_Stage_Tracking__c
                WHERE aos_Parent_Referral_Stage_Tracking__c IN :records
        ];
    }
}