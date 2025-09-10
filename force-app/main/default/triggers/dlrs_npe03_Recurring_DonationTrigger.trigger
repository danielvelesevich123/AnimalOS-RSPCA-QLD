/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_npe03_Recurring_DonationTrigger on npe03__Recurring_Donation__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(npe03__Recurring_Donation__c.SObjectType);
}