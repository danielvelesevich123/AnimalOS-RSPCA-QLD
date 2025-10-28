({
    handleCopyToAllClick: function (cmp, event, helper) {
        let action = event.getSource().get('v.value');

        cmp.getEvent('onaction').setParams({
            payload: {
                indexVar: cmp.get('v.indexVar'),
                action: action
            }
        }).fire();
    }
});