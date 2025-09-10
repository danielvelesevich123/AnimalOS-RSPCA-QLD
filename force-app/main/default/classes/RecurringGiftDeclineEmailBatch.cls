public class RecurringGiftDeclineEmailBatch implements Database.Batchable<SObject>, Schedulable{
    private final Set<String> paymentMethods = new Set<String>{
            'EziDebit',
            'Stripe-Offline',
            'Paypal-Offline',
            'Credit Card',
            'ACH/EFT'
    };

    private String recordId;

    public RecurringGiftDeclineEmailBatch(){

    }

    public RecurringGiftDeclineEmailBatch(String recordId){
        this.recordId = recordId;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, npsp__Status__c, npe03__Contact__r.Email FROM npe03__Recurring_Donation__c WHERE npsp__Status__c = \'Active\' AND npsp__PaymentMethod__c IN :paymentMethods AND Id IN (SELECT npe03__Recurring_Donation__c FROM Opportunity WHERE CloseDate = THIS_MONTH AND StageName != \'Closed Won\') AND npe03__Contact__r.Email != null';

        if(String.isNotBlank(this.recordId)){
            query += ' AND Id = \'' + this.recordId + '\' LIMIT 1';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        Map<Id, npe03__Recurring_Donation__c> recurringDonationMap = new Map<Id, npe03__Recurring_Donation__c>((List<npe03__Recurring_Donation__c>) scope);

        List<Opportunity> opportunities = [SELECT Id, npe03__Recurring_Donation__c, npsp__Closed_Lost_Reason__c FROM Opportunity WHERE npe03__Recurring_Donation__c IN :recurringDonationMap.keySet() AND CloseDate = THIS_MONTH AND StageName != 'Closed Won'];

        Map<Id, Opportunity> latestOpportunitiesByRecDonId = new Map<Id, Opportunity>();

        for(Opportunity opportunityVar : opportunities){
            latestOpportunitiesByRecDonId.put(opportunityVar.npe03__Recurring_Donation__c, opportunityVar);
        }

        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

        OrgWideEmailAddress orgWideEmailAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Supporter Care'];

        EmailTemplate emailTemplate = [SELECT Id, Subject FROM EmailTemplate WHERE DeveloperName = 'Recurring_Gift_Declines_Email_Template'];


        for (npe03__Recurring_Donation__c recurringDonationVar : recurringDonationMap.values()){
            Opportunity currentOpp = latestOpportunitiesByRecDonId.get(recurringDonationVar.Id);

            if(currentOpp == null){
                continue;
            }

            if('Refunded'.equals(currentOpp.npsp__Closed_Lost_Reason__c)){
                continue;
            }

            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setTargetObjectId(recurringDonationVar.npe03__Contact__c);
            emailMessage.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
            emailMessage.setTemplateId(emailTemplate.Id);

            emailMessages.add(emailMessage);
        }

        System.debug(emailMessages);

        if(!emailMessages.isEmpty()){
            Messaging.sendEmail(emailMessages);
        }

    }

    public void finish(Database.BatchableContext context) {
    }

    public void execute(SchedulableContext context) {
        Database.executeBatch(new RecurringGiftDeclineEmailBatch(), 1);
    }
}