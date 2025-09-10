({
    handleInit: function (cmp, event, helper) {
        helper.processDependent(cmp, event, helper);
    },

    handleDependentChange: function (cmp, event, helper) {
        helper.processDependent(cmp, event, helper);
    },

    handleChange: function (cmp, event, helper) {
        let changeEvent = cmp.getEvent("onchange");
        changeEvent.setParams({
            payload: {
                value: cmp.get('v.value')
            }
        });
        changeEvent.fire();
    }
})