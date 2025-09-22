@IsTest
public class RetryLogProcTest {

    @IsTest
    static void testRetryProc() {
        animalos__Log__c logVar = new animalos__Log__c(
            animalos__Process__c = 'InvalidProcess',
            animalos__Payload__c = JSON.serialize(new Map<String, Object>{'recordId' => 'testRecordId'}),
            animalos__Type__c = 'Scheduled'
        );
        insert logVar;
        animalos__Log__c retryLogVar = new animalos__Log__c(
                animalos__Process__c = 'RetryLogProc',
                animalos__Type__c = 'Error',
                animalos__Payload__c = JSON.serialize(new Map<String, Object>{'recordId' => logVar.Id})
        );
        insert retryLogVar;

        vertic_Response responseVar = new RetryLogProc().process(new Map<String, Object>{
            'recordId' => retryLogVar.Id
        });

        Assert.isTrue(responseVar.isValid);
        Assert.isTrue([SELECT animalos__Type__c FROM animalos__Log__c WHERE Id = :logVar.Id].animalos__Type__c == 'Error', 'Log should be updated to Error');
        Assert.isTrue([SELECT animalos__Type__c FROM animalos__Log__c WHERE Id = :retryLogVar.Id].animalos__Type__c == 'Success', 'Log should be updated to Success');
    }
}