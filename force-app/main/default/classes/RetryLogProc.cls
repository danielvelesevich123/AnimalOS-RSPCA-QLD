public class RetryLogProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.retry();

        return this.response;
    }


    private void retry() {
        String logId = this.request.getRequiredString('recordId');
        animalos__Log__c logVar = (animalos__Log__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, animalos__Payload__c, animalos__Process__c
                FROM animalos__Log__c
                WHERE Id = :logId
        ], 'Log not found: ' + logId);

        try {
            vertic_AbstractProcessor processor = (vertic_AbstractProcessor) Type.forName(logVar.animalos__Process__c).newInstance();
            processor.process((Map<String, Object>) JSON.deserializeUntyped(logVar.animalos__Payload__c));
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
    }
}