public class aos_JobContactIntCautionsMetaProc extends vertic_MetadataProcessor {

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
        String contactId = this.request.getString('contactId');
        String jobId = this.request.getString('jobId');
        String jobContactId = this.request.getString('jobContactId');

        if(String.isBlank(contactId) && String.isBlank(jobId) && String.isBlank(jobContactId)) {
            throw new vertic_Structs.MissingDataException('At least one of the following parameters must be provided: contactId, jobId, jobContactId');
        }

        Set<String> fields = new Set<String>{
                'Id',
                'animalos__Caution_Details__c',
                'animalos__Caution_Type__c',
                'animalos__Caution_Source__c',
                'animalos__Caution_Date_Time__c',
                'animalos__Job_Contact__r.animalos__Job__r.Name'
        };

        fflib_QueryFactory queryFactory = new fflib_QueryFactory(animalos__Interaction_Caution__c.SObjectType)
                .selectFields(fields)
                .addOrdering('animalos__Job_Contact__r.animalos__Job__r.Name', fflib_QueryFactory.SortOrder.DESCENDING)
                .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);

        if (String.isNotBlank(contactId)) {
            queryFactory.setCondition('animalos__Contact__c = :contactId');
        }

        if (String.isNotBlank(jobId)) {
            queryFactory.setCondition('animalos__Job_Contact__r.animalos__Job__c = :jobId');
        }

        if (String.isNotBlank(jobContactId)) {
            queryFactory.setCondition('animalos__Job_Contact__c = :jobContactId');
        }

        List<animalos__Interaction_Caution__c> interactionCautions = Database.query(queryFactory.toSOQL());
        this.response.getMapper().mapFromListSObjects('interactionCautions', interactionCautions);
    }
}