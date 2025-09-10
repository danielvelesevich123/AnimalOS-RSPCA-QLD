({
    showToast: function(cmp, event, helper) {

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'test',
            message: 'test',
            type: 'success'
        });
        toastEvent.fire();
    },
});