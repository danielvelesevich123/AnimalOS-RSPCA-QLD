@isTest
public class CampaignGenerateCRNActionTest {

    @isTest
    private static void test(){
        Account acc = new Account(Name='test');
        insert acc;
        Contact cnt = new Contact(FirstName = 'Test', LastName='test', Email='test@test.test', AccountId = acc.Id);
        insert cnt;
        Campaign campaignVar = new Campaign(Name='test');
        insert campaignVar;
        CampaignMember campaignMemberVar = new CampaignMember(
            ContactId = cnt.Id,
            CampaignId = campaignVar.Id
        );
        insert campaignMemberVar;

        new CampaignGenerateCRNActionSubmitProc().process(new vertic_Request(new Map<String,Object>{'recordId' => campaignVar.Id}));

        System.assertNotEquals(null, campaignVar);

    }
}