({
    handleCancelClick: function (cmp, event, helper) {
        cmp.closeModal();
    },

    handleSubmitClick: function (cmp, event, helper) {
        helper.submit(cmp, event, helper);
    },

    handleSubmitAndNewClick: function (cmp, event, helper) {
        helper.submit(cmp, event, helper, true);
    },

    handlePrimaryBreedLookupLoad: function (cmp, event, helper) {
        let selectedBreed = cmp.find('primaryBreedLookup').get('v.selectedRecord');
        if (selectedBreed) {
            cmp.set('v.animal.animalos__Primary_Breed__r', selectedBreed.record);
        }
    },

    handleExistingAnimalIdChange: function (cmp, event, helper) {
        let existingAnimal = cmp.find('existingAnimalLookup').get('v.selectedRecord');
        if (existingAnimal) {
            if (cmp.get('v.animal.Id') !== existingAnimal.record.Id) {
                cmp.set('v.isBusy', true);
                cmp.set('v.animal', existingAnimal.record);
                cmp.find('primaryBreedLookup').search();
                cmp.set('v.isBusy', false);
                let additionalFields = cmp.get('v.additionalFields');
                if (additionalFields) {
                    additionalFields.forEach(field => {
                        field.defaultValue = existingAnimal.record[field.name];
                    });
                    cmp.set('v.additionalFields', additionalFields);
                }
            }
        }
    }
})