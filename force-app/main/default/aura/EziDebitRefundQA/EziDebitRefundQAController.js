({
    handleInit: function (cmp, event, helper) {
        helper.getBaseCmp(cmp).doInit().then(function (resolve, reject) {
            var isSuccessful = cmp.get('v.meta.dto.payment.EziDebit_Transaction_ID__c') && cmp.get('v.meta.dto.payment.npsp_plus__Status__c') === 'Processed';
            if (isSuccessful == true) {
                cmp.set('v.screen', cmp.get('v.mainScreen'));
            }
        });
    },

    handleCloseClick: function (cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
        cmp.find('modal').close();
    },

    handleDoneRendering: function (cmp, event, helper) {
        var isSuccessful = cmp.get('v.meta.dto.payment.EziDebit_Transaction_ID__c') && cmp.get('v.meta.dto.payment.npsp_plus__Status__c') === 'Processed';
        if (isSuccessful == null || isSuccessful != true) {
            var closeAction = $A.get("e.force:closeQuickAction");
            if (closeAction) closeAction.fire();

            helper.utils(cmp).showToast({
                title: "Error!",
                message: 'You do not have access to perform this action, because Refunds can only be processed for successful payments.',
                type: 'error'
            });
        }
    },


    handleConfirm: function (cmp, event, helper) {
        if (!cmp.find('modal').validate()) {
            return;
        }
        helper.execute(
            cmp,
            'EziDebitRefundQASubmitProc',
            {
                recordId: cmp.get('v.recordId')
            },
            function (response) {

                cmp.find('modal').close();

                helper.utils(cmp).showToast({
                    title: "Success!",
                    message: 'The Refund has been processed successfully.',
                    type: 'success'
                });

            },
            function (errors) {
                cmp.find('modal').find('errorMessages').showErrors(errors, true);
            }
        );
    }
});