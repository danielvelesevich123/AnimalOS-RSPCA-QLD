({
    handleSubmitClick: function (cmp, event, helper) {
        cmp.set('v.isBusy', true);
        cmp.utils
            .execute(
                cmp,
                'aos_SendDeletedOneDriveFileIdProc',
                {
                    recordId: cmp.get('v.recordId'),
                },
                function (response) {
                    cmp.set('v.meta', response);
                    cmp.set('v.isBusy', false);
                },
                function (errors) {
                    let errorMessages = cmp.find('modal').find('errorMessages');
                    errorMessages.showErrors(errors, true);
                    cmp.set('v.isBusy', false);
                }
            );
    },

    handleFinishClick: function (cmp, event, helper){
        cmp.find('modal').close();
    }
});