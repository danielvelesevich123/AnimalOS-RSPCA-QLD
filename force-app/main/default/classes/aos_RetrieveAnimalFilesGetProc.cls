public class aos_RetrieveAnimalFilesGetProc extends aos_AbstractProcessor implements aos_Structs.IRollbackable {

    private Set<String> oneDriveFileFields = new Set<String>{
            'Name',
            'aos_Animal__r.Name',
            'aos_Animal__r.animalos__Status__c',
            'aos_File_Link__c',
            'aos_Folder_Name__c',
            'aos_Is_Primary__c',
            'aos_File_ID__c',
            'aos_Is_Deleted__c',
            'LastModifiedDate'
    };

    public override aos_Response process(aos_Request request) {
        this.request = (aos_RestService.Request) request;
        this.response = (aos_RestService.Response) super.response;

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

        aos_QueryFactory queryFactory = new aos_QueryFactory(aos_OneDrive_File__c.SObjectType)
                .selectFields(this.oneDriveFileFields);

        List<String> conditions = new List<String>();
        List<String> totalConditions;

        conditions.add('aos_Is_Public__c = TRUE');
        conditions.add('aos_Folder_Name__c LIKE \'%PHOTO%\'');
        conditions.add('aos_Is_Deleted__c = FALSE');

        if (String.isNotBlank(this.request.params.get('AnimalId'))) {
            String animalId = this.request.params.get('AnimalId');
            conditions.add('aos_Animal__c = :animalId');
            totalConditions = conditions.clone();
        } else {
            if (String.isNotBlank(animalStatus)) {
                statuses = animalStatus.split(',');
                conditions.add('aos_Animal__r.animalos__Status__c IN :statuses');
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
                .setOrdering(aos_OneDrive_File__c.Id, aos_QueryFactory.SortOrder.ASCENDING);
        List<aos_OneDrive_File__c> oneDriveFiles = Database.query(queryFactory.toSOQL());

        Integer recordsLeft = (Integer) Database.countQuery(('SELECT COUNT() FROM aos_OneDrive_File__c WHERE ' + String.join(conditions, ' AND '))) - (queryLimit == null ? 0 : queryLimit);

        this.response.put('oneDriveFiles', oneDriveFiles);

        Integer totalNumberOfRecords = (Integer) Database.countQuery(('SELECT COUNT() FROM aos_OneDrive_File__c WHERE ' + String.join(totalConditions, ' AND ')));
        this.response.put('recordsLeft', recordsLeft < 0 || String.isBlank(this.request.params.get('Limit')) ? 0 : recordsLeft);
        this.response.put('totalNumberOfRecords', totalNumberOfRecords);
    }

    private aos_RestService.Response response;

    protected override aos_Response getResponseInstance() {
        return new aos_RestService.Response();
    }

    /** ============================================================================================================= */

    private aos_RestService.Request request;

    public override Type getRequestType() {
        return aos_RestService.Request.class;
    }

    public override aos_Request getRequestInstance(String requestJSON) {
        return (aos_RestService.Request) JSON.deserialize(requestJSON, this.getRequestType());
    }

}