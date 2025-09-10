({
    handleInit: function (cmp, event, helper) {

        let procName = 'AOS_JobSummaryQA';
        let fileName = 'Job Summary';

        let jobIds = cmp.get('v.pageReference.state.c__jobIds');

        if (cmp.get('v.recordId')) {
            window.open('/apex/AOS_JobSummary?proc=' + procName + '&fileName=' + fileName + '&renderAs=pdf' + '&jobId=' + cmp.get('v.recordId'), '_blank');
            window.setTimeout(
                $A.getCallback(function () {
                    $A.get("e.force:closeQuickAction").fire();
                }), 500
            );
        } else if (jobIds) {
            window.setTimeout(
                $A.getCallback(function () {
                    window.open('/apex/AOS_JobSummary?proc=' + procName + '&fileName=' + fileName + '&renderAs=pdf' + '&jobId=' + jobIds, '_blank');
                }), 1000
            );

        } else {
            cmp.find('notifyLib').showToast({
                variant: 'error',
                message: 'Job records were not found. Please select the Job records on the List View layout and use the \'Download Summaries\' action',
            });
        }


    }
});