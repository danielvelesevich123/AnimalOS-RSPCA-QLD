({
    handleShowProgress: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var batchId = params.batchId;

            cmp.set('v.progress', 0);
            cmp.set('v.isVisible', true);
            cmp.set('v.batchId', batchId);

            helper.updateStatus(cmp, event, helper);
        }
    }
})