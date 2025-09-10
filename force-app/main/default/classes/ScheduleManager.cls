//SECURED!
global with sharing class ScheduleManager {

    public static final String EZIDEBIT_GET_PAYMENTS_DAILY = 'Ezidebit Get Payments - Every Day at 8 PM';

    public static final Map<String, Object> SCHEDULERS = new Map<String, Object>{
            EZIDEBIT_GET_PAYMENTS_DAILY => new Map<String, Object>{
                    'type' => EzidebitGetPaymentsScheduledBatch.class,
                    'cron' => '0 0 20 * * ? *' //Every Day at 8 PM
            }
    };

    global static void restart() {
        stopAll();
        startAll();
    }

    global static void startAll() {
        for (String jobName : SCHEDULERS.keySet()) {

            Map<String, Object> scheduleSetting = (Map<String, Object>) SCHEDULERS.get(jobName);
            Type typeVar = (Type) scheduleSetting.get('type');

            System.debug(jobName);
            System.debug((String) scheduleSetting.get('cron'));
            System.debug((Schedulable) typeVar.newInstance());
            System.schedule(
                    jobName,
                    (String) scheduleSetting.get('cron'),
                    (Schedulable) typeVar.newInstance()
            );
        }
    }

    global static void stopAll() {
        for (CronTrigger delCron : [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name IN :SCHEDULERS.keySet()
                WITH SECURITY_ENFORCED
        ]) {
            System.abortJob(delCron.Id);
        }
    }



    public static Id schedule(String jobName, Time timeVar, Schedulable scheduler) {
        return schedule(jobName, String.format('0 {1} {0} * * ? *', new List<String>{
                '' + timeVar.hour(),
                '' + timeVar.minute()
        }), scheduler);
    }


    public static Id schedule(String jobName, String cron, Schedulable scheduler) {
        return System.schedule(
                jobName,
                cron,
                scheduler
        );
    }



    public static void abortSchedule(String jobName) {
        jobName = jobName + '%';
        for (CronTrigger delCron : [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :jobName
                WITH SECURITY_ENFORCED
        ]) {
            System.abortJob(delCron.Id);
        }
    }


    public static CronTrigger getScheduled(String jobName) {
        jobName = '%' + jobName + '%';
        return (CronTrigger) vertic_Utils.arrays.firstOrNull([
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :jobName
                WITH SECURITY_ENFORCED
        ]);
    }

}