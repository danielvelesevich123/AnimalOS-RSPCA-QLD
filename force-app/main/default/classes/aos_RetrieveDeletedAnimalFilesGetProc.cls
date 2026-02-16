public class aos_RetrieveDeletedAnimalFilesGetProc extends vertic_AbstractProcessor {

    private Set<String> oneDriveFileFields = new Set<String>{
            'Name',
            'aos_Folder_Name__c',
            'aos_Is_Primary__c',
            'aos_File_ID__c',
            'aos_Is_Deleted__c',
            'aos_Is_Public__c',
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
        String lastRecordId = this.request.params.get('LastRecordId');

        fflib_QueryFactory queryFactory = new fflib_QueryFactory(aos_OneDrive_File__c.SObjectType)
                .selectFields(this.oneDriveFileFields);

        List<String> conditions = new List<String>();
        List<String> totalConditions;

        conditions.add('(Is_Public__c = FALSE OR Is_Deleted__c = TRUE)');
        conditions.add('Folder_Name__c LIKE \'%PHOTO%\'');
        conditions.add('animalos_Animal__c IN (\n' +
                '        SELECT Id\n' +
                '        FROM animalos__Animal__c\n' +
                ')');

        if (lastModifiedDate != null) {
            conditions.add('LastModifiedDate > :lastModifiedDate');
        }

        totalConditions = conditions.clone();

        if (String.isNotBlank(lastRecordId)) {
            conditions.add('Id > \'' + lastRecordId + '\'');
        }

        queryFactory.setCondition(String.join(conditions, ' AND '))
                .setOrdering(aos_OneDrive_File__c.Id, fflib_QueryFactory.SortOrder.ASCENDING);

        if (queryLimit != null) {
            queryFactory.setLimit(queryLimit);
        }

        List<aos_OneDrive_File__c> oneDriveFiles = Database.query(queryFactory.toSOQL());

        Integer recordsLeft = (Integer) Database.countQuery(('SELECT COUNT() FROM OneDrive_File__c WHERE ' + String.join(conditions, ' AND '))) - (queryLimit == null ? 0 : queryLimit);
        Integer totalNumberOfRecords = (Integer) Database.countQuery(('SELECT COUNT() FROM OneDrive_File__c WHERE ' + String.join(totalConditions, ' AND ')));

        this.response.getMapper().mapFromListSObjects('oneDriveFiles', oneDriveFiles);
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
