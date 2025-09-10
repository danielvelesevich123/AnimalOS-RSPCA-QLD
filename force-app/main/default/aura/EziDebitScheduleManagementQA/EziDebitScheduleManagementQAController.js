({
    handleInit: function (cmp, event, helper) {
        cmp.set('v.isBusy', true);
        cmp.utils
            .execute(cmp, 'EziDebitScheduleManagementQAMetaProc', {})
            .then(response => {
                cmp.set('v.meta', response);
            })
            .catch(errors => {
                cmp.find('modal').showErrors(errors, true);
            })
            .finally(() => {
                cmp.set('v.isBusy', false);
            });
    },

    handleSubmitClick: function (cmp, event, helper) {
        let errorMessagesCmp = cmp.find('modal').find('errorMessages');
        errorMessagesCmp.clearErrors();

        let validationResult = cmp.utils.validate(cmp.find('modal'), {}), errors = [];

        if (validationResult.allValid !== true) {
            errors.push.apply(errors, validationResult.getErrorMessages());
        }

        if (errors.length !== 0) {
            errorMessagesCmp.showErrors(errors, true);
            return;
        }

        cmp.set('v.isBusy', true);
        let processor = 'EzidebitScheduleManagementQA' + (cmp.get('v.selectedAction') === 'migrate' ? 'MigrateProc' : 'CancelProc');
        cmp.utils
            .execute(cmp, processor, {
                recordId: cmp.get('v.recordId'),
                closedReason: cmp.get('v.closedReason')
            })
            .then(response => {
                cmp.find('notifLib').showToast({
                    variant: 'success',
                    message: 'The operation has been successfully completed.'
                });

                $A.get('e.force:refreshView');
                cmp.find('modal').close();
            })
            .catch(errors => {
                cmp.find('modal').showErrors(errors, true);
            })
            .finally(() => {
                cmp.set('v.isBusy', false);
            });
    }
});