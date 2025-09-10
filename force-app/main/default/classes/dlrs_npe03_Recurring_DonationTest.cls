/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_npe03_Recurring_DonationTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_npe03_Recurring_DonationTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new npe03__Recurring_Donation__c());
    }
}