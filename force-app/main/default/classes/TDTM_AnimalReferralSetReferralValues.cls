global class TDTM_AnimalReferralSetReferralValues extends animalos.TDTM.Handler implements animalos.TDTM.BeforeInsert {
    public void onBeforeInsert(List<SObject> records) {
        this.setReferralValues(records);
    }

    private void setReferralValues(List<SObject> records) {
        Set<Id> referralIds = vertic_Utils.sObjects.getIdFieldValues(records, animalos__Animal_Referral__c.animalos__Referral__c);
        Map<Id, animalos__Referral__c> referralsByIds = new Map<Id, animalos__Referral__c>([
                SELECT Id, animalos__Job__c
                FROM animalos__Referral__c
                WHERE Id IN :referralIds
        ]);

        for (animalos__Animal_Referral__c animalReferral : (List<animalos__Animal_Referral__c>) records) {
            animalos__Referral__c referral = referralsByIds.get(animalReferral.animalos__Referral__c);
            if (referral != null) {
                animalReferral.animalos__Job__c = referral.animalos__Job__c;
            }
        }
    }
}