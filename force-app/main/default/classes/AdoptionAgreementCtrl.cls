public without sharing class AdoptionAgreementCtrl extends vertic_MetadataProcessor {
    public Map<String, Object> dto { get; set; }

    public void initMetadata() {
        String recordId = ApexPages.currentPage().getParameters().get('recordId');

        vertic_Response responseVar = new AdoptionAgreementMetaProc().process(
                new Map<String, Object>{
                        'recordId' => recordId,
                        'isPdf' => true
                }
        );

        this.dto = responseVar.getMap();
    }
}
