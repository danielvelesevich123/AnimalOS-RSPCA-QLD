public without sharing class EmailMessageDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {

    public EmailMessageDomain(List<Event> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new EmailMessageDomain(sObjectList);
        }
    }

    public override void onBeforeInsert() {
        this.createOpportunityRelationship();
    }

    public override void onAfterInsert() {
        // this.createProgramActivityRelationship(new Map<Id, SObject>());
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
//        this.createProgramActivityRelationship(existingRecords);
    }

//    private void createProgramActivityRelationship(Map<Id, SObject> oldEmails) {
//
//        Map<String, Map<String, SObject>> emailsByProgramName = new Map<String, Map<String, SObject>>();
//        Set<String> emailMessageIds = new Set<String>();
//
//        for (SObject emailItem : Records) {
//
//            ProgramActivityRelationshipService.setEmailActivityMap(
//                emailItem
//                , oldEmails.get((Id) emailItem.get('Id'))
//                , emailsByProgramName
//                , emailMessageIds
//            );
//        }
//
//        if (emailsByProgramName.isEmpty()) return;
//
//        ProgramActivityRelationshipService.createEmailProgramActivityRelationship(emailsByProgramName, emailMessageIds);
//    }

    private void createOpportunityRelationship(){
        for (EmailMessage emailItem : (List<EmailMessage>) Records) {
            if(emailItem.RelatedToId != null && 'Opportunity'.equals(emailItem.RelatedToId.getSobjectType().toString())){
                emailItem.Opportunity__c = emailItem.RelatedToId;
            }
        }

//        Set<Id> recurringDonationsIds = new Set<Id>();
//
//        for (EmailMessage emailItem : (List<EmailMessage>) Records) {
//            if(emailItem.RelatedToId != null){
//                recurringDonationsIds.add(emailItem.RelatedToId);
//            }
//        }
//
//        List<Opportunity> opportunities = [SELECT Id, npe03__Recurring_Donation__c, npsp__Closed_Lost_Reason__c FROM Opportunity WHERE npe03__Recurring_Donation__c IN :recurringDonationsIds AND CloseDate = THIS_MONTH AND StageName != 'Closed Won'];
//
//        for (EmailMessage emailItem : (List<EmailMessage>) Records) {
//            for(Opportunity opportunityVar : opportunities){
//                if(emailItem.RelatedToId.equals(opportunityVar.npe03__Recurring_Donation__c)){
//                    emailItem.Opportunity__c = opportunityVar.Id;
//                }
//            }
//        }
    }
}