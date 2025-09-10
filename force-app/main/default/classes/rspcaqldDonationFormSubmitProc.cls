public inherited sharing class rspcaqldDonationFormSubmitProc extends vertic_AbstractProcessor {
    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String type = this.request.getString('type');
        if (type == 'Monthly') {
            this.doSubmitMonthly();
        } else {
            this.doSubmitOnce();
        }
    }

    private void doSubmitMonthly() {
        Decimal amount = this.request.getDecimal('amount');
        String paymentMethodId = this.request.getString('paymentMethodId');
        String campaignName = this.request.getString('campaignName');
        String organisationName = this.request.getString('contact.organisation');
        String comments = this.request.getString('comments');
        Boolean keepUpdated = this.request.getBoolean('keepUpdated');
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
                    'name' => String.format('{0} {1}', new List<String>{this.request.getString('contact.firstName'), this.request.getString('contact.lastName')}),
                    'email' => this.request.getString('contact.email'),
                    'phone' => this.request.getString('contact.phone'),
                    'address[city]' => this.request.getString('contact.city'),
                    'address[country]' => this.request.getString('contact.country'),
                    'address[line1]' => this.request.getString('contact.street'),
                    'address[postal_code]' => this.request.getString('contact.postalCode'),
                    'address[state]' => this.request.getString('contact.state')
                }
            );
        }

        Map<String, String> subscriptionOptions = new Map<String, String>{
            'customer' => createCustomerResponse.getString('id'),
            'items[0][price]' => priceId,
            'proration_behavior' => 'none',
            'off_session' => 'true',
            'default_payment_method' => paymentMethodId,
            'metadata[npsp_plus_contact]' => getContactMetadata(this.request),
            'metadata[npsp_plus_recurring_donation]' => JSON.serialize(new Map<String, Object>{'Portal_Donation__c' => true, 'Portal_Comment__c' => comments, 'Portal_Keep_Updated__c' => keepUpdated})
        };

        if (String.isNotBlank(campaignName)) {
            subscriptionOptions.put('metadata[npsp_plus_campaign]', JSON.serialize(new Map<String, Object>{'Name' => campaignName}));
        }

        if (String.isNotBlank(organisationName)) {
            subscriptionOptions.put('metadata[npsp_plus_organisation]', JSON.serialize(new Map<String, Object>{'Name' => organisationName}));
        }

        Date trialDateEnd = getTrialDate();
        subscriptionOptions.put('trial_end', '' + toStripeTimestamp(trialDateEnd));

        String subscriptionId = Test.isRunningTest() ? '123': new npsp_plus.Stripe().subscriptions.create(subscriptionOptions).getRequiredString('id');
    }

    private void doSubmitOnce() {
        String campaignName = this.request.getString('campaignName');
        String organisationName = this.request.getString('contact.organisation');
        String comments = this.request.getString('comments');
        Boolean keepUpdated = this.request.getBoolean('keepUpdated');

        npsp_plus.vertic_DTO createCustomerResponse;
        if (Test.isRunningTest()) {
            createCustomerResponse = new npsp_plus.vertic_DTO(new Map<String, Object>{ 'id' => 'test' });
        } else {
            createCustomerResponse = new npsp_plus.Stripe().customers.send(
                new Map<String, String>{
                    'name' => String.format('{0} {1}', new List<String>{this.request.getString('contact.firstName'), this.request.getString('contact.lastName')}),
                    'email' => this.request.getString('contact.email'),
                    'phone' => this.request.getString('contact.phone'),
                    'address[city]' => this.request.getString('contact.city'),
                    'address[country]' => this.request.getString('contact.country'),
                    'address[line1]' => this.request.getString('contact.street'),
                    'address[postal_code]' => this.request.getString('contact.postalCode'),
                    'address[state]' => this.request.getString('contact.state')
                }
            );
        }

        Map<String, String> requestData = new Map<String, String>{
            'customer' => createCustomerResponse.getString('id'),
            'amount' => '' + npsp_plus.Stripe.formatAmount(this.request.getDecimal('amount')),
            'metadata[npsp_plus_contact]' => getContactMetadata(this.request),
            'metadata[npsp_plus_donation]' => JSON.serialize(new Map<String, Object>{'npsp__Acknowledgment_Status__c' => 'Email Acknowledgment Now', 'Portal_Donation__c' => true, 'Portal_Comment__c' => comments, 'Portal_Keep_Updated__c' => keepUpdated})
        };

        if (String.isNotBlank(campaignName)) {
            requestData.put('metadata[npsp_plus_campaign]', JSON.serialize(new Map<String, Object>{'Name' => campaignName}));
        }
        if (String.isNotBlank(organisationName)) {
            requestData.put('metadata[npsp_plus_organisation]', JSON.serialize(new Map<String, Object>{'Name' => organisationName}));
        }

        npsp_plus.vertic_DTO intentDTO;
        if (Test.isRunningTest()) {
            intentDTO = new npsp_plus.vertic_DTO(new Map<String, Object>{
                'intent' => this.request.getRequiredString('intentId'),
                'client_secret' => 'testKey'
            });
        } else {
            intentDTO = new npsp_plus.Stripe().getGenericAPI('payment_intents').doUpdate(this.request.getRequiredString('intentId'), requestData);
        }

        this.response.put('intent', intentDTO.getMap());
        this.response.put('clientSecret', intentDTO.getRequiredString('client_secret'));
    }

    public static String getContactMetadata(vertic_DTO dto) {
        Map<String, String> contactDetails = new Map<String, String>();
        contactDetails.put('FirstName', dto.getString('contact.firstName'));
        contactDetails.put('LastName', dto.getString('contact.lastName'));
        contactDetails.put('npe01__HomeEmail__c', dto.getString('contact.email'));
        contactDetails.put('MailingStreet', dto.getString('contact.street'));
        contactDetails.put('MailingCity', dto.getString('contact.city'));
        contactDetails.put('MailingState', dto.getString('contact.state'));
        contactDetails.put('MailingPostalCode', dto.getString('contact.postalCode'));
        contactDetails.put('MailingCountry', dto.getString('contact.country'));

        String phone = dto.getString('contact.phone');
        contactDetails.put(phone.startsWith('04') ? 'MobilePhone' : 'HomePhone', phone);
        contactDetails.put('npe01__PreferredPhone__c', phone.startsWith('04') ? 'Mobile' : 'Home');

        return JSON.serialize(contactDetails);
    }

    private static Date getTrialDate() {
        Date result;
        Integer currentDay = Date.today().day();
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();
        Integer nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
        Integer nextYear = currentMonth == 12 ? currentYear + 1 : currentYear;

        if (currentDay >= 1 && currentDay < 13) {
            result = Date.newInstance(currentYear, currentMonth, 15);
        } else {
            if (currentDay >= 13) {
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