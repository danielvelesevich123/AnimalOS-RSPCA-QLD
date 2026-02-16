({
    handleInit: function (cmp, event, helper) {
        cmp.set('v.isBusy', true);
        let referralJSON = cmp.get('v.referralJSON'),
            referral = JSON.parse(referralJSON),
            animalJSON = cmp.get('v.animalJSON'),
            animal = JSON.parse(animalJSON);

        cmp.utils
            .executePromise(
                cmp,
                'aos_WildlifeAnimalIntakeMetaProc',
                {
                    referral: referral,
                    animal: animal
                }
            )
            .then(response => {
                cmp.set('v.meta', response);
            })
            .finally(() => {
                cmp.set('v.isBusy', false);
            });
    },

    handleNavigation: function (cmp, event, helper) {
        let actionClicked = event.getSource().getLocalId(),
            isInboundRecordType = cmp.get('v.meta.dto.isInboundRecordType'),
            steps = cmp.get('v.steps'),
            currentStep = cmp.get('v.currentStep'),
            animals = cmp.get('v.meta.dto.animals') || [];

        cmp.set('v.isBusy', true);

        animals.forEach(animal => {
            delete animal.errorMessage;
        });


        helper.handleNavigationValidation(cmp, helper, actionClicked)
            .then($A.getCallback(response => {
                if (actionClicked === 'BACK') {
                    if (steps.indexOf(currentStep) === 0) {
                        cmp.get('v.navigateFlow')(actionClicked);
                    } else {
                        let resultStep = steps.indexOf(currentStep) - 1;
                        cmp.set('v.currentStep', steps[resultStep]);
                    }
                    cmp.set('v.isBusy', false);
                } else if (actionClicked === 'NEXT') {
                    let resultStep = steps.indexOf(currentStep) + 1;
                    currentStep = steps[resultStep];
                    helper.handleNavigationProcessing(cmp, actionClicked, currentStep);

                    if (currentStep === 'movements' && cmp.get('v.meta.dto.movements').filter(movement => movement.animalos__Animal__r && movement.animalos__Animal__r.animalos__Stage__c !== 'Pre-Intake').length === 0) {
                        helper.executeSubmitProc(cmp)
                            .then(response => {
                                cmp.find('notifyLib').showToast({
                                    variant: 'success',
                                    message: 'Referral successfully created'
                                });

                                let urlEvent = $A.get("e.force:navigateToURL");
                                urlEvent.setParams({
                                    "url": '/' + response.dto.referralId
                                });
                                urlEvent.fire();
                            })
                            .finally(() => {
                                cmp.set('v.isBusy', false);
                            });
                    } else {
                        cmp.set('v.currentStep', steps[resultStep]);
                        cmp.set('v.isBusy', false);
                    }
                } else if (actionClicked === 'FINISH') {
                    if (currentStep === 'movements') {

                        if (cmp.utils.validate(cmp.find('movements').find('movementItems')).allValid !== true) {
                            cmp.set('v.isBusy', false);
                            return;
                        }

                        let movements = cmp.get('v.meta.dto.movements');
                        movements.forEach(movement => {
                            if (!movement.animalos__Location__c && movement.block) {
                                movement.animalos__Location__c = movement.block;
                            }
                        });
                        cmp.set('v.meta.dto.movements', movements);
                    }

                    helper.executeSubmitProc(cmp)
                        .then(response => {
                            cmp.find('notifyLib').showToast({
                                variant: 'success',
                                message: 'Referral successfully created'
                            });

                            let urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": '/' + response.dto.referralId
                            });
                            urlEvent.fire();
                        })
                        .finally(() => {
                            cmp.set('v.isBusy', false);
                        });
                }
            }))
            .catch(errors => {
                if (errors) {
                    cmp.find('notifyLib').showToast({
                        variant: 'error',
                        message: errors[0]
                    });
                }
                cmp.set('v.isBusy', false);
            });
    }
});