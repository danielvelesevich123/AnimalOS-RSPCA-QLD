@IsTest
private class rspcaqldCtaFormCtrlTest {
    @IsTest
    static void rspcaqldCtaFormCtrlTest() {
        Map<String, Object> contactMap = new Map<String, Object>{
            'organisation' => 'Test Organisation',
            'firstName' => 'Test',
            'lastName' => 'Contact',
            'email' => 'test@email.com',
            'phone' => '0112341234'
        };

        Map<String, Object> caseMap = new Map<String, Object>{
            'partnershipType' => 'Corporate Partnership Opportunity',
            'description' => 'Test Description',
            'reason' => 'Partnership Enquiry',
            'marketingOptin' => true,
            'privacyPolicy' => false
        };

        Test.startTest();
        rspcaqldCtaFormCtrl.doSubmit(JSON.serialize(contactMap), JSON.serialize(caseMap));
        Test.stopTest();
    }
}