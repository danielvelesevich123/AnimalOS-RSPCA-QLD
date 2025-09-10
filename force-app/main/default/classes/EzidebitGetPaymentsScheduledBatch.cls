public without sharing class EzidebitGetPaymentsScheduledBatch extends vertic_AbstractProcessor implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {

    private npe03__Recurring_Donation__c recurringDonationVar;
    private Campaign campaignVar;
    private Opportunity existingRetryingOpportunity;
    private List<Opportunity> existingPledgedOpportunities;
    private List<EzidebitStructs.Payment> ezidebitPayments = new List<EzidebitStructs.Payment>();
    private Map<String, SObject> existingPaymentsByEziDebitIds = new Map<String, npe01__OppPayment__c>();

    private static final Map<String, String> OPPORTUNITY_STAGE_NAMES_BY_EZIDEBIT_PAYMENT_STATUSES = new Map<String, String>{
            'Processed' => 'Closed Won',
            'Dishonoured' => 'Retrying',
            'Failed' => 'Closed Lost'
    };

    //PROCESSOR
    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        try {
            this.initData();
            this.syncPayments();
        } catch (Exception e) {
            insert new Vertic_Async_Process__c(
                    Processor__c = '' + EzidebitGetPaymentsScheduledBatch.class,
                    Payload__c = JSON.serializePretty(this.request.getMap()),
                    Description__c = 'Sync failed. Review details.',
                    Details__c = e.getMessage(),
                    Priority__c = 0,
                    Autorun__c = false,
                    Status__c = 'Failed',
                    Recurring_Donation__c = this.request.getString('recordId'),
                    Group_Key__c = this.request.getString('recordId')
            );
        }

        return this.response;
    }

    private void initData() {
        this.recurringDonationVar = (npe03__Recurring_Donation__c) vertic_Utils.arrays.firstOrException([
                SELECT Id,
                        EziDebit_Customer_ID__c,
                        npe03__Recurring_Donation_Campaign__c,
                        npe03__Contact__c, npe03__Contact__r.Name
                FROM npe03__Recurring_Donation__c
                WHERE Id = :this.request.getRequiredString('recordId')
        ],
                'No RD with Id: ' + this.request.getRequiredString('recordId')
        );

        this.existingPaymentsByEziDebitIds = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, EziDebit_Transaction_ID__c, npe01__Opportunity__c, npe01__Opportunity__r.StageName
                FROM npe01__OppPayment__c
                WHERE npe01__Opportunity__r.npe03__Recurring_Donation__c = :this.recurringDonationVar.Id AND npe01__Opportunity__r.StageName != 'Pledged'
        ], npe01__OppPayment__c.EziDebit_Transaction_ID__c);

        Date fromDate = this.request.getISODate('fromDate');
        Date toDate = this.request.getISODate('toDate');

        this.ezidebitPayments = new EzidebitPaymentProcessor(
                payment_ProcessorFactory.getGatewayCredentials('EziDebit')
        ).getPayments(
                'ALL',
                'ALL',
                'SCHEDULED',
                null,
                String.valueOf(fromDate),
                String.valueOf(toDate),
                fromDate != null || toDate != null ? 'PAYMENT' : null,
                this.recurringDonationVar.EziDebit_Customer_ID__c,
                null
        );

        this.campaignVar = (Campaign) vertic_Utils.arrays.firstOrException([
                SELECT Id
                FROM Campaign
                WHERE Id = :this.recurringDonationVar.npe03__Recurring_Donation_Campaign__c
        ], String.isBlank(
                this.recurringDonationVar.npe03__Recurring_Donation_Campaign__c) ?
                'Recurring Donation has no related Campaign' : 'No Campaign with Id: ' + this.recurringDonationVar.npe03__Recurring_Donation_Campaign__c
        );

        this.existingPledgedOpportunities = [
                SELECT Id, CampaignId, Name, CloseDate, (
                        SELECT Id
                        FROM npe01__OppPayment__r
                        WHERE npe01__Paid__c = FALSE
                )
                FROM Opportunity
                WHERE StageName = 'Pledged' AND npe03__Recurring_Donation__c = :this.recurringDonationVar.Id AND CloseDate <= :toDate
                ORDER BY CloseDate ASC
        ];

        this.existingRetryingOpportunity = (Opportunity) vertic_Utils.arrays.firstOrNull([
                SELECT Id, CloseDate, StageName, Name
                FROM Opportunity
                WHERE StageName = 'Retrying' AND npe03__Recurring_Donation__c = :this.recurringDonationVar.Id
        ]);
    }

    private void syncPayments() {
        vertic_UnitOfWork uow = new vertic_UnitOfWork(new List<SObjectType>{
                npe03__Recurring_Donation__c.SObjectType,
                Contact.SObjectType,
                Opportunity.SObjectType,
                npe01__OppPayment__c.SObjectType
        });

        //process payments in reverse order to because EziDebit returns payments in descending order by DebitDate.
        for (Integer i = this.ezidebitPayments.size() - 1; i >= 0; i--) {
            EzidebitStructs.Payment ezidebitPayment = this.ezidebitPayments[i];

            npe01__OppPayment__c existingPayment = (npe01__OppPayment__c) this.existingPaymentsByEziDebitIds.get(ezidebitPayment.PaymentID);
            //skip Pending payments and existing Closed Won/Lost.
            Boolean isPending = 'Pending'.equalsIgnoreCase(ezidebitPayment.PaymentStatus);
            Boolean isClosedWonLost = existingPayment != null && ('Closed Won'.equalsIgnoreCase(existingPayment.npe01__Opportunity__r.StageName) || 'Closed Lost'.equalsIgnoreCase(existingPayment.npe01__Opportunity__r.StageName));

            if (isPending || isClosedWonLost) {
                continue;
            }

            Opportunity opportunityVar = new Opportunity(
                    npsp__Acknowledgment_Status__c = 'Do Not Acknowledge',
                    Amount = ezidebitPayment.ScheduledAmount,
                    CloseDate = ezidebitPayment.DebitDate?.date(),
                    Payment_Method__c = 'EziDebit',
                    npe01__Do_Not_Automatically_Create_Payment__c = true,
                    npsp__Primary_Contact__c = this.recurringDonationVar.npe03__Contact__c,
                    StageName = OPPORTUNITY_STAGE_NAMES_BY_EZIDEBIT_PAYMENT_STATUSES.get(ezidebitPayment.PaymentStatus),
                    CampaignId = this.campaignVar?.Id
            );

            npe01__OppPayment__c paymentVar = new npe01__OppPayment__c(
                    npe01__Payment_Method__c = 'EziDebit',
                    npsp_plus__Status__c = ezidebitPayment.PaymentStatus,
                    npe01__Paid__c = 'Processed'.equalsIgnoreCase(ezidebitPayment.PaymentStatus),
                    EziDebit_Transaction_ID__c = ezidebitPayment.PaymentID,
                    npsp_plus__Failure_Code__c = ezidebitPayment.BankReturnCode,
                    npsp_plus__Error_Message__c = ezidebitPayment.BankFailedReason,
                    npe01__Payment_Date__c = ezidebitPayment.SettlementDate == null ? Date.today() : ezidebitPayment.SettlementDate.date(),
                    npe01__Scheduled_Date__c = ezidebitPayment.DebitDate?.date(),
                    npe01__Payment_Amount__c = ezidebitPayment.ScheduledAmount
            );

            //if payment exists in SF side, then update only Payment
            if (existingPayment != null) {
                paymentVar.Id = existingPayment.Id;
                uow.registerDirty(paymentVar);
                continue;
            }

            //if payment doesn't  exist in SF side, then create new Opp with Payment
            if (existingPayment == null) {
                //https://verticconsulting.atlassian.net/browse/RQJ-167. Retry logic.
                //EziDebit RDs are only Monthly and Yearly. Day of month always = 15.
                //EziDebit processes retry attempts as separate transactions after 3 business days from the original payment date.
                //Number of Attempts = 1.
                //According this business process only one Retrying Opportunity should be created within RD.
                //Retry attempt should be created as separate OppPayment within existing Retrying Opportunity.
                if (this.existingRetryingOpportunity != null && 'Retrying'.equalsIgnoreCase(this.existingRetryingOpportunity.StageName)) {
                    this.existingRetryingOpportunity.StageName = 'Processed'.equalsIgnoreCase(ezidebitPayment.PaymentStatus) ? 'Closed Won' : 'Closed Lost';
                    this.existingRetryingOpportunity.CloseDate = opportunityVar.CloseDate;
                    this.existingRetryingOpportunity.Name = String.format('{0} {1} {2} {3}', new List<String>{
                            this.recurringDonationVar.npe03__Contact__r.Name, '$' + opportunityVar.Amount, 'Donation', opportunityVar.CloseDate.format()
                    });
                    if (String.isNotBlank(this.existingRetryingOpportunity?.Id)) {
                        uow.registerDirty(this.existingRetryingOpportunity);
                    }
                    uow.registerNew(paymentVar, npe01__OppPayment__c.npe01__Opportunity__c, this.existingRetryingOpportunity);
                    continue;
                }

                //get pledged ids;
                Opportunity pledgedOpportunity;
                npe01__OppPayment__c pledgedPayment;

                if (this.existingPledgedOpportunities != null && !this.existingPledgedOpportunities.isEmpty()) {
                    //try to find pledged opp with the same date
                    for (Opportunity pledgedOpp : this.existingPledgedOpportunities) {
                        if (pledgedOpp.CloseDate != null && pledgedOpp.CloseDate.equals(ezidebitPayment.DebitDate.date())) {
                            pledgedOpportunity = pledgedOpp;
                            pledgedPayment = pledgedOpp.npe01__OppPayment__r.isEmpty() ? null : pledgedOpp.npe01__OppPayment__r[0];
                            break;
                        }
                    }
                    //if not found then use the earliest Pledged opp.
                    if (pledgedOpportunity == null) {
                        pledgedOpportunity = this.existingPledgedOpportunities.remove(0);
                        pledgedPayment = pledgedOpportunity.npe01__OppPayment__r.isEmpty() ? null : pledgedOpportunity.npe01__OppPayment__r[0];
                    }
                }

                opportunityVar.Id = pledgedOpportunity?.Id;
                opportunityVar.CampaignId = String.isBlank(pledgedOpportunity?.CampaignId) ? this.campaignVar?.Id : pledgedOpportunity?.CampaignId;
                paymentVar.Id = pledgedPayment?.Id;


                //new Opportunities should have name populated. Existing pledged opp name should be updated.
                if (String.isBlank(opportunityVar.Id)) {
                    opportunityVar.Name = 'EziDebit Recurring Opp';//will be automatically updated by npsp
                    uow.registerRelationship(opportunityVar, Opportunity.npe03__Recurring_Donation__c, this.recurringDonationVar);
                } else {
                    //update name of pledged opp. Potentially it has incorrect date.
                    opportunityVar.Name = String.format('{0} {1} {2} {3}', new List<String>{
                            this.recurringDonationVar.npe03__Contact__r.Name, '$' + opportunityVar.Amount, 'Donation', opportunityVar.CloseDate.format()
                    });
                }

                uow.registerUpsert(opportunityVar);
                uow.registerUpsert(paymentVar);

                if (String.isBlank(paymentVar.Id)) {
                    uow.registerRelationship(paymentVar, npe01__OppPayment__c.npe01__Opportunity__c, opportunityVar);
                }

                if ('Retrying'.equalsIgnoreCase(opportunityVar.StageName)) {
                    this.existingRetryingOpportunity = opportunityVar;
                }
            }

            //https://verticconsulting.atlassian.net/browse/RQJ-66, Failed payments because of incorrect bank details specific logic
            if ('5'.equalsIgnoreCase(ezidebitPayment.BankReturnCode) && ('Failed'.equalsIgnoreCase(ezidebitPayment.PaymentStatus) || 'Dishonoured'.equalsIgnoreCase(ezidebitPayment.PaymentStatus))) {
                opportunityVar.StageName = 'Closed Lost';
                this.recurringDonationVar.npsp__Status__c = 'Lapsed';
                uow.registerDirty(this.recurringDonationVar);
            }
        }

        uow.commitWork();
    }

    //SCHEDULABLE
    public void execute(SchedulableContext context) {
        if (!'true'.equalsIgnoreCase(vertic_SettingService.getValue('EZIDEBIT_PROCESSING_DISABLED'))) {
            Database.executeBatch(new EzidebitGetPaymentsScheduledBatch(), 1);
        }
    }

    //BATCHABLE
    private Integer limitVar;

    public EzidebitGetPaymentsScheduledBatch() {
    }

    public EzidebitGetPaymentsScheduledBatch(Integer limitVar) {
        this.limitVar = limitVar;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(npe03__Recurring_Donation__c.SObjectType)
                .selectFields(new Set<String>{
                        'Id'
                })
                .setCondition('EziDebit_Customer_ID__c != NULL AND npsp__Status__c = \'Active\' AND npsp_plus__Stripe_Subscription__c = NULL AND npsp__PaymentMethod__c = \'EziDebit\'')
                .setLimit(this.limitVar);

        return Database.getQueryLocator(queryFactory.toSOQL());
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        String recurringDonationId = scope[0].Id;

        Opportunity mostRecentOpportunity = (Opportunity) vertic_Utils.arrays.firstOrNull([
                SELECT CloseDate
                FROM Opportunity
                WHERE npe03__Recurring_Donation__c = :recurringDonationId AND
                StageName != 'Pledged'
                ORDER BY CloseDate DESC
                LIMIT 1
        ]);

        new EzidebitGetPaymentsScheduledBatch().process(
                new vertic_Request(new Map<String, Object>{
                        'recordId' => recurringDonationId,
                        'fromDate' => mostRecentOpportunity.CloseDate.addDays(1),
                        'toDate' => Date.today()
                }));
    }

    public void finish(Database.BatchableContext context) {
    }

}