public class aos_DesexedCertificateQAMetaProc  extends aos_MetadataProcessor {

    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        String animalId = this.request.getRequiredString('animalId');

        List<Object> components = new List<Object>();

        List<animalos__Animal__c> animals = [
                SELECT
                    Id
                    ,Name
                    ,animalos__Animal_Name__c
                    ,animalos__Calculated_Age__c
                    ,animalos__Current_Site__c
                    ,animalos__Current_Site__r.Name
                    ,animalos__Current_Site__r.aos_Postcode__c
                    ,animalos__Current_Site__r.aos_Site_Phone__c
                    ,animalos__Current_Site__r.aos_State__c
                    ,animalos__Current_Site__r.aos_Street_Address__c
                    ,animalos__Current_Site__r.aos_Suburb__c
                    ,animalos__Current_Weight__c
                    ,animalos__Gender__c
                    ,animalos__Microchip_Number__c
                    ,animalos__Neutered_Spayed_Date_Time__c
                    ,animalos__Primary_Breed__r.Name
                    ,animalos__Primary_Colour__c
                    ,animalos__Secondary_Breed__r.Name
                    ,animalos__Secondary_Colour__c
                    ,animalos__Shelter_ID__c
                    ,animalos__Type__c
                    ,aos_Crossbreed__c
                    ,aos_Neutered_Spayed_By__c
                    ,aos_Neutered_Spayed_By__r.Name
                FROM animalos__Animal__c
                WHERE Id = :animalId
        ];

        String fileName;

        for (animalos__Animal__c animal : animals) {

            Map<String, Object> dto = new Map<String, Object>();

            dto.put('animal', animal);

            components.add(new Component.aos_DesexedCertificate(
                dto = dto
            ));

            if (fileName == null) {
                fileName = 'Desexed Certificate - ' + animal.Name;
            } else {
                fileName += '_' + animal.Name;
            }
        }

        fileName = fileName.left(80);

        if (ApexPages.currentPage() != null) {
            ApexPages.currentPage()
                    .getHeaders()
                    .put('content-disposition', 'filename=' + fileName + '.pdf');
        }

        this.response.dto.put('components', components);
        this.response.dto.put('head-component', new Component.aos_DesexedCertificateStyles());
    }
}