global class CalcRollupsAnimalReferral extends animalos.vertic_SequentialScheduledBatch {

    global override Database.QueryLocator getLocator() {
        List<String> conditions = new List<String>();

        if (String.isNotBlank(this.sequentialBatchSetting.animalos__Conditions__c)) {
            conditions.add('(' + sequentialBatchSetting.animalos__Conditions__c + ')');
        }

        Datetime lastCalculationDateTime = this.sequentialBatchSetting.animalos__Last_Calculation_Datetime__c;
        if (lastCalculationDateTime != null) {
            conditions.add('Id IN (SELECT animalos__Animal__c FROM animalos__Animal_Referral__c WHERE LastModifiedDate > :lastCalculationDateTime)');
        }

        return Database.getQueryLocator(
                new fflib_QueryFactory(((SObject) Type.forName(this.sequentialBatchSetting.animalos__SObject_Type__c).newInstance()).getSObjectType())
                        .selectFields(new Set <String>{
                                'Id'
                        })
                        .setCondition(String.join(conditions, ' AND '))
                        .toSOQL()
        );
    }

    global override void process(List<SObject> records) {
        Map<String, Object> animalReferralsByAnimalId = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, animalos__Animal__c, animalos__Referral__r.RecordType.DeveloperName, animalos__Referral__r.animalos__Stage__c
                FROM animalos__Animal_Referral__c
                WHERE animalos__Animal__c IN :records AND animalos__Referral__r.RecordType.DeveloperName IN (
                        'Animal_Intake_Bequests_incoming_offspring_and_Transfer_In', 'Inbound_Animal',
                        'Information_Pre_surrender_Pet_Reunite', 'Inspectorate_Animal', 'Stray',
                        'Return_Animals_returned_less_that_14_days_post_adoption', 'Surrender',
                        'Adoption', 'Outbound_Animal'
                )
        ], animalos__Animal_Referral__c.animalos__Animal__c);

        for (animalos__Animal__c animal : (List<animalos__Animal__c>) records) {
            List<animalos__Animal_Referral__c> animalReferrals = (List<animalos__Animal_Referral__c>) animalReferralsByAnimalId.get(animal.Id);

            if (animalReferrals == null || animalReferrals.isEmpty()) {
                continue;
            }

            Integer numberOfIncomingReferrals = 0;
            Integer numberOfOutboundReferrals = 0;

            for (animalos__Animal_Referral__c animalReferral : animalReferrals) {
                if ('Completed'.equals(animalReferral.animalos__Referral__r.animalos__Stage__c) || 'Adopted'.equals(animalReferral.animalos__Referral__r.animalos__Stage__c)) {

                    if ('Adoption'.equals(animalReferral.animalos__Referral__r.RecordType.DeveloperName) || 'Outbound_Animal'.equals(animalReferral.animalos__Referral__r.RecordType.DeveloperName)) {
                        numberOfOutboundReferrals++;
                    } else {
                        numberOfIncomingReferrals++;
                    }
                }
            }

            animal.Number_of_Incoming_Referrals__c = numberOfIncomingReferrals;
            animal.Number_of_Outbound_Referrals__c = numberOfOutboundReferrals;
        }

        fflib_SObjectDomain.getTriggerEvent(animalos_AnimalDomain.class).disableAll();
        animalos.TDTM.getTriggerSObjectTypeEvent(animalos__Animal__c.SObjectType).disableAll();
        update records;
    }
}