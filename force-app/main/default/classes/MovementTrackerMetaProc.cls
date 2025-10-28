public class MovementTrackerMetaProc extends vertic_MetadataProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        super.process(this.request);

        this.doInit();

        return this.response;
    }

    private void doInit() {
        String recordId = this.request.getRequiredString('recordId');

        animalos__Animal__c animal = (animalos__Animal__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, Name
                FROM animalos__Animal__c
                WHERE Id = :recordId
                WITH USER_MODE
                LIMIT 1
        ]);

        this.response.getMapper().mapFromSObject('animal', animal);
    }
}