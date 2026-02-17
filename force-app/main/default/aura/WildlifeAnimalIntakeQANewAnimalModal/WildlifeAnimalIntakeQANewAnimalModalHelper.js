({
    submit: function (cmp, event, helper, openNewModal) {
        if (cmp.utils.validate(cmp.find('animalForm')).allValid !== true) {
            return;
        }

        //deduplicate if no Id, otherwise close modal
        if (!cmp.get('v.animal.Id')) {
            let existingAnimal;

            cmp.set('v.isBusy', true);
            cmp.utils
                .executePromise(
                    cmp,
                    'aos_SOQLProc',
                    {
                        'SOQL': 'SELECT Id FROM animalos__Animal__c WHERE animalos__Microchip_Number__c = \'' + cmp.get('v.animal.animalos__Microchip_Number__c') + '\' WITH USER_MODE'
                    }
                )
                .then(response => {
                    existingAnimal = (response.dto.records || [])[0];

                    if (existingAnimal && existingAnimal.Id) {
                        return cmp.find('modalService').show(
                            'c:aos_ConfirmModal',
                            {
                                text: 'Animal with ' + cmp.get('v.animal.animalos__Microchip_Number__c') + ' Microchip Number already exists. Do you want to use and review this Animal?'
                            },
                            {
                                header: 'Existing Animal',
                                cssClass: 'slds-modal_small'
                            }
                        )
                    }

                    return Promise.resolve(response);
                })
                .then(response => {
                    //use existing animal confirmed - populate all values
                    if (response === true) {
                        cmp.set('v.existingAnimalId', existingAnimal.Id);
                        cmp.find('existingAnimalLookup').search();
                        return Promise.resolve();
                    }
                    //use existing animal rejected - edit entered values
                    if (response === false) {
                        return Promise.resolve();
                    }
                    //existing animal not found - close modal
                    cmp.set('v.animal.animalReferral', cmp.get('v.animalReferral'));
                    cmp.closeModal({animal: cmp.get('v.animal'), openNewModal: openNewModal});
                })
                .catch(errors => {
                    cmp.showErrors(errors);
                })
                .finally(() => {
                    cmp.set('v.isBusy', false);
                })
        } else {
            cmp.set('v.animal.animalReferral', cmp.get('v.animalReferral'));
            cmp.closeModal({animal: cmp.get('v.animal'), openNewModal: openNewModal});
        }
    }
});