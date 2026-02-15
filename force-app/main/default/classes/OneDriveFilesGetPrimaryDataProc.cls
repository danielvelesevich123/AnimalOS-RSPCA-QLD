public without sharing class OneDriveFilesGetPrimaryDataProc extends vertic_AbstractProcessor {
    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        List<Object> filesObjects = (List<Object>) this.request.get('files');
        Id recordId = this.request.getRequiredString('recordId');
        String folderName = this.request.getRequiredString('folderName');

        SObjectType sObjectTypeName = recordId.getSobjectType();
        String sObjectTypeNameString = recordId.getSobjectType() == animalos__Animal__c.SObjectType ? 'animalos_Animal__c' : OneDriveCreateFileSObjectProc.getLookupFieldName(sObjectTypeName);

        String oneDriveFilesQuery = 'SELECT Id, aos_Is_Primary__c, aos_Profile_Image__c, Name FROM aos_OneDrive_File__c WHERE '
                + sobjectTypeNameString.remove('__c') + '__c = \'' + recordId + '\'' + ' AND aos_Folder_Name__c = \'' + folderName + '\'';

        List<aos_OneDrive_File__c> oneDriveFiles = Database.query(oneDriveFilesQuery);

        Map<String, aos_OneDrive_File__c> oneDriveFilesMap = new Map<String, aos_OneDrive_File__c>();
        for (aos_OneDrive_File__c oneDriveFileVar : oneDriveFiles) {
            oneDriveFilesMap.put(oneDriveFileVar.Name, oneDriveFileVar);
        }

        List<Map<String, Object>> filesList = new List<Map<String, Object>>();
        for (Object fileObject : filesObjects) {
            Map<String, Object> file = (Map<String, Object>) fileObject;
            if (oneDriveFilesMap.get((String) file.get('name')) != null) {
                file.put('isPrimary', oneDriveFilesMap.get((String) file.get('name')).aos_Is_Primary__c);
                file.put('isProfilePhoto', oneDriveFilesMap.get((String) file.get('name')).aos_Profile_Image__c);
            }
            filesList.add(file);
        }

        this.response.put('files', filesList);

        return this.response;
    }
}