@IsTest
private class CalcRollupsAssessmentTotalScoreTest {

    @IsTest
    static void calculatesTotalScoreFromAssessmentScores() {
        // Minimal animal to satisfy potential lookups on Assessment
        animalos__Breed__c breed = new animalos__Breed__c(
                animalos__Type__c = 'Dog',
                Name = 'Test Breed'
        );
        insert breed;

        animalos__Animal__c animal = new animalos__Animal__c(
                animalos__Animal_Name__c = 'Test Animal',
                animalos__Class__c = 'Domestic',
                animalos__Type__c = 'Dog',
                animalos__Age_Group__c = 'Young Adult 6 mths - 1 yr',
                animalos__Date_of_Birth__c = Date.today(),
                animalos__Stage__c = 'Pre-Intake',
                animalos__Status__c = 'Information',
                aos_Is_New__c = false,
                animalos__Primary_Breed__c = breed.Id
        );
        insert animal;

        // Create an Assessment record. Keep fields minimal and avoid trigger side-effects by disabling domain events on update in batch.
        animalos__Assessment__c assessment = new animalos__Assessment__c(
                animalos__Animal__c = animal.Id,
                animalos__Assessment_Date_Time__c = Datetime.now()
        );
        insert assessment;

        // Create related Assessment Score records that the rollup will sum
        List<aos_Assessment_Score__c> scores = new List<aos_Assessment_Score__c>{
                new aos_Assessment_Score__c(
                        aos_Assessment__c = assessment.Id,
                        aos_Score__c = 3,
                        Name = 'Cat 1',
                        aos_Score_Category__c = 'Cat 1'
                ),
                new aos_Assessment_Score__c(
                        aos_Assessment__c = assessment.Id,
                        aos_Score__c = 7,
                        Name = 'Cat 2',
                        aos_Score_Category__c = 'Cat 2'
                )
        };
        insert scores;

        // Execute the batch directly calling process with our assessment in scope
        Test.startTest();
        new CalcRollupsAssessmentTotalScore().process(new List<SObject>{ assessment });
        Test.stopTest();

        // Verify total score is the sum of child scores (3 + 7 = 10)
        assessment = [SELECT Id, animalos__Total_Score__c FROM animalos__Assessment__c WHERE Id = :assessment.Id];
        System.assertEquals(10, assessment.animalos__Total_Score__c);
    }

    @IsTest
    static void handlesNoScoresAsZero() {
        animalos__Breed__c breed = new animalos__Breed__c(
                animalos__Type__c = 'Dog',
                Name = 'Test Breed'
        );
        insert breed;

        animalos__Animal__c animal = new animalos__Animal__c(
                animalos__Animal_Name__c = 'Test Animal',
                animalos__Class__c = 'Domestic',
                animalos__Type__c = 'Dog',
                animalos__Age_Group__c = 'Young Adult 6 mths - 1 yr',
                animalos__Date_of_Birth__c = Date.today(),
                animalos__Stage__c = 'Pre-Intake',
                animalos__Status__c = 'Information',
                aos_Is_New__c = false,
                animalos__Primary_Breed__c = breed.Id
        );
        insert animal;

        animalos__Assessment__c assessment = new animalos__Assessment__c(
                animalos__Animal__c = animal.Id,
                animalos__Assessment_Date_Time__c = Datetime.now()
        );
        insert assessment;

        Test.startTest();
        new CalcRollupsAssessmentTotalScore().process(new List<SObject>{ assessment });
        Test.stopTest();

        assessment = [SELECT Id, animalos__Total_Score__c FROM animalos__Assessment__c WHERE Id = :assessment.Id];
        System.assertEquals(0, assessment.animalos__Total_Score__c);
    }
}