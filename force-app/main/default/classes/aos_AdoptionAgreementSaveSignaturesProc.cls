public without sharing class aos_AdoptionAgreementSaveSignaturesProc extends aos_AbstractProcessor {

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String adoptionAgreementSignature = this.request.getString('adoptionAgreementSignature');
        String indemnityWaiverContractSignature = request.getString('indemnityWaiverContractSignature');
        String referralId = this.request.getRequiredString('referral.Id');

        animalos__Referral__c referralVar = (animalos__Referral__c) aos_Utils.arrays.firstOrException([
                SELECT Id, Name
                FROM animalos__Referral__c
                WHERE Id = :referralId
        ]);

        this.saveSignature(adoptionAgreementSignature, referralVar, false);
        this.saveSignature(indemnityWaiverContractSignature, referralVar, true);
        update referralVar;
    }

    public void saveSignature(String signatureBody, animalos__Referral__c referralVar, Boolean isAdoptionAgreementSignature) {
        if(String.isBlank(signatureBody)) {
            return;
        }

        ContentVersion contentVersionVar = new ContentVersion();
        contentVersionVar.ContentLocation = 'S';
        contentVersionVar.PathOnClient = referralVar.Name + (isAdoptionAgreementSignature ? ' Adoption Agreement' : ' Indemnity Waiver Contract') + ' Signature.png';
        contentVersionVar.Title = referralVar.Name + (isAdoptionAgreementSignature ? ' Adoption Agreement' : ' Indemnity Waiver Contract') + ' Signature';
        contentVersionVar.VersionData = EncodingUtil.base64Decode(signatureBody);
        insert contentVersionVar;

        contentVersionVar = [
                SELECT Id, Title, PathOnClient, VersionData, PublishStatus, ContentDocumentId, ContentDocument.Title
                FROM ContentVersion
                WHERE Id = :contentVersionVar.Id
        ];

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                ContentDocumentId = contentVersionVar.ContentDocumentId,
                ContentDocument = contentVersionVar.ContentDocument,
                LinkedEntityId = referralVar.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
        );

        insert contentDocumentLink;

        ContentDistribution signatureDistribution = (ContentDistribution) aos_Utils.arrays.firstOrNull([
                SELECT ContentDownloadUrl
                FROM ContentDistribution
                WHERE ContentVersionId = :contentVersionVar.Id
        ]);

        if (signatureDistribution == null) {
            signatureDistribution = new ContentDistribution(
                    Name = contentVersionVar.Title,
                    ContentVersionId = contentVersionVar.Id,
                    PreferencesAllowViewInBrowser = true,
                    PreferencesLinkLatestVersion = true,
                    PreferencesNotifyOnVisit = false,
                    PreferencesPasswordRequired = false,
                    PreferencesAllowOriginalDownload = true,
                    PreferencesAllowPDFDownload = true
            );
            insert signatureDistribution;
        }

        signatureDistribution = (ContentDistribution) aos_Utils.arrays.firstOrException([
                SELECT ContentDownloadUrl
                FROM ContentDistribution
                WHERE ContentVersionId = :contentVersionVar.Id
        ]);

        if (isAdoptionAgreementSignature) {
            referralVar.aos_Additional_Signature_URL__c = signatureDistribution.ContentDownloadUrl;
            referralVar.aos_Additional_Signing_Date__c = Date.today();
        } else {
            referralVar.aos_Signature_URL__c = signatureDistribution.ContentDownloadUrl;
            referralVar.aos_Signing_Date__c = Date.today();
        }
    }
}