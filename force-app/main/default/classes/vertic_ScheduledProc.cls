global abstract class vertic_ScheduledProc extends vertic_AbstractProcessor implements Schedulable, vertic_Structs.ISchedulable {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    global abstract String getScheduledJobName();
    global abstract String getScheduledCRON();
    global abstract Type getScheduledProcType();

    global virtual Map<String, Object> getScheduledParams(){
        return new Map<String, Object>();
    }

    global virtual Boolean isQueueable(){
        return false;
    }

    global void execute(SchedulableContext SC) {

        Vertic_Async_Process__c scheduledProcVar = vertic_AsyncProcess.create(
            this.getScheduledProcType(),
            this.getScheduledParams()
        );

        scheduledProcVar.Is_Queueable__c = this.isQueueable();

        vertic_AsyncProcess verticAsyncProcess = new vertic_AsyncProcess();
        verticAsyncProcess.add(scheduledProcVar);

        if(scheduledProcVar.Is_Queueable__c == true){
            verticAsyncProcess.enqueueAndRun();
        } else {
            verticAsyncProcess.enqueue();
        }
    }

    global virtual void start() {
        System.schedule(
            this.getScheduledJobName(),
            this.getScheduledCRON(),
            (Schedulable)this.getScheduledProcType().newInstance()
        );
    }

    global virtual void stop() {
        for (CronTrigger delCron : [
            SELECT Id
            FROM CronTrigger
            WHERE CronJobDetail.Name = :this.getScheduledJobName()
        ]) {
            System.abortJob(delCron.Id);
        }
    }


}