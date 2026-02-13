({
    handleNewAnimalClick: function (cmp, event, helper) {
        helper.addNewAnimal(cmp, event, helper);
    },

    handleAction: function (cmp, event, helper) {
        let payload = event.getParam('payload'),
            indexVar = payload.indexVar,
            action = payload.action,
            animals = cmp.get('v.meta.dto.animals') || [],
            animal = animals[indexVar];

        switch (action) {
            case 'delete':
                animals.splice(indexVar, 1);
                cmp.set('v.meta.dto.animals', animals);
                break;
            case 'edit':

                let additionalFields = cmp.get('v.meta.dto.additionalFields') ? JSON.parse(JSON.stringify(cmp.get('v.meta.dto.additionalFields'))) : [],
                    animalReferralFields = cmp.get('v.meta.dto.animalReferralFields') ? JSON.parse(JSON.stringify(cmp.get('v.meta.dto.animalReferralFields'))) : [];
                if (animal) {
                    cmp.find('modalService')
                        .show(
                            'c:WildlifeAnimalIntakeQANewAnimalModal',
                            {
                                selectOptions: cmp.get('v.meta.selectOptions'),
                                dependentOptions: cmp.get('v.meta.dependentOptions'),
                                animal: animal,
                                animalReferral: animal.animalReferral || {},
                                existingAnimalId: animal.Id,
                                additionalFields: additionalFields,
                                animalReferralFields: animalReferralFields,
                                animalLookupFields: cmp.get('v.meta.dto.animalLookupFields'),
                                isInboundRecordType: cmp.get('v.meta.dto.isInboundRecordType'),
                                recordTypeDevName: cmp.get('v.meta.dto.recordTypeDeveloperName')
                            },
                            {
                                header: 'Edit Animal',
                                cssClass: 'slds-modal_large'
                            }
                        )
                        .then(response => {
                            if (response) {
                                animals[indexVar] = response.animal;
                                cmp.set('v.meta.dto.animals', animals);
                                if (response.openNewModal === true) {
                                    helper.addNewAnimal(cmp, event, helper);
                                }
                            }
                        })
                        .catch(errors => {
                            cmp.showErrors(errors);
                        })
                }

                break;
            case 'copy':
                if (animal) {
                    let clonedAnimal = JSON.parse(JSON.stringify(animal)),
                        additionalFields = cmp.get('v.meta.dto.additionalFields') ? JSON.parse(JSON.stringify(cmp.get('v.meta.dto.additionalFields'))) : [],
                        animalReferralFields = cmp.get('v.meta.dto.animalReferralFields') ? JSON.parse(JSON.stringify(cmp.get('v.meta.dto.animalReferralFields'))) : [];

                    clonedAnimal.Id = null;
                    clonedAnimal.Name = null;

                    cmp.find('modalService')
                        .show(
                            'c:WildlifeAnimalIntakeQANewAnimalModal',
                            {
                                selectOptions: cmp.get('v.meta.selectOptions'),
                                dependentOptions: cmp.get('v.meta.dependentOptions'),
                                animal: clonedAnimal,
                                animalReferral: clonedAnimal.animalReferral || {},
                                additionalFields: additionalFields,
                                animalReferralFields: animalReferralFields,
                                animalLookupFields: cmp.get('v.meta.dto.animalLookupFields'),
                                isInboundRecordType: cmp.get('v.meta.dto.isInboundRecordType'),
                                recordTypeDevName: cmp.get('v.meta.dto.recordTypeDeveloperName')
                            },
                            {
                                header: 'Clone Animal',
                                cssClass: 'slds-modal_large'
                            }
                        )
                        .then(response => {
                            if (response) {
                                animals.push(response.animal);
                                cmp.set('v.meta.dto.animals', animals);
                                if (response.openNewModal === true) {
                                    helper.addNewAnimal(cmp, event, helper);
                                }
                            }
                        })
                        .catch(errors => {
                            cmp.showErrors(errors);
                        })
                }

                break;
            case 'bulkClone':
                cmp.set('v.isBusy', true);

                if (animal) {
                    cmp.find('modalService')
                        .show(
                            'c:WildlifeAnimalIntakeBulkCloneModal',
                            {
                                closeCallback: () => {
                                    cmp.set('v.isBusy', false);
                                }
                            },
                            {
                                header: 'How many Animals do you want to create?',
                                cssClass: 'slds-modal_small'
                            }
                        )
                        .then(response => {
                            if (response) {
                                for (let i = 0; i < response; i++) {
                                    let clonedAnimal = JSON.parse(JSON.stringify(animal));

                                    delete clonedAnimal.Id;
                                    delete clonedAnimal.Name;
                                    delete clonedAnimal.animalos__Animal_Name__c;
                                    delete clonedAnimal.animalos__Microchip_Number__c;
                                    delete clonedAnimal.animalos__Shelter_ID__c;
                                    delete clonedAnimal.errorMessage;
                                    clonedAnimal.isEditMode = false;
                                    animals.push(clonedAnimal);
                                }

                                cmp.set('v.meta.dto.animals', animals);
                            }
                        })
                        .catch(errors => {
                            cmp.showErrors(errors);
                        })
                        .finally(() => {
                            cmp.set('v.isBusy', false);
                        });
                }
                break;
            default:
                break;
        }
    }
});