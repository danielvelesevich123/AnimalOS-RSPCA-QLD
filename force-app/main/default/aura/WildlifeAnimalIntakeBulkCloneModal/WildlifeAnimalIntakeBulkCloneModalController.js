({
    handleCancelClick: function (cmp, event, helper) {
        cmp.cancelModal();
    },

    handleSubmitClick: function (cmp, event, helper) {
        if (cmp.utils.validate(cmp.find('form')).allValid !== true) {
            return;
        }

        cmp.closeModal(cmp.get('v.numberOfAnimals'));
    }
});