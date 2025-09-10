({
    generateCRN: function (cmp, helper) {
        cmp.set('v.message', null);
        cmp.set('v.disabled', true);

        return new Promise($A.getCallback(function (resolve, reject) {
            helper.execute(cmp, 'CampaignGenerateCRNActionSubmitProc',
                {
                    recordId: cmp.get('v.recordId')
                }
            ).then(function (response) {

                var batchId = response.dto.batchId;
                if (batchId) {
                    cmp.find('batchProgress').showProgress(batchId);
                } else {
                    cmp.set('v.message', 'CRNs generating failed!');
                }
                resolve(response);
            }).catch(function (reason) {
                reject(reason);
            });
        }));
    },

    closeModal: function(cmp){
        $A.get('e.force:refreshView').fire();

        var closeAction = $A.get("e.force:closeQuickAction");
        if(closeAction) { closeAction.fire(); }
    },

    showMessage: function(cmp, variant, message){
        cmp.find('notifyLib').showToast({
            variant: variant,
            message:  message
        });
    },
})