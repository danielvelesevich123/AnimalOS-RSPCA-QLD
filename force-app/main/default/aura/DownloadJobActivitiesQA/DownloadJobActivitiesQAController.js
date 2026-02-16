({
    handleInit: function (cmp, event, helper) {

        let procName = 'DownloadJobActivitiesQA';
        let fileName = 'Download Job Activities';

        if (cmp.get('v.recordId')) {
            window.open('/apex/aos_Content?proc=' + procName + '&fileName=' + fileName + '&renderAs=pdf' + '&jobId=' + cmp.get('v.recordId'), '_blank');
            window.setTimeout(
                $A.getCallback(function () {
                    $A.get("e.force:closeQuickAction").fire();
                }), 500
            );
        }
    }
});