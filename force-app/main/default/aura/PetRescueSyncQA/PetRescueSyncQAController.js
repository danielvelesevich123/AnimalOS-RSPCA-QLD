({
    handleInit: function (cmp, event, helper) {
        cmp.set('v.isBusy', true);

        cmp.utils
            .execute(
                cmp,
                'aos_PetRescueSyncQAMetaProc',
                {
                    recordId: cmp.get('v.recordId')
                },
                function (response) {
                    cmp.set('v.meta', response);
                },
                function (errors) {
                    cmp.find('modal').find('errorMessages').showErrors(errors, true);
                }
            )
            .finally(() => {
                cmp.set('v.isBusy', false);
            });
    },

    handleSubmitClick: function (cmp, event, helper) {
        let errorMessagesCmp = cmp.find('modal').find('errorMessages');

        errorMessagesCmp.clearErrors();

        let validationResult = cmp.utils.validate(cmp.find('form'));
        if (validationResult.allValid !== true) {
            errorMessagesCmp.showErrors(validationResult.getErrorMessages(), true);
            return;
        }

        cmp.set('v.isBusy', true);

        cmp.utils
            .execute(
                cmp,
                'aos_PetRescueSyncQASubmitProc',
                {
                    recordId: cmp.get('v.recordId'),
                    locationId: cmp.get('v.meta.dto.locationId'),
                    status: cmp.get('v.meta.dto.status')
                },
                function (response) {
                    cmp.find('notifyLib').showToast({
                        variant: 'success',
                        message: 'Animal has been successfully synced with PetRescue',
                    });
                    cmp.find('modal').close();
                },
                function (errors) {
                    cmp.find('modal').find('errorMessages').showErrors(errors, true);
                }
            )
            .finally(() => {
                cmp.set('v.isBusy', false);
            });
    }
});