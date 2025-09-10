public class RetrieveAnimalFilesGetProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    private Set<String> oneDriveFileFields = new Set<String>{
            'Name',
            'animalos_Animal__r.Name',
            'animalos_Animal__r.animalos__Status__c',
            'File_Link__c',
            'Folder_Name__c',
            'Is_Primary__c',
            'File_ID__c',
            'Is_Deleted__c',
            'LastModifiedDate'
    };

    public override vertic_Response process(vertic_Request request) {
        this.request = (vertic_RestService.Request) request;
        this.response = (vertic_RestService.Response) super.response;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {

        Integer queryLimit = String.isBlank(this.request.params.get('Limit')) ? null : Integer.valueOf(this.request.params.get('Limit'));
        String lastModifiedDateStr = this.request.params.get('LastModifiedDate');
        Date lastModifiedDate;
        if (String.isNotBlank(lastModifiedDateStr)) {
            lastModifiedDate = Date.valueOf(lastModifiedDateStr + 'T00:00:00Z');
        }
        List<String> statuses = new List<String>();
        String animalStatus = this.request.params.get('AnimalStatus');

        fflib_QueryFactory queryFactory = new fflib_QueryFactory(OneDrive_File__c.SObjectType)
                .selectFields(this.oneDriveFileFields);

        List<String> conditions = new List<String>();
        List<String> totalConditions;

        conditions.add('Is_Public__c = TRUE');
        conditions.add('Folder_Name__c LIKE \'%PHOTO%\'');
        conditions.add('Is_Deleted__c = FALSE');

        if (String.isNotBlank(this.request.params.get('AnimalId'))) {
            String animalId = this.request.params.get('AnimalId');
            conditions.add('animalos_Animal__c = :animalId');
            totalConditions = conditions.clone();
        } else {
            if (String.isNotBlank(animalStatus)) {
                statuses = animalStatus.split(',');
                conditions.add('animalos_Animal__r.animalos__Status__c IN :statuses');
            }

            if (lastModifiedDate != null) {
                conditions.add('LastModifiedDate > :lastModifiedDate');
            }

            if (String.isNotBlank(this.request.params.get('Limit'))) {
                queryFactory.setLimit(Integer.valueOf(this.request.params.get('Limit')));
            }
            totalConditions = conditions.clone();

            if (String.isNotBlank(this.request.params.get('LastRecordId'))) {
                conditions.add('Id > \'' + this.request.params.get('LastRecordId') + '\'');
            }
        }

        queryFactory.setCondition(String.join(conditions, ' AND '))
                .setOrdering(OneDrive_File__c.Id, fflib_QueryFactory.SortOrder.ASCENDING);
        List<OneDrive_File__c> oneDriveFiles = Database.query(queryFactory.toSOQL());

        Integer recordsLeft = (Integer) Database.countQuery(('SELECT COUNT() FROM OneDrive_File__c WHERE ' + String.join(conditions, ' AND '))) - (queryLimit == null ? 0 : queryLimit);

        this.response.put('oneDriveFiles', oneDriveFiles);

        Integer totalNumberOfRecords = (Integer) Database.countQuery(('SELECT COUNT() FROM OneDrive_File__c WHERE ' + String.join(totalConditions, ' AND ')));
        this.response.put('recordsLeft', recordsLeft < 0 || String.isBlank(this.request.params.get('Limit')) ? 0 : recordsLeft);
        this.response.put('totalNumberOfRecords', totalNumberOfRecords);
    }

    private vertic_RestService.Response response;

    protected override vertic_Response getResponseInstance() {
        return new vertic_RestService.Response();
    }

    /** ============================================================================================================= */

    private vertic_RestService.Request request;

    public override Type getRequestType() {
        return vertic_RestService.Request.class;
    }

    public override vertic_Request getRequestInstance(String requestJSON) {
        return (vertic_RestService.Request) JSON.deserialize(requestJSON, this.getRequestType());
    }

}