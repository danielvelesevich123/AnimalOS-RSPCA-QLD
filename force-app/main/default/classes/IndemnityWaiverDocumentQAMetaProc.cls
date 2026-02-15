public with sharing class IndemnityWaiverDocumentQAMetaProc extends vertic_MetadataProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new MetadataRequest() : (MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{

        };

        super.process(this.request);
        this.initMetadata();
        this.initComponents();

        return this.response;
    }

    private void initMetadata() {
        vertic_MetadataProcessor.MetadataRequest request = new vertic_MetadataProcessor.MetadataRequest();

        this.recordId = this.request.getRequiredString('recordId');

        request.put('recordId', this.recordId);
        request.put('isVisualForce', true);

    }

    private void initComponents() {

        List<Object> components = new List<Object>();
        vertic_DTO dto = new vertic_DTO();

        animalos__Animal__c animal = (animalos__Animal__c) vertic_Utils.arrays.firstOrException([
            SELECT Id, Name, animalos__Animal_Name__c,
                    aos_Tag_Number__c, animalos__Primary_Breed__r.Name, animalos__Microchip_Number__c, (
                SELECT Id, animalos__Animal_Indemnity_Waiver_Content__c, animalos__Indemnity_Waiver__r.Name
                FROM animalos__Animal_Indemnity_Waivers__r
                ORDER BY CreatedDate ASC
            )
            FROM animalos__Animal__c
            WHERE Id = :this.recordId
        ], 'No animal with Id ' + this.recordId);

        vertic_AutoMapper autoMapper = new vertic_AutoMapper(dto)
            .getOptions()
            .setIsVisualforce(true)
            .setIsAllFields(true)
            .setDefaultFieldValue(' ')
            .getMapper()
            .mapFromSObject('animal', animal, new vertic_AutoMapper.BinderQueue(new AnimalBinder()));

        components.add(new Component.IndemnityWaiverDocument(
            dto = dto.getMap()
        ));

        this.response.dto.put('components', components);
        this.response.dto.put('head-component', new Component.IndemnityWaiverDocumentStyles());

    }

    public class AnimalBinder extends vertic_AutoMapper.AbstractBinder {

        public void bind(SObject animalVar, Map<String, Object> dtoMap) {
            animalos__Animal__c animal = (animalos__Animal__c) animalVar;

            dtoMap.put('animalBreed', animal.animalos__Primary_Breed__r == null ? '' : animal.animalos__Primary_Breed__r.Name);
            dtoMap.put('indemnityWaiverContent', animal.animalos__Animal_Indemnity_Waivers__r);

        }
    }
    /**
     * ==============================================================================================================
     *                                         STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */

    private vertic_Response tablesData;
    private String recordId;

}