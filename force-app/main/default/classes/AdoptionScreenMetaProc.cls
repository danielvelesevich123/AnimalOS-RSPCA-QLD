public without sharing class AdoptionScreenMetaProc extends vertic_MetadataProcessor{
    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{};

        super.process(this.request);

        this.initMetadata();

        return this.response;
    }

    private void initMetadata(){
        String unitId = this.request.getString('unitId');

        animalos__Location__c locationVar = (animalos__Location__c)vertic_Utils.arrays.firstOrException(
                [
                        SELECT Id
                        FROM animalos__Location__c
                        WHERE
                                aos_Shelter_ID__c = :unitId
                                AND RecordType.DeveloperName = 'Unit'
                        LIMIT 1
                ], 'There is no unit with provided Id'
        );

        List<animalos__Movement__c> movements = [
                SELECT
                        Id,
                        animalos__Animal__c
                FROM animalos__Movement__c
                WHERE
                        animalos__Current__c = TRUE
                        AND animalos__Location__r.aos_Shelter_ID__c = :unitId
                        AND animalos__Location__r.RecordType.DeveloperName = 'Unit'
        ];

        Set<String> animalIds = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(movements, animalos__Movement__c.animalos__Animal__c).keySet();

        List<animalos__Animal__c> animals = [
                SELECT
                        Id,
                        Name,
                        animalos__Animal_Name__c,
                        animalos__Adoption_Fee__c,
                        animalos__Primary_Breed__c,
                        animalos__Primary_Breed__r.Name,
                        animalos__Secondary_Breed__c,
                        animalos__Secondary_Breed__r.Name,
                        animalos__Gender__c,
                        animalos__Adoption_Profile__c,
                        animalos__Current_Unit__r.Name,
                        animalos__Age_for_Adoption_Website__c
                FROM animalos__Animal__c
                WHERE Id IN :animalIds
        ];

        this.response.getMapper().mapFromListSObjects('animals', animals, new vertic_AutoMapper.BinderQueue(
                new AnimalBinder(animals)
        ));
        this.response.put('unitId', unitId);
        this.response.put('unitHasMultipleAnimals', animals.size() > 0);
    }

    public class AnimalBinder extends vertic_AutoMapper.AbstractBinder {

        List<animalos__Animal__c> animals;

        public AnimalBinder(
                List<animalos__Animal__c> animals
        ) {
            this.animals = animals;
        }

        public void bind(SObject animalVar, Map<String, Object> dtoMap) {
            animalos__Animal__c animal = (animalos__Animal__c) animalVar;

            String photoTitle = 'Profile Photo - ' + animal.Name;

            ContentDocumentLink photoDocumentLink = (ContentDocumentLink) vertic_Utils.arrays.firstOrNull([
                    SELECT ContentDocument.LatestPublishedVersionId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :animal.Id
                    AND ContentDocument.Title = :photoTitle
            ]);
            if (photoDocumentLink != null) {
                ContentDistribution photoDistribution = (ContentDistribution) vertic_Utils.arrays.firstOrNull([
                        SELECT ContentDownloadUrl
                        FROM ContentDistribution
                        WHERE ContentVersionId = :photoDocumentLink.ContentDocument.LatestPublishedVersionId
                        OR ContentDocumentId = :photoDocumentLink.ContentDocumentId
                ]);

                if (photoDistribution != null) {
                    dtoMap.put('photoUrl', photoDistribution.ContentDownloadUrl);
                }
            }
        }
    }

}
