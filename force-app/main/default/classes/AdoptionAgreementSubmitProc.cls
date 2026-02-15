public without sharing class AdoptionAgreementSubmitProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        animalos__Referral__c referralVar = new animalos__Referral__c();
        this.request.getMapper().mapToSObject('referral', referralVar);
        update referralVar;
        Id referralId = (Id) referralVar.Id;
        vertic_AsyncProcess asyncProcess = new vertic_AsyncProcess();

        aos_Async_Process__c saveSignaturesVap = vertic_AsyncProcess.create(
                AdoptionAgreementSaveSignaturesProc.class,
                this.request.getMap()
        );

        saveSignaturesVap.aos_Group_Key__c = referralId;
        asyncProcess.add(saveSignaturesVap);

        aos_Async_Process__c savePdfVap = vertic_AsyncProcess.create(
                AdoptionAgreementSavePdfProc.class,
                this.request.getMap()
        );
        savePdfVap.aos_Group_Key__c = referralId;
        asyncProcess.add(savePdfVap);

        asyncProcess.enqueue();
    }
}
