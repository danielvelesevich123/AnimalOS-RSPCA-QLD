public without sharing class OneDriveDeleteRestoreFileSobjectProc extends vertic_AbstractProcessor {
    public override vertic_Response process(vertic_Request request) {

        Id recordId = request.getRequiredString('recordId');
        String fileName = request.getRequiredString('fileName');
        String folderName = request.getRequiredString('folderName');
        String action = request.getRequiredString('action');

        fileName = fileName.length() > 80 ? fileName.substring(0, 77) : fileName;

        SObjectType sObjectTypeName = recordId.getSobjectType();
        String sObjectTypeNameString = OneDriveCreateFileSObjectProc.getLookupFieldName(sObjectTypeName);

        List<String> conditions = new List<String>{
                'Name = :fileName',
                (sObjectTypeName == animalos__Animal__c.SObjectType ? 'animalos_Animal__c' : sObjectTypeNameString) + ' = :recordId',
                'Folder_Name__c = :folderName'
        };

        fflib_QueryFactory queryFactory = new fflib_QueryFactory(OneDrive_File__c.SObjectType)
                .selectFields(new Set<String>{
                        'Id', 'Name'
                })
                .setCondition(String.join(conditions, ' AND '));

        System.debug(queryFactory.toSOQL());
        OneDrive_File__c oneDriveFile = (OneDrive_File__c) vertic_Utils.arrays.firstOrException(Database.query(queryFactory.toSOQL()),
                'No OneDrive file with name: ' + fileName + ' for record: ' + recordId);

        if (action == 'completelyDelete') {
            delete oneDriveFile;
        }
        if (action == 'delete') {
            oneDriveFile.Is_Deleted__c = true;
            oneDriveFile.Is_Primary__c = false;
            oneDriveFile.Is_Public__c = false;
            update oneDriveFile;
        }
        if (action == 'restore') {
            oneDriveFile.Is_Deleted__c = false;
            update oneDriveFile;
        }

        this.response.put('oneDriveFile', fileName);

        return this.response;
    }
}