public with sharing class CreateContentDocumentLinkProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    /**
 * ==============================================================================================================
 *                                              PROCESS
 * ==============================================================================================================
 */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    /**
 * ==============================================================================================================
 *                                             PRIVATE METHODS
 * ==============================================================================================================
 */

    private void doSubmit() {
        String recordId = this.request.getRequiredString('recordId');
        String sObjectName = this.request.getRequiredString('params.sObjectName');
        Content_Document_Link__c linkVar = (Content_Document_Link__c) vertic_Utils.arrays.firstOrException([
            SELECT Id, Opportunity_Id__c, Content_Document_Id__c, ShelterBuddy_ID__c FROM Content_Document_Link__c WHERE Id =:recordId
        ]);
        System.debug('record:  ' + linkVar);
        SObject record;
        switch on sObjectName {
            when 'Opportunity' {
                record = (Opportunity) vertic_Utils.arrays.firstOrNull([SELECT Id FROM Opportunity WHERE External_ID__c =: linkVar.Opportunity_Id__c]);
            }
            when 'Contact' {
                record = (Contact) vertic_Utils.arrays.firstOrNull([SELECT Id FROM Contact WHERE ShelterBuddy_ID_PID__c =: linkVar.ShelterBuddy_ID__c]);
            }
        }

        System.debug('record:  ' + record);
//        ContentDocumentLink link = (ContentDocumentLink) vertic_Utils.arrays.firstOrNull([SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId =: record.Content_Document_Id__c]);
//        System.debug('link:  ' + link);
        if (record != null) {
            insert new ContentDocumentLink(
                ContentDocumentId = linkVar.Content_Document_Id__c,
                LinkedEntityId = record.Id
            );
        }
    }

    /**
 * ==============================================================================================================
 *                                               STRUCTURES
 * ==============================================================================================================
 */

// Proposed Live Templates to override Super properties:
// vertic_request
// vertic_response

}