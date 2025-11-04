({
    handleInit: function(cmp, event, helper){
        helper.processDependent(cmp, event, helper);
    },

    handleDependentChange: function(cmp, event, helper){
        helper.processDependent(cmp, event, helper);
    },

    handleValueChange: function(cmp, event, helper){
        var completeEvent = cmp.getEvent("onchange");
        completeEvent.setParams({
            payload: {
                name: event.getSource().get('v.name'),
                value: event.getSource().get('v.value')
            }
        });
        completeEvent.fire();
    }
})