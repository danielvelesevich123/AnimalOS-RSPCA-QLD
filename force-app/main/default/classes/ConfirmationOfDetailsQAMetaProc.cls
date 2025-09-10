public class ConfirmationOfDetailsQAMetaProc extends vertic_MetadataProcessor {

    protected List<animalos__Animal__c> animals = new List<animalos__Animal__c>();

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                // SObject Fields, e.g. Contact.Salutation
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        String recordId = this.request.getRequiredString('recordId');

        List<Object> components = new List<Object>();
        vertic_DTO dto = new vertic_DTO();

        animalos__Referral__c referral = (animalos__Referral__c) vertic_Utils.arrays.firstOrException([
                SELECT
                        Id,
                        animalos__Contact__r.Name,
                        animalos__Contact__r.Full_Address__c,
                        animalos__Contact__r.Email,
                        animalos__Contact__r.HomePhone,
                        animalos__Contact__r.npe01__WorkPhone__c,
                        animalos__Contact__r.MobilePhone,
                        animalos__Contact__r.Fax
                FROM animalos__Referral__c
                WHERE Id = :recordId
        ]);

        this.animals = [
                SELECT Id, animalos__Microchip_Number__c, animalos__Animal_Name__c,
                        animalos__Gender__c, animalos__Primary_Breed__r.Name,
                        animalos__Type__c, animalos__Primary_Colour__c,
                        animalos__Date_of_Birth__c, Microchip_Implant_Date__c
                FROM animalos__Animal__c
                WHERE Id IN (
                        SELECT animalos__Animal__c
                        FROM animalos__Animal_Referral__c
                        WHERE animalos__Referral__c = :recordId
                )
        ];

        vertic_AutoMapper autoMapper = new vertic_AutoMapper(dto)
                .getOptions()
                .setIsVisualforce(true)
                .setIsAllFields(true)
                .setDefaultFieldValue(' ')
                .getMapper()
                .mapFromSObject('referral', referral)
                .mapFromListSObjects('animals', animals, new vertic_AutoMapper.BinderQueue(new AnimalBinder(this)));


        components.add(new Component.ConfirmationOfDetails(
                dto = dto.getMap()
        ));

        this.response.dto.put('components', components);
        this.response.dto.put('head-component', new Component.ConfirmationOfDetailsStyles());
    }

    public class AnimalBinder extends vertic_AutoMapper.AbstractBinder {

        private ConfirmationOfDetailsQAMetaProc parentClass;

        public AnimalBinder(ConfirmationOfDetailsQAMetaProc parentClass) {
            this.parentClass = parentClass;
        }

        public void bind(SObject animalVar, Map<String, Object> dtoMap) {
            animalos__Animal__c animal = (animalos__Animal__c) animalVar;

            dtoMap.put('animalBreed', animal.animalos__Primary_Breed__r == null ? '' : animal.animalos__Primary_Breed__r.Name);
            dtoMap.put('isLast', this.parentClass.animals.indexOf((animalos__Animal__c) animalVar) == (this.parentClass.animals.size() - 1));
        }
    }
}