({
    handleInit: function (cmp, event, helper) {

        let procName = 'IndemnityWaiverDocumentQA';
        let fileName = 'Indemnity Waiver';

        window.open('/apex/aos_IndemnityWaiver?proc=' + procName + '&fileName=' + fileName + '&renderAs=pdf' + '&recordId=' + cmp.get('v.recordId'), '_blank');
        window.setTimeout(
            $A.getCallback(function () {
                $A.get("e.force:closeQuickAction").fire();
            }), 500
        );
    }
});