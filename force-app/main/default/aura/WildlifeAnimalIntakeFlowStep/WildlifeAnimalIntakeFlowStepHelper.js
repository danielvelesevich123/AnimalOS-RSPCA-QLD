({
    handleNavigationValidation: function (cmp, helper, action) {
        let currentStep = cmp.get('v.currentStep');

        if ((action === 'NEXT' || action === 'FINISH') && currentStep === 'animals') {
            let animals = cmp.get('v.meta.dto.animals') || [];

            if (animals.length === 0) {
                return Promise.reject(['Add at least one Animal']);
            }

            if (cmp.utils.validate(cmp.find('animals').find('animalsTable')).allValid !== true) {
                return Promise.reject();
            }

            return helper.submitAnimals(cmp, animals)

        } else {
            return Promise.resolve();
        }
    },

    handleNavigationProcessing: function (cmp, action, step) {

        if (action === 'NEXT' && step === 'movements') {
            let movements = [],
                animals = cmp.get('v.meta.dto.animals') || [],
                entrySite = cmp.get('v.meta.dto.referral.animalos__Entry_Site__c'),
                defaultBlock = cmp.get('v.meta.dto.defaultBlock');

            if (animals.length === 0) {
                return;
            }

            animals.forEach((animal, indexVar) => {
                let movement = {
                        animalos__Animal__r: animal,
                        animalos__Current__c: true
                    },
                    titleParts = [indexVar + 1];

                if (animal.animalos__Microchip_Number__c) {
                    titleParts.push(animal.animalos__Microchip_Number__c);
                }

                if (animal.animalos__Primary_Breed__c && animal.animalos__Primary_Breed__r.Name) {
                    titleParts.push(animal.animalos__Primary_Breed__r.Name);
                }

                if (animal.animalos__Stage__c) {
                    titleParts.push(animal.animalos__Stage__c);
                }

                if (animal.animalos__Status__c) {
                    titleParts.push(animal.animalos__Status__c);
                }

                if (entrySite) {
                    movement.site = entrySite;
                }

                if (defaultBlock) {
                    movement.block = defaultBlock;
                }

                movement.title = titleParts.join(' - ');

                movements.push(movement);
            });

            cmp.set('v.meta.dto.movements', movements);
        }
    },

    submitAnimals: function (cmp, animals) {
        let promises = [],
            referral = cmp.get('v.meta.dto.referral');

        animals.forEach((animal, indexVar) => {
            promises.push(
                cmp.utils
                    .executePromise(
                        cmp,
                        'WildlifeAnimalIntakeAnimalsSubmitProc',
                        {
                            animal: animal,
                            referral: referral
                        },
                        false
                    )
                    .then(response => {
                        if (response.dto.errorMessage) {
                            animals[indexVar].errorMessage = response.dto.errorMessage
                            cmp.set('v.meta.dto.animals', animals);
                        }
                        return Promise.resolve(response);
                    })
                    .catch(errors => {
                        return Promise.reject(errors);
                    })
            );
        });

        return Promise.all(promises)
            .then(responses => {
                let failedResponse = responses.filter(response => response.dto.errorMessage !== undefined && response.dto.errorMessage !== null) || [];

                if (failedResponse.length !== 0) {
                    return Promise.reject(['Please review failed rows']);
                }

                return Promise.resolve();
            })
    },

    executeSubmitProc: function (cmp) {
        return cmp.utils
            .executePromise(
                cmp,
                'WildlifeAnimalIntakeSubmitProc',
                cmp.get('v.meta.dto')
            );
    }
});