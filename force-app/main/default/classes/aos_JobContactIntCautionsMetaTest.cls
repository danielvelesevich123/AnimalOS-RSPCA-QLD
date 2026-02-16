@IsTest
private class aos_JobContactIntCautionsMetaTest {
    @IsTest
    static void testBehavior() {
        Contact contactVar = new Contact(
                LastName = 'Test'
        );
        insert contactVar;

        vertic_Response response = new JobContactInteractionCautionsMetaProc().process(new Map<String, Object>{
                'contactId' => contactVar.Id
        });

        System.assert(response.isValid);
    }
}