public class aos_ProcessLogQueueable implements Queueable, Database.AllowsCallouts {
    //QUEUEABLE
    Set<Id> logIds = new Set<Id>();
    List<animalos__Log__c> logs = new List<animalos__Log__c>();

    public void execute(QueueableContext param1) {
        if (this.logs != null && !this.logs.isEmpty()) {
            insert logs;
            this.logIds = vertic_Utils.sObjects.getIdFieldValues(this.logs, animalos__Log__c.Id);
        }

        if (this.logIds != null && !this.logIds.isEmpty()) {
            Id logId = new List<Id>(this.logIds).get(0);

            animalos__Log__c logVar = (animalos__Log__c) vertic_Utils.arrays.firstOrException([
                    SELECT Id, animalos__Payload__c, animalos__Process__c
                    FROM animalos__Log__c
                    WHERE Id = :logId
            ]);

            try {
                ((vertic_AbstractProcessor) Type.forName(logVar.animalos__Process__c).newInstance()).process((Map<String, Object>) JSON.deserializeUntyped(logVar.animalos__Payload__c));
                update new animalos.Logging()
                        .setId(logVar.Id)
                        .addPayload((Map<String, Object>) JSON.deserializeUntyped(logVar.animalos__Payload__c))
                        .setType('Success')
                        .build();
            } catch (Exception ex) {
                update new animalos.Logging()
                        .setId(logVar.Id)
                        .addDetails(ex)
                        .addPayload((Map<String, Object>) JSON.deserializeUntyped(logVar.animalos__Payload__c))
                        .setType('Error')
                        .build();
            }

            this.logIds.remove(logId);
            if (!this.logIds.isEmpty()) {
                System.enqueueJob(new aos_ProcessLogQueueable(this.logIds));
            }
        }
    }

    public aos_ProcessLogQueueable(Set<Id> logIds) {
        this.logIds = logIds;
    }

    public aos_ProcessLogQueueable(List<animalos__Log__c> logs) {
        this.logs = logs;
    }

    public aos_ProcessLogQueueable() {
    }
}
