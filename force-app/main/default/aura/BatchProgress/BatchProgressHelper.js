({
    updateStatus: function (cmp, event, helper) {
        var batchId = cmp.get('v.batchId');
        var that = this;

        helper.execute(
            cmp,
            'vertic_SOQLProc',
            {
                SOQL: 'SELECT  Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset ' +
                    'FROM AsyncApexJob ' +
                    'WHERE Id = \'' + batchId + '\''
            },
            function (response) {

                if(!response.dto.records.length){
                    var completeEvent = cmp.getEvent("onComplete");
                    completeEvent.setParams({
                        payload: {
                            success: false,
                            error: 'No Async Job with Id: ' + batchId
                        }
                    });
                    completeEvent.fire();
                    cmp.set('v.isVisible', false);
                    return;
                }

                var job = response.dto.records[0];

                var status = job.Status;

                var progress = (job.JobItemsProcessed || 0) / (job.TotalJobItems || 1) * 100;
                cmp.set('v.progress', progress);
                console.log('progress', progress);

                if (status == 'Completed') {
                    // debugger
                    var completeEvent = cmp.getEvent("onComplete");
                    completeEvent.setParams({"payload": {success: true}});
                    completeEvent.fire();
                    cmp.set('v.isVisible', false);
                } else if (status == 'Aborted') {
                    var completeEvent = cmp.getEvent("onComplete");
                    completeEvent.setParams({
                        payload: {
                            success: false,
                            error: 'The Job has Aborted'
                        }
                    });
                    completeEvent.fire();
                    cmp.set('v.isVisible', false);
                } else if (status == 'Failed') {
                    var completeEvent = cmp.getEvent("onComplete");
                    completeEvent.setParams({
                        payload: {
                            success: false,
                            error: job.ExtendedStatus
                        }
                    });
                    completeEvent.fire();
                    cmp.set('v.isVisible', false);
                } else {

                    window.setTimeout(
                        $A.getCallback(function () {

                            that.updateStatus(cmp, event, helper);

                        }),
                        1000
                    );
                }
            }
        );
    }
})