public without sharing class aos_AdoptionAgreementSubmitProc extends aos_AbstractProcessor {

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        animalos__Referral__c referralVar = new animalos__Referral__c();
        this.request.getMapper().mapToSObject('referral', referralVar);
        update referralVar;
        Id referralId = (Id) referralVar.Id;
        aos_AsyncProcess asyncProcess = new aos_AsyncProcess();

        aos_Async_Process__c saveSignaturesVap = aos_AsyncProcess.create(
                aos_AdoptionAgreementSaveSignaturesProc.class,
                this.request.getMap()
        );

        saveSignaturesVap.aos_Group_Key__c = referralId;
        asyncProcess.add(saveSignaturesVap);

        aos_Async_Process__c savePdfVap = aos_AsyncProcess.create(
                aos_AdoptionAgreementSavePdfProc.class,
                this.request.getMap()
        );
        savePdfVap.aos_Group_Key__c = referralId;
        asyncProcess.add(savePdfVap);

        asyncProcess.enqueue();
    }
}