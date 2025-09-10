public inherited sharing class DonateSubmitProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }


    private void doSubmit() {
        Decimal amount = this.request.getDecimal('amount');
        String paymentMethodId = this.request.getString('paymentMethodId');
        String campaignName = this.request.getString('campaignName');
        String interval = 'month';
        Integer frequency = 1;

        String priceId = Test.isRunningTest() ? '123' : new npsp_plus.Stripe().prices.create(
            amount, 'AUD', interval, frequency,
            new Map<String, String>{
                'product_data[name]' => 'Donation'
            }
        ).getRequiredString('id');


        npsp_plus.vertic_DTO createCustomerResponse;
        if (Test.isRunningTest()) {
            createCustomerResponse = new npsp_plus.vertic_DTO(new Map<String, Object>{ 'id' => 'test' });
        } else {
            createCustomerResponse = new npsp_plus.Stripe().customers.send(
                new Map<String, String>{
                    'payment_method' => paymentMethodId,
                    'name' => this.request.getString('addressData.name'),
                    'email' => this.request.getString('email'),
                    'address[city]' => this.request.getString('addressData.address.city'),
                    'address[country]' => this.request.getString('addressData.address.country'),
                    'address[line1]' => this.request.getString('addressData.address.line1'),
                    'address[line2]' => this.request.getString('addressData.address.line2'),
                    'address[postal_code]' => this.request.getString('addressData.address.postal_code'),
                    'address[state]' => this.request.getString('addressData.address.state')
                }
            );
        }


        Map<String, String> subscriptionOptions = new Map<String, String>{
            'customer' => createCustomerResponse.getString('id'),
            'items[0][price]' => priceId,
            'proration_behavior' => 'none',
            'off_session' => 'true',
            'default_payment_method' => paymentMethodId,
            'metadata[npsp_plus_contact]' => getContactMetadata(this.request)
        };

        if (String.isNotBlank(campaignName)) {
            subscriptionOptions.put('metadata[npsp_plus_campaign]', JSON.serialize(new Map<String, Object>{'Name' => campaignName}));
        }

        Date trialDateEnd = getTrialDate();
        subscriptionOptions.put('trial_end', '' + toStripeTimestamp(trialDateEnd));

        String subscriptionId = Test.isRunningTest() ? '123': new npsp_plus.Stripe().subscriptions.create(subscriptionOptions).getRequiredString('id');
    }

    public static String getContactMetadata(vertic_DTO dto) {

        String contactEmail = dto.getString('email');

        Map<String, String> contactDetails = new Map<String, String>();
        contactDetails.put('FirstName', dto.getString('addressData.firstName'));
        contactDetails.put('LastName', dto.getString('addressData.lastName'));

        if (String.isNotBlank(contactEmail)) {
            contactDetails.put('Email', contactEmail);
        }

        contactDetails.put('MailingStreet', dto.getString('addressData.address.line1'));
        contactDetails.put('MailingCity', dto.getString('addressData.address.city'));
        contactDetails.put('MailingState', dto.getString('addressData.address.state'));
        contactDetails.put('MailingPostalCode', dto.getString('addressData.address.postal_code'));
        contactDetails.put('MailingCountry', dto.getString('addressData.address.country'));

        return JSON.serialize(contactDetails);
    }

    private static Date getTrialDate() {
        Date result;
        Integer currentDay = Date.today().day();
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();
        Integer nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
        Integer nextYear = currentMonth == 12 ? currentYear + 1 : currentYear;

        if (currentDay >= 1 && currentDay < 14) {
            result = Date.newInstance(currentYear, currentMonth, 15);
        } else {
            if (currentDay >= 14) {
                result = Date.newInstance(nextYear, nextMonth, 15);
            }
        }

        return result;
    }

    public static Long toStripeTimestamp(Date dateVar) {
        Time trialEndTime = vertic_Utils.dates.timeStringToTime('11:00:00');

        return npsp_plus.Stripe.dateTimeToStripeTimestamp(Datetime.newInstance(dateVar, trialEndTime));
    }
}