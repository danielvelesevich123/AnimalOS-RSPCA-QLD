({
    addNewAnimal: function (cmp, event, helper) {
        let additionalFields = cmp.get('v.meta.dto.additionalFields') ? JSON.parse(JSON.stringify(cmp.get('v.meta.dto.additionalFields'))) : [],
            animalReferralFields = cmp.get('v.meta.dto.animalReferralFields') ? JSON.parse(JSON.stringify(cmp.get('v.meta.dto.animalReferralFields'))) : [];

        cmp.find('modalService')
            .show(
                'c:WildlifeAnimalIntakeQANewAnimalModal',
                {
                    selectOptions: cmp.get('v.meta.selectOptions'),
                    dependentOptions: cmp.get('v.meta.dependentOptions'),
                    animalLookupFields: cmp.get('v.meta.dto.animalLookupFields'),
                    additionalFields: additionalFields,
                    animalReferralFields: animalReferralFields,
                    animal: JSON.parse(cmp.get('v.animalJSON')),
                    isInboundRecordType: cmp.get('v.meta.dto.isInboundRecordType')
                },
                {
                    header: 'New Animal',
                    cssClass: 'slds-modal_large'
                }
            )
            .then(response => {
                if (response) {
                    let animals = cmp.get('v.meta.dto.animals') || [];
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
});