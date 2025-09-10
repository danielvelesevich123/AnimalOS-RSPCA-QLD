({
    handleInit: function (cmp, event, helper) {
        let recordId = cmp.get('v.recordId');

        if (recordId) {
            window.open('/lightning/cmp/animalos__StartReferral?c__recordId=' + recordId, '_blank');
            window.setTimeout(
                $A.getCallback(() => {
                    $A.get("e.force:closeQuickAction").fire();
                })
            );
        }
    }
});