public without sharing class aos_AdoptionAgreementCtrl extends aos_MetadataProcessor {
    public Map<String, Object> dto { get; set; }

    public void initMetadata() {
        String recordId = ApexPages.currentPage().getParameters().get('recordId');

        aos_Response responseVar = new aos_AdoptionAgreementMetaProc().process(
                new Map<String, Object>{
                        'recordId' => recordId,
                        'isPdf' => true
                }
        );

        this.dto = responseVar.getMap();
    }
}