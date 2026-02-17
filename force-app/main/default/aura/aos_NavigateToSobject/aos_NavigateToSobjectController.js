({
    handleInit: function (cmp, event, helper) {
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get('v.recordId')
        });
        navEvt.fire();
    }
});