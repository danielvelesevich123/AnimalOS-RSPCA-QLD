({
    handleInit: function (cmp, event, helper) {
        cmp.set('v.isBusy', true);
        cmp.utils
            .execute(
                cmp,
                'aos_BehaviourEvaluationSmallAnimalsMetaProc',
                {
                    recordId: cmp.get('v.recordId')
                }
            )
            .then(response => {
                cmp.set('v.meta', response)
            })
            .finally(() => {
                cmp.set('v.isBusy', false);
            });
    },

    handleBehavioursExhibitedChanged: function (cmp, event, helper) {
        cmp.set('v.meta.dto.assessment.aos_Behaviours_Exhibited_SAE__c', cmp.get('v.behavioursExhibitedValue').join(';'));
    },

    handleHouseHoldRecommendationsChanged: function (cmp, event, helper) {
        cmp.set('v.meta.dto.assessment.aos_Household_Recommendations_SAE__c', cmp.get('v.householdRecommendationsValue').join(';'));
    },

    handleSubmit: function (cmp, event, helper) {
        cmp.set('v.isBusy', true);

        cmp.utils
            .execute(
                cmp,
                'aos_DMLProc',
                {
                    sObjectType: 'animalos__Assessment__c',
                    upsert: [cmp.get('v.meta.dto.assessment')]
                }
            )
            .then(response => {
                let recordId = response.dto.upsert[0].Id;

                cmp.find('notifyLib').showToast({
                    variant: 'success',
                    message: '{0} successfully created',
                    messageData: [{
                        label: 'Behaviour Evaluation',
                        url: '/' + recordId
                    }]
                });

                $A.get("e.force:closeQuickAction").fire();
            })
            .finally(() => {
                cmp.set('v.isBusy', false);
            });

    }
});