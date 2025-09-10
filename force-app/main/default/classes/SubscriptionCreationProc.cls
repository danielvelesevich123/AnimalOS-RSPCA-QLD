global without sharing class SubscriptionCreationProc extends npsp_plus.vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    global override npsp_plus.vertic_Response process(npsp_plus.vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private static Map<String, String> INTERVAL_TO_INSTALLMENT_PERIOD_MAPPING = new Map<String, String>{
        'Daily' => 'day',
        'Weekly' => 'week',
        'Monthly' => 'month',
        'Yearly' => 'year',
        'Annually' => 'year'
    };

    private void doSubmit() {

        String rdId = this.request.getRequiredString('recordId');

        npe03__Recurring_Donation__c recurringDonationVar = (npe03__Recurring_Donation__c) npsp_plus.vertic_Utils.arrays.firstOrException(
            [
                SELECT Id, Name, npe03__Contact__c, npsp_plus__Stripe_Subscription__c, npe03__Next_Payment_Date__c,
                    npsp__Status__c, npe03__Amount__c, npsp__StartDate__c, npe03__Date_Established__c, npsp__EndDate__c,
                    npe03__Installment_Period__c, npsp__InstallmentFrequency__c, LastModifiedDate,
                    npe03__Recurring_Donation_Campaign__c, npe03__Recurring_Donation_Campaign__r.npsp_plus__Stripe_Account_Id__c,
                    Stripe_Initial_Payment_Date__c, Stripe_Customer_Id__c
                FROM npe03__Recurring_Donation__c
                WHERE Id = :rdId
            ],
            'No npe03__Recurring_Donation__c with Stripe_Customer_Id__c: ' + rdId
        );

        if (String.isNotBlank(recurringDonationVar.npsp_plus__Stripe_Subscription__c)) {
            throw new npsp_plus.vertic_Structs.ProcessException('RD is already synced with Stripe. RD Id: ' + recurringDonationVar.Id);
        }

        if (String.isBlank(recurringDonationVar.Stripe_Customer_Id__c)) {
            throw new npsp_plus.vertic_Structs.ProcessException('No Stripe_Customer_Id__c. RD Id: ' + recurringDonationVar.Id);
        }


        Boolean isActiveStatus = 'Active'.equalsIgnoreCase(recurringDonationVar.npsp__Status__c);
        if (isActiveStatus != true) {
            throw new npsp_plus.vertic_Structs.ProcessException('RD is not Active. RD Id: ' + recurringDonationVar.Id);
        }

        if (recurringDonationVar.Stripe_Initial_Payment_Date__c == null || recurringDonationVar.Stripe_Initial_Payment_Date__c <= Date.today()) {
            throw new npsp_plus.vertic_Structs.ProcessException('Stripe_Initial_Payment_Date__c should be in the future. RD Id: ' + recurringDonationVar.Id);
        }

//        if (recurringDonationVar.Is_Create_Subscription__c != true && Test.isRunningTest() != true) {
//            throw new vertic_Structs.ProcessException('RD is not meet Is_Create_Subscription__c formula');
//        }

//        String existingSubscriptionId = new npsp_plus.Stripe().subscriptions.retrieveAll(new Map<String, String>{
//            'customer' => stripeCustomerId
//        }).getString('data.[0].id');
//        if(String.isNotBlank(existingSubscriptionId)){
//            throw new npsp_plus.vertic_Structs.ProcessException('Stripe Customer already has a subscription with Id: ' + existingSubscriptionId);
//        }

//        Boolean isFutureEffectiveDate = recurringDonationVar.npsp__StartDate__c > Date.today();

//        if(this.request.getBoolean('checkExistingSubscriptions') == true){
//            String existingSubscriptionId = new npsp_plus.Stripe().subscriptions.retrieveAll(new Map<String, String>{
//                'customer' => stripeCustomerId
//            }).getString('data.[0].id');
//            if (String.isNotBlank(existingSubscriptionId)) {
//                throw new npsp_plus.vertic_Structs.ProcessException('Stripe Customer already has a subscription with Id: ' + existingSubscriptionId);
//            }
//        }

        String interval = INTERVAL_TO_INSTALLMENT_PERIOD_MAPPING.get(recurringDonationVar.npe03__Installment_Period__c);
        Integer frequency = npsp_plus.vertic_Utils.objects.defaultIfNull(recurringDonationVar.npsp__InstallmentFrequency__c, 1).intValue();

        if ('Bi-Monthly'.equalsIgnoreCase(recurringDonationVar.npe03__Installment_Period__c)) {
            interval = 'month';
            frequency = 2;
        } else if ('Quarterly'.equalsIgnoreCase(recurringDonationVar.npe03__Installment_Period__c)) {
            interval = 'month';
            frequency = 3;
        } else if ('Half Yearly'.equalsIgnoreCase(recurringDonationVar.npe03__Installment_Period__c)) {
            interval = 'month';
            frequency = 6;
        }

        String priceId = Test.isRunningTest() ? '123' : new npsp_plus.Stripe().prices.create(
            recurringDonationVar.npe03__Amount__c,
            'AUD',
            interval,
            frequency,
            new Map<String, String>{
                'product_data[name]' => recurringDonationVar.Name
            }
        ).getRequiredString('id');


        String subscriptionId = this.createStripeSubscription(recurringDonationVar.Stripe_Customer_Id__c, priceId, recurringDonationVar);

//        fflib_SObjectDomain.getTriggerEvent(RecurringDonationDomain.class).disableAll();

        try {
            update new npe03__Recurring_Donation__c(
                Id = recurringDonationVar.Id,
                npsp_plus__Stripe_Subscription__c = subscriptionId
            );

            String stripeModeForIntegrationItem = 'Live';
            if(String.isNotBlank(stripeModeForIntegrationItem)){
                insert new npsp_plus__Integration_Item__c(
                    npsp_plus__Contact__c = recurringDonationVar.npe03__Contact__c,
                    npsp_plus__Stripe_Customer_Id__c = recurringDonationVar.Stripe_Customer_Id__c,
                    npsp_plus__Stripe_Mode__c = stripeModeForIntegrationItem
                );
            }
        } catch (Exception e) {
            throw new npsp_plus.vertic_Structs.ProcessException(JSON.serialize(new Map<String, Object>{
                'rdId' => recurringDonationVar.Id,
                'subscriptionId' => subscriptionId,
                'error' => e.getMessage()
            }));
        }

        this.response
            .put('rdId', recurringDonationVar.Id)
            .put('subscriptionId', subscriptionId);
    }

    private String createStripeSubscription(String stripeCustomerId, String priceId, npe03__Recurring_Donation__c recurringDonationVar) {
        Map<String, String> subscriptionOptions = new Map<String, String>{
            'customer' => stripeCustomerId,
            'items[0][price]' => priceId,
            'proration_behavior' => 'none',
            'off_session' => 'true',
            'metadata[payload]' => JSON.serialize(new Map<String, Object>{
                'recurringDonationId' => recurringDonationVar.Id,
                'migration' => true
            })
        };

//        if (recurringDonationVar.npsp__EndDate__c != null) {
//            subscriptionOptions.put('cancel_at', '' + String.valueOf(npsp_plus.Stripe.dateToStripeTimestamp(recurringDonationVar.npsp__EndDate__c)));
//        }

        //Datetime.now().addDays(10).format('yyyy-MM-dd')
        String SUBSCRIPTION_TRIAL_DATEStr = npsp_plus.vertic_SettingService.getValue('SUBSCRIPTION_TRIAL_DATE', '2021-02-15');
        Date SUBSCRIPTION_TRIAL_DATE = Date.valueOf(SUBSCRIPTION_TRIAL_DATEStr);

        if (recurringDonationVar.Stripe_Initial_Payment_Date__c != null) {
            SUBSCRIPTION_TRIAL_DATE = recurringDonationVar.Stripe_Initial_Payment_Date__c;
        }

        if(SUBSCRIPTION_TRIAL_DATE == null){
            throw new npsp_plus.vertic_Structs.ValidationException('No trial');
        }

//        subscriptionOptions.put('trial_end', '' + npsp_plus.Stripe.dateToStripeTimestamp(SUBSCRIPTION_TRIAL_DATE));
        subscriptionOptions.put('trial_end', '' + toStripeTimestamp(SUBSCRIPTION_TRIAL_DATE));

        // Backdating and setting the billing cycle anchor: https://stripe.com/docs/billing/subscriptions/backdating#backdating-billing-cycle
        if (recurringDonationVar.npe03__Date_Established__c != null && recurringDonationVar.npe03__Date_Established__c < Date.today()) {
//            subscriptionOptions.put('backdate_start_date', '' + npsp_plus.Stripe.dateToStripeTimestamp(recurringDonationVar.npe03__Date_Established__c));
            subscriptionOptions.put('backdate_start_date', '' + toStripeTimestamp(recurringDonationVar.npe03__Date_Established__c));
        }

        String stripeAccountId = recurringDonationVar?.npe03__Recurring_Donation_Campaign__r?.npsp_plus__Stripe_Account_Id__c;
        if (String.isNotBlank(stripeAccountId)) {
            subscriptionOptions.put('transfer_data[destination]', stripeAccountId);
        }

        System.debug(subscriptionOptions);

        try {

            // Create and charge today.
            String subscriptionId = Test.isRunningTest() ? '123' : new npsp_plus.Stripe().subscriptions.create(
                subscriptionOptions
            ).getRequiredString('id');

            return subscriptionId;

        } catch (npsp_plus.Stripe.StripeException ex) {
            throw new npsp_plus.vertic_Structs.ProcessException('Stripe: ' + ex.response.getRequiredString('error.message'));
        }

    }

    public static Long toStripeTimestamp(Date dateVar) {
//        Datetime dt = Datetime.newInstance(dateVar, Time.newInstance(1, 0, 0, 0));

        Time trialEndTime = vertic_Utils.dates.timeStringToTime('11:00:00');
        return npsp_plus.Stripe.dateTimeToStripeTimestamp(Datetime.newInstance(dateVar, trialEndTime));

//        System.TimeZone myTz = UserInfo.getTimeZone();
//        Integer millisecondOffsetGmt = myTz.getOffset(dt);
//
//        Long ts = (dt.getTime() + millisecondOffsetGmt) / 1000;
//        return ts;
    }


}