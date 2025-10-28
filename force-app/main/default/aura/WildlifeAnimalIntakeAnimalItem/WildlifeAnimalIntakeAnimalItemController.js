({
    handleInit: function (cmp, event, helper) {
        let animal = cmp.get('v.animal');
        animal.title = (1 + cmp.get('v.indexVar')) + '. ' +
            (animal.animalos__Microchip_Number__c ? animal.animalos__Microchip_Number__c : 'New Animal');
    },

    handleActionClick: function (cmp, event, helper) {
        let action = cmp.get('v.isTableView') === true ? event.getSource().get('v.value') : event.getParam('value');

        cmp.getEvent('onaction').setParams({
            payload: {
                indexVar: cmp.get('v.indexVar'),
                action: action
            }
        }).fire();
    },

    handleEditLookupClick: function (cmp, event, helper) {
        let animal = cmp.get('v.animal');
        animal.isEditMode = !animal.isEditMode;
        cmp.set('v.animal', animal);
    },

    handlePrimaryBreedChange: function (cmp, event, helper) {
        let selectedBreed = cmp.find('primaryBreedLookup').get('v.selectedRecord');
        if (selectedBreed) {
            cmp.set('v.animal.animalos__Primary_Breed__r', selectedBreed.record);
        } else {
            cmp.set('v.animal.animalos__Primary_Breed__r', {});
        }
    }
});