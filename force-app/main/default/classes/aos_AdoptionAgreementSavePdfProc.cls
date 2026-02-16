public without sharing class aos_AdoptionAgreementSavePdfProc extends aos_AbstractProcessor {

    private Id pdfDocumentId;
    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String referralId = this.request.getRequiredString('referral.Id');

        animalos__Referral__c referralVar = (animalos__Referral__c) aos_Utils.arrays.firstOrException([
                SELECT Id, animalos__Contact__c
                FROM animalos__Referral__c
                WHERE Id = :referralId
        ]);

        this.savePDF(referralVar.Id);
        this.sendPDFEmail(referralVar.animalos__Contact__c, referralVar.Id);
        this.sendEmailToReferralOwner(referralVar.Id);
    }

    public void savePDF(String recordId) {
        String urlVar = '/apex/AdoptionAgreement?recordId=' + recordId;
        PageReference pg = new PageReference(urlVar);

        ContentVersion contentVersionVar = new ContentVersion();
        contentVersionVar.ContentLocation = 'S';
        contentVersionVar.PathOnClient = 'Adoption Agreement.pdf';
        contentVersionVar.Title = 'Adoption Agreement.pdf';
        contentVersionVar.VersionData = pg.getContent();
        insert contentVersionVar;

        contentVersionVar = [
                SELECT Id, Title, PathOnClient, VersionData, PublishStatus, ContentDocumentId, ContentDocument.Title
                FROM ContentVersion
                WHERE Id = :contentVersionVar.Id
        ];

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                ContentDocumentId = contentVersionVar.ContentDocumentId,
                ContentDocument = contentVersionVar.ContentDocument,
                LinkedEntityId = recordId,
                ShareType = 'V',
                Visibility = 'AllUsers'
        );

        insert contentDocumentLink;

        ContentDistribution pdfDistribution = (ContentDistribution) aos_Utils.arrays.firstOrNull([
                SELECT ContentDownloadUrl
                FROM ContentDistribution
                WHERE ContentVersionId = :contentVersionVar.Id
        ]);

        if (pdfDistribution == null) {
            pdfDistribution = new ContentDistribution(
                    Name = contentVersionVar.Title,
                    ContentVersionId = contentVersionVar.Id,
                    PreferencesAllowViewInBrowser = true,
                    PreferencesLinkLatestVersion = true,
                    PreferencesNotifyOnVisit = false,
                    PreferencesPasswordRequired = false,
                    PreferencesAllowOriginalDownload = true,
                    PreferencesAllowPDFDownload = true
            );
            insert pdfDistribution;
        }

        this.pdfDocumentId = contentVersionVar.ContentDocumentId;
    }

    public void sendPDFEmail(String targetId, String whatId) {
        EmailTemplate adoptionAgreementPDFTemplate = (EmailTemplate) aos_Utils.arrays.firstOrNull([
                SELECT DeveloperName
                FROM EmailTemplate
                WHERE Name = 'Partners Adoption Agreement PDF Email'
        ]);

        new aos_SendEmailProc().process(new Map<String, Object>{
                'email' => new Map<String, Object>{
                        'templateName' => adoptionAgreementPDFTemplate.DeveloperName,
                        'targetId' => targetId,
                        'whatId' => whatId,
                        'orgWideEmail' => aos_Utils.strings.defaultIfBlank(aos_SettingService.getValue('ADOPTION_AGREEMENT_ORG_WIDE_EMAIL'), 'developer@vertic.com.au'),
                        'attachments' => new List<Map<String, Object>>{
                                new Map<String, Object>{
                                        'contentDocumentIds' => new List<String>{
                                                this.pdfDocumentId
                                        }
                                }
                        },
                        'contentAttachments' => new List<Map<String, Object>>{
                                new Map<String, Object>{
                                        'proc' => 'ConfirmationOfDetailsQA',
                                        'fileName' => 'Confirmation of Details.pdf',
                                        'recordId' => whatId
                                }
                        }
                }
        });
    }

    private void sendEmailToReferralOwner(String whatId) {
        EmailTemplate adoptionAgreementOwnerNotificationTemplate = (EmailTemplate) aos_Utils.arrays.firstOrNull([
                SELECT DeveloperName
                FROM EmailTemplate
                WHERE Name = 'Partners Adoption Agreement Owner Notification'
        ]);

        User userVar = (User) aos_Utils.arrays.firstOrException([
                SELECT Id, Email
                FROM User
                WHERE Id IN (
                        SELECT OwnerId
                        FROM animalos__Referral__c
                        WHERE Id = :whatId
                )
        ]);

        aos_Async_Process__c adoptionAgreementOwnerNotificationAsyncProc = new aos_SendEmailProc.EmailAsyncProcess(
                adoptionAgreementOwnerNotificationTemplate.DeveloperName,
                userVar,
                whatId
        )
                .setOrgWideEmail(aos_Utils.strings.defaultIfBlank(aos_SettingService.getValue('ADOPTION_AGREEMENT_ORG_WIDE_EMAIL'), 'developer@vertic.com.au'))
                .toAsyncProcess();

        new aos_AsyncProcess()
                .add(adoptionAgreementOwnerNotificationAsyncProc)
                .enqueue();
    }
}