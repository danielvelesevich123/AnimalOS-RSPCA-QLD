@IsTest
private class animalos_AlertDomainTest {
    @IsTest
    static void testBehavior() {
        animalos__Breed__c animalBreed = new animalos__Breed__c(
                animalos__Type__c = 'Dog',
                Name = 'Test Breed'
        );
        insert animalBreed;
        animalos__Animal__c animal = new animalos__Animal__c(
                animalos__Animal_Name__c = 'Test Animal',
                animalos__Class__c = 'Domestic',
                animalos__Type__c = 'Dog',
                animalos__Age_Group__c = 'Young Adult 6 mths - 1 yr',
                animalos__Date_of_Birth__c = Date.today(),
                animalos__Stage__c = 'Pre-Intake',
                animalos__Status__c = 'Information',
                aos_Is_New__c = false,
                animalos__Primary_Breed__c = animalBreed.Id
        );
        insert animal;

        animalos__Alert__c alert = new animalos__Alert__c(
                animalos__Target_Object__c = 'animalos__Animal__c',
                animalos__Target_Record_Id__c = animal.Id
        );
        insert alert;

        System.assertEquals(animal.Id, [
                SELECT Id, aos_Animal__c
                FROM animalos__Alert__c
                WHERE Id = :alert.Id
        ].aos_Animal__c);

    }
}