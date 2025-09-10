@IsTest
private class rspcaqldDonationFormSubmitProcTest {
    @IsTest
    static void rspcaqldDonationFormSubmitProcTest() {
        Map<String, Object> contactMap = new Map<String, Object> {
            'organisation' => 'test',
            'firstName' => 'test',
            'lastName' => 'lastName',
            'email' => 'test@email.com',
            'phone' => '0421341234',
            'city' => 'city',
            'country' => 'country',
            'street' => 'street',
            'postalCode' => '4040',
            'state' => 'state'
        };

        Map<String, Object> paymentOnceMap = new Map<String, Object> {
            'type' => 'Once',
            'intentId' => 'testId',
            'amount' => 500,
            'contact' => contactMap,
            'campaignName' => 'test campaign',
            'comments' => 'test comments',
            'keepUpdated' => true
        };
        Map<String, Object> paymentMonthlyMap = new Map<String, Object> {
            'type' => 'Monthly',
            'paymentMethodId' => 'testId',
            'amount' => 500,
            'contact' => contactMap,
            'campaignName' => 'test campaign',
            'comments' => 'test comments',
            'keepUpdated' => true
        };

        Test.startTest();
        new rspcaqldDonationFormSubmitProc().process(new vertic_Request(paymentOnceMap));
        new rspcaqldDonationFormSubmitProc().process(new vertic_Request(paymentMonthlyMap));
        Test.stopTest();
    }
}