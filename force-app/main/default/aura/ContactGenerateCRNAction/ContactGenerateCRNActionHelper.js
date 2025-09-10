({
    requestCRN: function(cmp, helper){
        helper.execute(cmp, 'ContactGenerateCRNActionSubmitProc',
            {
                recordId: cmp.get('v.recordId')
            }
        ).then(function (response) {
            if (response.isValid) {
                cmp.set('v.message', 'BPAY Customer Reference Number: ' + response.dto.CRN);
                cmp.set('v.disabled', true);
                $A.get('e.force:refreshView').fire();
            }
        })
    },
})