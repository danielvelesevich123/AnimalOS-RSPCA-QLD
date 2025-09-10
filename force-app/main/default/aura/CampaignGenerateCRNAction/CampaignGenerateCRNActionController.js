({
    handleInit: function(cmp, event, helper){

    },

    handleBatchProgressComplete: function (cmp, event, helper) {
        helper.showMessage(cmp, 'Success', 'CRNs generating completed!');
        helper.closeModal(cmp);
    },

    handleRequestCRNClick: function (cmp, event, helper) {
        helper.generateCRN(cmp, helper);
    },

    handleCancelClick: function(cmp, event, helper){
        helper.closeModal(cmp);
    }
})