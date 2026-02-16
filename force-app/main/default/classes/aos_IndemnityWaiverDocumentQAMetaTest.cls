@IsTest
private class aos_IndemnityWaiverDocumentQAMetaTest {
    @IsTest
    static void testBehavior() {

        animalos__Breed__c animalBreed = new animalos__Breed__c(
            animalos__Type__c = 'Dog',
            Name = 'Test Breed'
        );
        insert animalBreed;


        animalos__Animal__c animal = new animalos__Animal__c(
            animalos__Gender__c = 'Male',
            animalos__Primary_Breed__c = animalBreed.Id
        );
        insert animal;

        animalos__Indemnity_Waiver__c indemnityWaiver = new animalos__Indemnity_Waiver__c(
            Name = 'Test',
            animalos__Content__c = 'Test'
        );
        insert indemnityWaiver;

        animalos__Animal_Indemnity_Waiver__c animalIndemnityWaiver = new animalos__Animal_Indemnity_Waiver__c(
            animalos__Indemnity_Waiver__c = indemnityWaiver.Id,
            animalos__Animal__c = animal.Id
        );
        insert animalIndemnityWaiver;

        vertic_Response response = new IndemnityWaiverDocumentQAMetaProc().process(new Map<String, Object>{
            'recordId' => animal.Id
        });

        System.assert(response.isValid);
    }
}