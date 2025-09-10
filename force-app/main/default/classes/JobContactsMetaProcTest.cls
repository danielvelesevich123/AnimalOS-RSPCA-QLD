@IsTest
public class JobContactsMetaProcTest {
    @IsTest static void test(){
        Contact contactVar = new Contact(
                LastName = 'Test Contact'
        );
        insert contactVar;
        animalos__Job__c jobVar = new animalos__Job__c(
                animalos__Subject__c = 'Test Job'
        );
        insert jobVar;
        animalos__Job_Contact__c jobContactVar = new animalos__Job_Contact__c(
                animalos__Contact__c = contactVar.Id,
                animalos__Job__c = jobVar.Id,
                animalos__Contact_Type__c = 'Informant'
        );
        insert jobContactVar;
        vertic_Response response = new JobContactsMetaProc().process(new Map<String, Object>{
                'recordId' => jobVar.Id
        });

        System.assert(response.isValid);
    }
}