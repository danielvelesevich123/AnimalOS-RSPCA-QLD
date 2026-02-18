public without sharing class aos_OneDriveDeleteRestoreFileSobjectProc extends aos_AbstractProcessor {
    public override aos_Response process(aos_Request request) {

        Id recordId = request.getRequiredString('recordId');
        String fileName = request.getRequiredString('fileName');
        String folderName = request.getRequiredString('folderName');
        String action = request.getRequiredString('action');

        fileName = fileName.length() > 80 ? fileName.substring(0, 77) : fileName;

        SObjectType sObjectTypeName = recordId.getSobjectType();
        String sObjectTypeNameString = aos_OneDriveCreateFileSObjectProc.getLookupFieldName(sObjectTypeName);

        List<String> conditions = new List<String>{
                'Name = :fileName',
                sObjectTypeNameString + ' = :recordId',
                'aos_Folder_Name__c = :folderName'
        };

        aos_QueryFactory queryFactory = new aos_QueryFactory(aos_OneDrive_File__c.SObjectType)
                .selectFields(new Set<String>{
                        'Id', 'Name'
                })
                .setCondition(String.join(conditions, ' AND '));

        System.debug(queryFactory.toSOQL());
        aos_OneDrive_File__c oneDriveFile = (aos_OneDrive_File__c) aos_Utils.arrays.firstOrException(Database.query(queryFactory.toSOQL()),
                'No OneDrive file with name: ' + fileName + ' for record: ' + recordId);

        if (action == 'completelyDelete') {
            delete oneDriveFile;
        }
        if (action == 'delete') {
            oneDriveFile.aos_Is_Deleted__c = true;
            oneDriveFile.aos_Is_Primary__c = false;
            oneDriveFile.aos_Is_Public__c = false;
            update oneDriveFile;
        }
        if (action == 'restore') {
            oneDriveFile.aos_Is_Deleted__c = false;
            update oneDriveFile;
        }

        this.response.put('oneDriveFile', fileName);

        return this.response;
    }
}