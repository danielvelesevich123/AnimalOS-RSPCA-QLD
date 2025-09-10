({
    handleInit: function (cmp, event, helper) {

        let procName = 'DownloadInspectorateActivitiesQA';
        let fileName = 'Download Inspectorate Activities';

        if (cmp.get('v.recordId')) {
            window.open('/apex/vertic_Content?proc=' + procName + '&fileName=' + fileName + '&renderAs=pdf' + '&jobId=' + cmp.get('v.recordId'), '_blank');
            window.setTimeout(
                $A.getCallback(function () {
                    $A.get("e.force:closeQuickAction").fire();
                }), 500
            );
        }
    }
});