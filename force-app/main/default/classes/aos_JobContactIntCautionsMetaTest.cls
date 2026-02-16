@IsTest
private class aos_JobContactIntCautionsMetaTest {
    @IsTest
    static void testBehavior() {
        Contact contactVar = new Contact(
                LastName = 'Test'
        );
        insert contactVar;

        aos_Response response = new aos_JobContactIntCautionsMetaProc().process(new Map<String, Object>{
                'contactId' => contactVar.Id
        });

        System.assert(response.isValid);
    }
}