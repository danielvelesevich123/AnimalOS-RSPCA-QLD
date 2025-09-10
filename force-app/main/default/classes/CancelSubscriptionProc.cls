public with sharing class CancelSubscriptionProc extends vertic_AbstractProcessor{
    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        doSubmit();

        return this.response;
    }

//    private vertic_UnitOfWork uow = new vertic_UnitOfWork(new List<SObjectType>{
//            npe03__Recurring_Donation__c.SObjectType
//    });

    private void doSubmit() {
        npsp_plus.vertic_DTO response = new npsp_plus.Stripe().subscriptions.cancel(
                 this.request.getString('subscriptionId')
        );
    }
}

//    Set<Id> subscriptionIds = new Set<Id>{
//            'someSubId'
//    };
//
//    for (Id subscriptionId : subscriptionIds){
//        insert new Vertic_Async_Process__c(
//                Processor__c = '' + CancelSubscriptionProc.class,
//                Payload__c = JSON.serializePretty(new Map<String, Object>{
//                        'subscriptionId' => subscriptionId
//                }),
//                Is_Queueable__c = true
//        );
//    }