({
    handleInit : function (cmp, event, helper){
        helper.execute(
            cmp,
            'JobFinalisationNotificationQAMetaProc',
            {
                recordId: cmp.get('v.recordId')
            },
            function (response) {
                // cmp.set('v.isBusy', false);

                cmp.set('v.availableIds', response.dto.availableIds);

                cmp.get('v.availableIds');

                console.log('availableIds - ' + cmp.get('v.availableIds'));
            },
            function(errors) {
                helper.utils(cmp).showToast({
                    type: 'error',
                    message: errors[0].message
                });
            }
        );
    },

    handleSubmitClick : function (cmp, event, helper){
        console.log('submit');

        console.log('emailTemplate - ' + cmp.get('v.emailTemplate'));

        console.log('contactId - ' + cmp.get('v.contactId'));

        helper.execute(
            cmp,
            'JobFinalisationNotificationQASubmitProc',
            {
                contactId: cmp.get('v.contactId'),
                emailTemplateDeveloperName: cmp.get('v.emailTemplate'),
                jobId: cmp.get('v.recordId')
            },
            function (response) {
                // cmp.set('v.isBusy', false);

                cmp.find('modal').close();
            },
            function(errors) {
                helper.utils(cmp).showToast({
                    type: 'error',
                    message: errors[0].message
                });
            }
        );
    },
});