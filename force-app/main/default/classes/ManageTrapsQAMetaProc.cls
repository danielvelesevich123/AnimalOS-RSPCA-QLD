public class ManageTrapsQAMetaProc extends vertic_MetadataProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                animalos__Resource__c.aos_Status__c
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        String recordId = this.request.getRequiredString('recordId');

        animalos__Job__c job = (animalos__Job__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, animalos__Location_Of_Interest__c
                FROM animalos__Job__c
                WHERE Id = :recordId
        ]);

        List<animalos__Resource__c> resources = [
                SELECT Id, Name
                FROM animalos__Resource__c
                WHERE animalos__Type__c = 'Trap' AND aos_Status__c = 'Available'
        ];

        this.response.put('locationOfInterestId', job.animalos__Location_Of_Interest__c);
        this.response.getMapper().mapFromListSObjects('resources', resources);
    }
}