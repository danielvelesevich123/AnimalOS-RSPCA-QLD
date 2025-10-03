public without sharing class AdoptionAgreementSendEmailProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        EmailTemplate adoptionAgreementTemplate = (EmailTemplate) vertic_Utils.arrays.firstOrNull([
                SELECT DeveloperName
                FROM EmailTemplate
                WHERE Name = 'Partners Adoption Agreement Email'
        ]);

        Id referralId = (Id) this.request.getRequiredString('referralId');
        Contact relatedContact = (Contact) vertic_Utils.arrays.firstOrException([
                SELECT Id, Email
                FROM Contact
                WHERE Id IN (
                        SELECT animalos__Contact__c
                        FROM animalos__Referral__c
                        WHERE Id = :referralId
                )
        ], 'Referral has empty Contact, email can not be sent');

        List<Map<String, Object>> contentAttachments = new List<Map<String, Object>>{
                new Map<String, Object>{
                        'proc' => 'ConfirmationOfDetailsQA',
                        'fileName' => 'Confirmation of Details.pdf',
                        'recordId' => referralId
                }
        };

        Vertic_Async_Process__c asyncProc = new vertic_SendEmailProc.EmailAsyncProcess(adoptionAgreementTemplate.DeveloperName, relatedContact, referralId)
                .setOrgWideEmail(vertic_Utils.strings.defaultIfBlank(vertic_SettingService.getValue('ADOPTION_AGREEMENT_ORG_WIDE_EMAIL'), 'developer@vertic.com.au'))
                .setContentAttachments(contentAttachments)
                .toAsyncProcess();

        asyncProc.Group_Key__c = referralId;

        new vertic_AsyncProcess().add(asyncProc).enqueue();
    }
}