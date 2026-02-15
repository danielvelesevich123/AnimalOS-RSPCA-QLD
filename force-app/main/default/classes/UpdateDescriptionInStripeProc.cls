public without sharing class UpdateDescriptionInStripeProc extends vertic_AbstractProcessor implements Database.Batchable<SObject>, Database.Stateful {
    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String gatewayPaymentId = this.request.getRequiredString('gatewayPaymentId');
        String stripeDescription = this.request.getRequiredString('stripeDescription');

        Map<String, String> requestData = new Map<String, String>();

        if (String.isNotBlank(stripeDescription)) {
            requestData.put('description', stripeDescription);
            requestData.put('metadata[npsp_plus_description]', stripeDescription);
        }

        if (!requestData.isEmpty()) {
            if(gatewayPaymentId.startsWith('pi_')){
                npsp_plus.vertic_DTO response = new npsp_plus.Stripe().paymentIntents.doUpdate(gatewayPaymentId, requestData);
            } else if (gatewayPaymentId.startsWith('ch_')) {
                npsp_plus.vertic_DTO response = new npsp_plus.Stripe().getGenericAPI('charges').doUpdate(gatewayPaymentId, requestData);
            }
        }
    }


    private Set<Id> vapIds = new Set<Id>();
    private Datetime createdAfter;
    public enum EntityType {
        PAYMENT_INTENT,
        CHARGE
    }
    private EntityType entityTypeVar = EntityType.PAYMENT_INTENT;

    public UpdateDescriptionInStripeProc(){
        this(EntityType.PAYMENT_INTENT, null);
    }

    public UpdateDescriptionInStripeProc(EntityType entityTypeVar, Datetime createdAfter){
        this.entityTypeVar = entityTypeVar;
        this.createdAfter = createdAfter;
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        String soql;
        if(this.entityTypeVar == EntityType.PAYMENT_INTENT){
            soql = 'SELECT Id, npsp__Gateway_Payment_ID__c, npe01__Opportunity__r.Name, npe01__Opportunity__r.Campaign__c FROM npe01__OppPayment__c WHERE npsp__Gateway_Payment_ID__c != NULL AND npsp__Gateway_Payment_ID__c LIKE \'pi_%\'';
        } else if(this.entityTypeVar == EntityType.CHARGE){
            soql = 'SELECT Id, Gateway_ID__c, Name, Campaign__c FROM Opportunity WHERE Gateway_ID__c != NULL AND Gateway_ID__c LIKE \'ch_%\'';
        } else {
            throw new vertic_Structs.ProcessException('Invalid entity type');
        }
        if(this.createdAfter != null){
            soql += ' AND CreatedDate >= :createdAfter';
        }
        return Database.getQueryLocator(soql);
    }

    public void execute(Database.BatchableContext param1, List<Object> records) {
        vertic_AsyncProcess vapProcessVar = new vertic_AsyncProcess();

        if (this.entityTypeVar == EntityType.PAYMENT_INTENT) {
            for (npe01__OppPayment__c payment : (List<npe01__OppPayment__c>)records) {
                aos_Async_Process__c vap = createVap(
                    payment.npsp__Gateway_Payment_ID__c,
                    payment.npe01__Opportunity__r.Campaign__c,
                    payment.npe01__Opportunity__r.Name
                );
                vapProcessVar.add(vap);
            }
        } else if (this.entityTypeVar == EntityType.CHARGE) {
            for (Opportunity oppVar : (List<Opportunity>)records) {
                aos_Async_Process__c vap = createVap(
                    oppVar.Gateway_ID__c,
                    oppVar.Campaign__c,
                    oppVar.Name
                );
                vapProcessVar.add(vap);
            }
        } else {
            throw new vertic_Structs.ProcessException('Invalid entity type');
        }

        List<aos_Async_Process__c> vaps = vapProcessVar.enqueue();

        this.vapIds.addAll(new Map<Id, SObject>(vaps).keySet());
    }

    public aos_Async_Process__c createVap(String gatewayId, String campaign, String oppName) {
        return new aos_Async_Process__c(
                aos_Processor__c = '' + UpdateDescriptionInStripeProc.class,
                aos_Payload__c = JSON.serialize(new Map<String, Object>{
                'gatewayPaymentId' => gatewayId,
                'stripeDescription' => vertic_Utils.strings.joinNonBlank(new List<String>{campaign, oppName}, ' ')
            }),
                aos_Is_Queueable__c = true,
                aos_Autorun__c = false
        );
    }

    public void finish(Database.BatchableContext param1) {
        vertic_AsyncProcessBatch.run(new List<Id>(this.vapIds));
    }

    public static Id run(EntityType entityTypeVar, Datetime createdAfter, Integer scopeSize){
        return Database.executeBatch(new UpdateDescriptionInStripeProc(entityTypeVar, createdAfter), scopeSize);
    }
}

//    Launch script - conditions to retrieve Payments???
//
//
//List<npe01__OppPayment__c> payments = [SELECT Id, npsp__Gateway_Payment_ID__c, npe01__Opportunity__r.Name, npe01__Opportunity__r.Campaign__c FROM npe01__OppPayment__c WHERE npsp__Gateway_Payment_ID__c != NULL AND npsp__Gateway_Payment_ID__c LIKE 'pi_%'];
//
//vertic_AsyncProcess vapProcessVar = new vertic_AsyncProcess();
//
//System.debug(payments.size());
//
//for(npe01__OppPayment__c payment : payments){
//    String stripeDescription;
//
//    if(payment.npe01__Opportunity__r.Campaign__c == null){
//        stripeDescription = payment.npe01__Opportunity__r.Name;
//    } else{
//        stripeDescription = payment.npe01__Opportunity__r.Campaign__c + ' ' + payment.npe01__Opportunity__r.Name;
//    }
//
//    vapProcessVar.add(new aos_Async_Process__c(
//        Processor__c = '' + UpdateDescriptionInStripeProc.class,
//        Payload__c = JSON.serialize(new Map<String, Object>{
//            'gatewayPaymentId' => payment.npsp__Gateway_Payment_ID__c,
//            'stripeDescription' => stripeDescription
//        }),
//        Is_Queueable__c = true
//    ));
//}
//
//vapProcessVar.enqueueAndRun();