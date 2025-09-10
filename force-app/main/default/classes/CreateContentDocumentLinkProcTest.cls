@IsTest
private class CreateContentDocumentLinkProcTest {
    static testMethod void testBehavior() {
        ContentVersion testContentInsert = new ContentVersion(
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            Title ='Google.com'
        );
        insert testContentInsert;
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentInsert.Id LIMIT 1];
        Opportunity opportunityVar = new Opportunity(
            Name = 'Test',
            StageName = 'Active',
            CloseDate = Date.today().addMonths(1)
        );
        insert opportunityVar;
        opportunityVar.External_ID__c = opportunityVar.Id;
        update opportunityVar;
        Content_Document_Link__c cdl = new Content_Document_Link__c(
            Opportunity_Id__c = opportunityVar.Id,
            Content_Document_Id__c = testContent.ContentDocumentId
        );
        insert cdl;
        vertic_Response response = new CreateContentDocumentLinkProc().process(new Map<String, Object>{
            'recordId' => cdl.Id,
            'params' => new Map<String, Object>{
                    'sObjectName' => 'Opportunity'
            }
        });
        Assert.isTrue(response.isValid, 'Processor failed');
    }
}