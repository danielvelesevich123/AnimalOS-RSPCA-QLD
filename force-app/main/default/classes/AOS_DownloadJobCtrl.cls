public with sharing class AOS_DownloadJobCtrl {
    private ApexPages.StandardSetController controller;

    public String getRecordsJSON() {
        List<SObject> records = this.controller.getSelected().isEmpty()
                                ? this.controller.getRecords()
                                : this.controller.getSelected();

        return JSON.serialize(records);
    }

    public AOS_DownloadJobCtrl(ApexPages.StandardSetController controller) {
        this.controller = controller;
    }

    public String getRecords() {
        List<SObject> records = this.controller.getSelected();
        List<String> ids = new List<String>();

        if (!records.isEmpty()) {
            for (SObject sobj : records) {
                ids.add(sobj.Id);
            }
            return String.join(ids, ',');
        } else {
            return '';
        }
    }
}