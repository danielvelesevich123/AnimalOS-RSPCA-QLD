public class aos_JobContactsAddIntCautionMetaProc extends vertic_MetadataProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                animalos__Interaction_Caution__c.animalos__Caution_Source__c,
                animalos__Interaction_Caution__c.animalos__Caution_Type__c
        };

        super.process(this.request);

        this.doInit();

        return this.response;
    }

    private void doInit() {
        String jobContactId = this.request.getString('jobContactId');

        animalos__Interaction_Caution__c interactionCautionVar = new animalos__Interaction_Caution__c(
                animalos__Caution_Date_Time__c = Datetime.now(), animalos__Job_Contact__c = jobContactId
        );

        if(String.isNotBlank(jobContactId)) {
            animalos__Job_Contact__c jobContactVar = (animalos__Job_Contact__c) vertic_Utils.arrays.firstOrException([
                    SELECT Id, animalos__Contact__c
                    FROM animalos__Job_Contact__c
                    WHERE Id = :jobContactId
            ], 'No Job Contact with Id: ' + jobContactId);
            interactionCautionVar.animalos__Contact__c = jobContactVar.animalos__Contact__c;
        }

        this.response.put('interactionCaution', interactionCautionVar);
    }
}