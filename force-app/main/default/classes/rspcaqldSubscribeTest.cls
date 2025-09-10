@IsTest
private class rspcaqldSubscribeTest {
    @IsTest
    static void rspcaqldSubscribeTest() {
        Test.startTest();
        rspcaqldSubscribe.doSubscribe('Test', 'Subscribe', 'test.subscribe@test.com');
        Test.stopTest();
    }
}