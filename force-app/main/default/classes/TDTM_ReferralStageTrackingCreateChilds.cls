global class TDTM_ReferralStageTrackingCreateChilds extends animalos.TDTM.Handler implements animalos.TDTM.AfterUpdate, animalos.TDTM.AfterInsert, animalos.TDTM.BeforeDelete {

    public void onAfterInsert(List<SObject> records) {
        this.createChildRecords(records);
    }

    public void onAfterUpdate(List<SObject> records, Map<Id, SObject> oldMap) {
        this.updateChildRecords((List<Referral_Stage_Tracking__c>) records, (Map<Id, Referral_Stage_Tracking__c>) oldMap);
    }

    public void onBeforeDelete(List<SObject> records) {
        this.deleteChildRecords((List<Referral_Stage_Tracking__c>) records);

    }

    private void createChildRecords(List<Referral_Stage_Tracking__c> referralStageTrackingRecords) {
        Set<Id> referralIds = vertic_Utils.sObjects.getIdFieldValues(referralStageTrackingRecords, Referral_Stage_Tracking__c.Referral__c);
        List<Referral_Stage_Tracking__c> childReferralStageTrackingToInsert = new List<Referral_Stage_Tracking__c>();

        Map<String, List<SObject>> animalReferralsByReferralIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, animalos__Referral__c
                FROM animalos__Animal_Referral__c
                WHERE animalos__Referral__c IN :referralIds
        ], animalos__Animal_Referral__c.animalos__Referral__c);

        for (Referral_Stage_Tracking__c referralStageTracking : referralStageTrackingRecords) {
            List<animalos__Animal_Referral__c> relatedAnimalReferrals = animalReferralsByReferralIds.get(referralStageTracking.Referral__c);

            if (String.isBlank(referralStageTracking.Parent_Referral_Stage_Tracking__c) && relatedAnimalReferrals != null && !relatedAnimalReferrals.isEmpty()) {
                for (animalos__Animal_Referral__c animalReferral : relatedAnimalReferrals) {
                    Referral_Stage_Tracking__c childRecord = referralStageTracking.clone(false, true, false, false);
                    childRecord.Parent_Referral_Stage_Tracking__c = referralStageTracking.Id;
                    childRecord.Animal_Referral__c = animalReferral.Id;
                    childReferralStageTrackingToInsert.add(childRecord);
                }
            }
        }

        if (!childReferralStageTrackingToInsert.isEmpty()) {
            insert childReferralStageTrackingToInsert;
        }
    }

    private void updateChildRecords(List<Referral_Stage_Tracking__c> records, Map<Id, Referral_Stage_Tracking__c> oldMap) {
        List<Referral_Stage_Tracking__c> parentsToBeChecked = new List<Referral_Stage_Tracking__c>();
        for (Referral_Stage_Tracking__c record : records) {
            if (Trigger.isUpdate &&
                    oldMap != null &&
                    oldMap.containsKey(record.Id) &&
                    record.Parent_Referral_Stage_Tracking__c == null) {
                parentsToBeChecked.add(record);
            }
        }

        if (!parentsToBeChecked.isEmpty()) {
            Set<Id> referralIds = vertic_Utils.sObjects.getIdFieldValues(parentsToBeChecked, Referral_Stage_Tracking__c.Referral__c);
            List<Referral_Stage_Tracking__c> childsToBeUpserted = new List<Referral_Stage_Tracking__c>();
            Map<String, List<SObject>> childsByParentIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                    SELECT Id, Parent_Referral_Stage_Tracking__c
                    FROM Referral_Stage_Tracking__c
                    WHERE Parent_Referral_Stage_Tracking__c IN :parentsToBeChecked
            ], Referral_Stage_Tracking__c.Parent_Referral_Stage_Tracking__c);

            Map<String, List<SObject>> animalReferralsByReferralIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                    SELECT Id, animalos__Referral__c
                    FROM animalos__Animal_Referral__c
                    WHERE animalos__Referral__c IN :referralIds
            ], animalos__Animal_Referral__c.animalos__Referral__c);

            for (Referral_Stage_Tracking__c record : records) {
                List<Referral_Stage_Tracking__c> childRecords = childsByParentIds.get(record.Id);
                List<animalos__Animal_Referral__c> relatedAnimalReferrals = animalReferralsByReferralIds.get(record.Referral__c);
                if (childRecords != null && !childRecords.isEmpty()) {
                    for (Referral_Stage_Tracking__c childRecord : childRecords) {
                        childRecord.Stage__c = record.Stage__c;
                        childRecord.Start_Date_Time__c = record.Start_Date_Time__c;
                        childRecord.End_Date_Time__c = record.End_Date_Time__c;
                    }

                    childsToBeUpserted.addAll(childRecords);
                } else if (relatedAnimalReferrals != null && !relatedAnimalReferrals.isEmpty()) {
                    for (animalos__Animal_Referral__c animalReferral : relatedAnimalReferrals) {
                        Referral_Stage_Tracking__c childRecord = record.clone(false, true, false, false);
                        childRecord.Parent_Referral_Stage_Tracking__c = record.Id;
                        childRecord.Animal_Referral__c = animalReferral.Id;
                        childsToBeUpserted.add(childRecord);
                    }

                }
            }

            if (!childsToBeUpserted.isEmpty()) {
                upsert childsToBeUpserted;
            }
        }
    }

    private void deleteChildRecords(List<Referral_Stage_Tracking__c> records) {
        delete [
                SELECT Id
                FROM Referral_Stage_Tracking__c
                WHERE Parent_Referral_Stage_Tracking__c IN :records
        ];
    }
}