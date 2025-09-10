@isTest
public class EzidebitTest {
    @isTest
    static void testCRNBatch() {

        EzidebitPaymentProcessor.GetBPayCRNResponse_element element = new EzidebitPaymentProcessor.GetBPayCRNResponse_element();

        element.GetBPayCRNResult = new EzidebitPaymentProcessor.EziResponseOfDataTHgMB7oL();
        element.GetBPayCRNResult.Error = 0;
        element.GetBPayCRNResult.Data = new EzidebitPaymentProcessor.Data();
        element.GetBPayCRNResult.Data.BPayCRN = 'test';

        MockWebServiceResponseGenerator generator = new MockWebServiceResponseGenerator(element);

        Test.setMock(WebServiceMock.class, generator);

        Test.startTest();

        EzidebitStructs.BPayCRN bPayCRN = new EzidebitPaymentProcessor(payment_ProcessorFactory.getGatewayCredentials('EziDebit')).getCRN(
            'test', 'Vertic'
        );

        Test.stopTest();

        System.assertEquals('test', bPayCRN.BPayCRN);
    }

    @isTest
    static void testGetPayments() {

        EzidebitPaymentProcessor.GetPaymentsResponse_element element = new EzidebitPaymentProcessor.GetPaymentsResponse_element();

        element.GetPaymentsResult = new EzidebitPaymentProcessor.EziResponseOfArrayOfPaymentTHgMB7oL();
        element.GetPaymentsResult.Data = new EzidebitPaymentProcessor.ArrayOfPayment();
        element.GetPaymentsResult.Error = 0;

        EzidebitPaymentProcessor.Payment payment = new EzidebitPaymentProcessor.Payment();
        payment.PaymentAmount = 10;

        element.GetPaymentsResult.Data.Payment = new List<EzidebitPaymentProcessor.Payment>{payment};

        MockWebServiceResponseGenerator generator = new MockWebServiceResponseGenerator(element);

        Test.setMock(WebServiceMock.class, generator);

        Test.startTest();

        List<EzidebitStructs.Payment> payments = new EzidebitPaymentProcessor(payment_ProcessorFactory.getGatewayCredentials('EziDebit')).getPayments(
            'SUCCESSFUL',
            'ALL',
            'BPAY',
            'test',
            null,
            String.valueOf(Date.today()),
            'PAYMENT',
            null,
            null
        );

        Test.stopTest();

        System.assertEquals(1, payments.size());
    }

    @isTest
    static void testEzidebitGenerateCRNBatch() {

        Campaign campaign = new Campaign(
            Name='test'
        );
        insert campaign;

        Account account = new Account(
            Name = 'testName'
        );
        insert account;

        Contact contact = new Contact(
            LastName = 'test',
            FirstName = 'TestF',
            AccountId = account.Id
        );
        insert contact;

        CampaignMember campaignMember = new CampaignMember(
            CampaignId = campaign.Id,
            ContactId = contact.Id
        );
        insert campaignMember;

        EzidebitPaymentProcessor.GetBPayCRNResponse_element element = new EzidebitPaymentProcessor.GetBPayCRNResponse_element();

        element.GetBPayCRNResult = new EzidebitPaymentProcessor.EziResponseOfDataTHgMB7oL();
        element.GetBPayCRNResult.Error = 0;
        element.GetBPayCRNResult.Data = new EzidebitPaymentProcessor.Data();
        element.GetBPayCRNResult.Data.BPayCRN = 'test';

        MockWebServiceResponseGenerator generator = new MockWebServiceResponseGenerator(element);

        Test.setMock(WebServiceMock.class, generator);

        Test.startTest();

        Database.executeBatch(new EzidebitGenerateCRNBatch(campaign.Id), 200);

        Test.stopTest();

        System.assertEquals('test', [SELECT Id, BPAY_CRN__c FROM Contact LIMIT 1].BPAY_CRN__c);
    }

    @IsTest
    static void testPaymentProcessor(){
        //EzidebitPaymentProcessor ezidebitPaymentProcessor = new EzidebitPaymentProcessor();
        EzidebitPaymentProcessor.NewCustomer newCustomer = new EzidebitPaymentProcessor.NewCustomer();
        EzidebitPaymentProcessor.AddCustomerResponse_element addCustomerResponseElement = new EzidebitPaymentProcessor.AddCustomerResponse_element();
        EzidebitPaymentProcessor.AddCustomer_element addCustomerElement = new EzidebitPaymentProcessor.AddCustomer_element();
        EzidebitPaymentProcessor.CreateScheduleResponse_element cResponseElement = new EzidebitPaymentProcessor.CreateScheduleResponse_element();
        EzidebitPaymentProcessor.CreateSchedule_element cElement = new EzidebitPaymentProcessor.CreateSchedule_element();
        EzidebitPaymentProcessor.EziResponseOfCustomerDetailsTHgMB7oL eziResponseOfCustomerDetailsTHgMB7oL = new EzidebitPaymentProcessor.EziResponseOfCustomerDetailsTHgMB7oL();
        EzidebitPaymentProcessor.CustomerDetails customerDetails = new EzidebitPaymentProcessor.CustomerDetails();
        EzidebitPaymentProcessor.GetCustomerDetails_element gDetailsElement = new EzidebitPaymentProcessor.GetCustomerDetails_element();
        EzidebitPaymentProcessor.GetCustomerDetailsResponse_element gCustomerDetailsResponseElement = new EzidebitPaymentProcessor.GetCustomerDetailsResponse_element();
        EzidebitPaymentProcessor.ChangeCustomerStatus_element changeCustomerStatusElement = new EzidebitPaymentProcessor.ChangeCustomerStatus_element();
        EzidebitPaymentProcessor.ChangeCustomerStatusResponse_element changeCustomerStatusResponseElement = new EzidebitPaymentProcessor.ChangeCustomerStatusResponse_element();
        EzidebitPaymentProcessor.ClearSchedule_element clearScheduleElement = new EzidebitPaymentProcessor.ClearSchedule_element();
        EzidebitPaymentProcessor.ClearScheduleResponse_element clearScheduleResponseElement = new EzidebitPaymentProcessor.ClearScheduleResponse_element();
        EzidebitPaymentProcessor.AddBankDebit_element addBankDebitElement = new EzidebitPaymentProcessor.AddBankDebit_element();
        EzidebitPaymentProcessor.AddBankDebitResponse_element addBankDebitResponseElement = new EzidebitPaymentProcessor.AddBankDebitResponse_element();
        EzidebitPaymentProcessor.EziResponseOfRefundPaymentTHgMB7oL eziResponseOfRefundPaymentTHgMB7oL = new EzidebitPaymentProcessor.EziResponseOfRefundPaymentTHgMB7oL();
        EzidebitPaymentProcessor.RefundPayment refundPayment = new EzidebitPaymentProcessor.RefundPayment();
        EzidebitPaymentProcessor.ProcessRefund_element processRefundElement = new EzidebitPaymentProcessor.ProcessRefund_element();
        EzidebitPaymentProcessor.ProcessRefundResponse_element processRefundResponseElement = new EzidebitPaymentProcessor.ProcessRefundResponse_element();

    }

    @IsTest
    static void testPaymentProcGetCustomerDetails(){
        EzidebitPaymentProcessor.CustomerDetails customerDetails = new EzidebitPaymentProcessor.CustomerDetails();
        customerDetails.Email = 'test';

        EzidebitPaymentProcessor.EziResponseOfCustomerDetailsTHgMB7oL customerDetailsTHgMB7oL = new EzidebitPaymentProcessor.EziResponseOfCustomerDetailsTHgMB7oL();
        customerDetailsTHgMB7oL.Error = 0;
        customerDetailsTHgMB7oL.Data = customerDetails;

        EzidebitPaymentProcessor.GetCustomerDetailsResponse_element element = new EzidebitPaymentProcessor.GetCustomerDetailsResponse_element();
        element.GetCustomerDetailsResult = customerDetailsTHgMB7oL;

        MockWebServiceResponseGenerator generator = new MockWebServiceResponseGenerator(element);
        Test.setMock(WebServiceMock.class, generator);

        EzidebitPaymentProcessor ezidebitPaymentProcessor = new EzidebitPaymentProcessor(
            payment_ProcessorFactory.getGatewayCredentials('EziDebit')
        );

        Test.startTest();
        EzidebitStructs.CustomerDetails response = ezidebitPaymentProcessor.getCustomerDetails('test');
        Test.stopTest();

        System.assertEquals(true, response!=null);
    }

    @IsTest
    static void testPaymentProcChangeCustomerStatus(){
        EzidebitPaymentProcessor.EziResponseOfstring eziResponseOfstring = new EzidebitPaymentProcessor.EziResponseOfstring();
        eziResponseOfstring.Error =0;
        eziResponseOfstring.Data = 'test';

        EzidebitPaymentProcessor.ChangeCustomerStatusResponse_element element = new EzidebitPaymentProcessor.ChangeCustomerStatusResponse_element();
        element.ChangeCustomerStatusResult = eziResponseOfstring;

        MockWebServiceResponseGenerator generator = new MockWebServiceResponseGenerator(element);
        Test.setMock(WebServiceMock.class, generator);

        EzidebitPaymentProcessor ezidebitPaymentProcessor = new EzidebitPaymentProcessor(
            payment_ProcessorFactory.getGatewayCredentials('EziDebit')
        );

        Test.startTest();
        Boolean testBool = ezidebitPaymentProcessor.changeCustomerStatus('test', 'test');
        Test.stopTest();

        System.assertEquals(false, testBool);
    }

    @IsTest
    static void testPaymentProcCreateSchedule(){
        EzidebitPaymentProcessor.EziResponseOfstring eziResponseOfstring = new EzidebitPaymentProcessor.EziResponseOfstring();
        eziResponseOfstring.Error =0;
        eziResponseOfstring.Data = 'test';

        EzidebitPaymentProcessor.CreateScheduleResponse_element element = new EzidebitPaymentProcessor.CreateScheduleResponse_element();
        element.CreateScheduleResult = eziResponseOfstring;

        MockWebServiceResponseGenerator generator = new MockWebServiceResponseGenerator(element);
        Test.setMock(WebServiceMock.class, generator);

        EzidebitPaymentProcessor ezidebitPaymentProcessor = new EzidebitPaymentProcessor(
            payment_ProcessorFactory.getGatewayCredentials('EziDebit')
        );

        Test.startTest();
        Boolean testBool = ezidebitPaymentProcessor.createSchedule('test', 'test', '2020-08-11', 'test', 'test', 3, true, false, false, false, 5, 2, 10, true);
        Test.stopTest();

        System.assertEquals(false, testBool);
    }

    @IsTest
    static void testPaymentProcClearSchedule(){
        EzidebitPaymentProcessor.EziResponseOfstring eziResponseOfstring = new EzidebitPaymentProcessor.EziResponseOfstring();
        eziResponseOfstring.Error =0;
        eziResponseOfstring.Data = 'test';

        EzidebitPaymentProcessor.ClearScheduleResponse_element element = new EzidebitPaymentProcessor.ClearScheduleResponse_element();
        element.ClearScheduleResult = eziResponseOfstring;

        MockWebServiceResponseGenerator generator = new MockWebServiceResponseGenerator(element);
        Test.setMock(WebServiceMock.class, generator);

        EzidebitPaymentProcessor ezidebitPaymentProcessor = new EzidebitPaymentProcessor(
            payment_ProcessorFactory.getGatewayCredentials('EziDebit')
        );

        Test.startTest();
        Boolean testBool = ezidebitPaymentProcessor.clearSchedule('test', 'test', true);
        Test.stopTest();

        System.assertEquals(false, testBool);
    }

    @IsTest
    static void testPaymentProcProcessRefund(){
        EzidebitPaymentProcessor.RefundPayment payment = new EzidebitPaymentProcessor.RefundPayment();
        payment.RefundResult = 'W';

        EzidebitPaymentProcessor.EziResponseOfRefundPaymentTHgMB7oL refundPaymentTHgMB7oL = new EzidebitPaymentProcessor.EziResponseOfRefundPaymentTHgMB7oL();
        refundPaymentTHgMB7oL.Error = 0;
        refundPaymentTHgMB7oL.Data = payment;

        EzidebitPaymentProcessor.ProcessRefundResponse_element element = new EzidebitPaymentProcessor.ProcessRefundResponse_element();
        element.ProcessRefundResult = refundPaymentTHgMB7oL;

        MockWebServiceResponseGenerator generator = new MockWebServiceResponseGenerator(element);
        Test.setMock(WebServiceMock.class, generator);

        EzidebitPaymentProcessor ezidebitPaymentProcessor = new EzidebitPaymentProcessor(
            payment_ProcessorFactory.getGatewayCredentials('EziDebit')
        );

        Test.startTest();
        EzidebitStructs.RefundPayment response = ezidebitPaymentProcessor.processRefund('test', 5);
        Test.stopTest();

        System.assertEquals('Pending', response.RefundResult);
    }

    @IsTest
    static void testEziDebitRefundQAMetaProc(){
        Account accountVar = new Account(
            Name = 'test'
        );
        insert accountVar;

        Contact contactVar = new Contact(
            LastName='test',
            FirstName = 'TestF',
            Email='test@test.test',
            AccountId = accountVar.Id
        );
        insert contactVar;

        Opportunity opportunityVar = new Opportunity(
            CloseDate = date.today(),
            StageName = 'Close Won',
            Amount = 10,
            ContactId = contactVar.Id,
            AccountId = accountVar.Id,
            Name = 'Test'
        );

        insert opportunityVar;

        npe01__OppPayment__c paymentVar= new npe01__OppPayment__c(
            npe01__Opportunity__c = opportunityVar.Id,
            npe01__Payment_Method__c = 'Cash',
            EziDebit_Transaction_ID__c = '452323fkf',
            npsp_plus__Status__c = 'Processed'
        );

        insert paymentVar;

        vertic_Response manageEziDebitRefundQAMetaProc = new EziDebitRefundQAMetaProc().process(
            new Map<String, Object>{
                'recordId' => paymentVar.Id
            }
        );
    }
}