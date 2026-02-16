public without sharing class aos_AdoptionAgreementSendEmailProc extends aos_AbstractProcessor {

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        EmailTemplate adoptionAgreementTemplate = (EmailTemplate) aos_Utils.arrays.firstOrNull([
                SELECT DeveloperName
                FROM EmailTemplate
                WHERE Name = 'Partners Adoption Agreement Email'
        ]);

        Id referralId = (Id) this.request.getRequiredString('referralId');
        Contact relatedContact = (Contact) aos_Utils.arrays.firstOrException([
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

        aos_Async_Process__c asyncProc = new aos_SendEmailProc.EmailAsyncProcess(adoptionAgreementTemplate.DeveloperName, relatedContact, referralId)
                .setOrgWideEmail(aos_Utils.strings.defaultIfBlank(aos_SettingService.getValue('ADOPTION_AGREEMENT_ORG_WIDE_EMAIL'), 'developer@vertic.com.au'))
                .setContentAttachments(contentAttachments)
                .toAsyncProcess();

        asyncProc.aos_Group_Key__c = referralId;

        new aos_AsyncProcess().add(asyncProc).enqueue();
    }
}