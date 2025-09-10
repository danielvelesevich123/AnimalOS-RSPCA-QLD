@IsTest
private class StripeProcTest {
    @IsTest
    static void testStripePaymentIntentCreationProc() {


        Test.startTest();

        vertic_Response verticResponse = new StripePaymentIntentCreationProc().process(
            new Map<String, Object>{
                'amount' => 12,
                'currency' => '3'

            }
        );

        Test.stopTest();

    }
    @IsTest
    static void testStripePaymentIntentUpdateProc() {

        Test.startTest();

        vertic_Response verticResponse = new StripePaymentIntentUpdateProc().process(
            new Map<String, Object>{
                'amount' => 12,
                'currency' => '3',
                'intentId'  => 'test32'

            }
        );

        Test.stopTest();

    }

    @IsTest
    static void testStripeSetupIntentCreationProc() {

        Test.startTest();

        vertic_Response verticResponse = new StripeSetupIntentCreationProc().process(
            new Map<String, Object>{
                'intentId'  => 'test32'

            }
        );

        Test.stopTest();

    }
}