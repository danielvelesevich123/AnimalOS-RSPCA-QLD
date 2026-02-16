public without sharing class aos_JobFinalisationNotifQAMetaProc extends vertic_MetadataProcessor{
    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new MetadataRequest() : (MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                // SObject Fields, e.g. Contact.Salutation
        };

        super.process(this.request);

        this.initMetadata();

        return this.response;
    }

    private void initMetadata(){
        String recordId = this.request.getString('recordId');

        List<animalos__Job_Contact__c> jobContacts = [
                SELECT
                        Id,
                        animalos__Contact__c,
                        animalos__Contact__r.Email,
                        animalos__Contact_Type__c
                FROM animalos__Job_Contact__c
                WHERE
                        animalos__Job__c = :recordId
                        AND animalos__Contact_Type__c = 'Informant'
        ];

        if(jobContacts.size() > 0){
            Set<String> availableIds = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(jobContacts, animalos__Job_Contact__c.animalos__Contact__c).keySet();

            this.response.put('availableIds', '(\'' + String.join(availableIds, '\', \'') + '\')');
        }
    }
}