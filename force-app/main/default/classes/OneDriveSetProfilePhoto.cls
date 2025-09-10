public without sharing class OneDriveSetProfilePhoto extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        Id recordId = this.request.getRequiredString('recordId');
        String fileId = this.request.getString('fileId');

        SObjectType sObjectTypeName = recordId.getSobjectType();
        String sObjectTypeNameString = recordId.getSobjectType() == animalos__Animal__c.SObjectType ? 'animalos_Animal__c' : OneDriveCreateFileSObjectProc.getLookupFieldName(sObjectTypeName);

        String oneDriveFilesQuery = 'SELECT Id, Is_Primary__c, File_Link__c, Name, File_ID__c FROM OneDrive_File__c WHERE ' +
                sObjectTypeNameString.remove('__c') + '__c = ' + '\'' + recordId + '\'';

        List<OneDrive_File__c> oneDriveFiles = Database.query(oneDriveFilesQuery);

        List<OneDrive_File__c> oneDriveFilesForUpdate = new List<OneDrive_File__c>();


        for (OneDrive_File__c oneDriveFile : oneDriveFiles) {

            OneDrive_File__c oneDriveFileClone = oneDriveFile.clone();

            if (oneDriveFile.File_ID__c == fileId) {
                oneDriveFile.Profile_Image__c = true;
                this.response.put('primaryFile', oneDriveFile);
            } else {
                oneDriveFile.Profile_Image__c = false;
            }

            if (vertic_Utils.sObjects.isSomeFieldChanged(oneDriveFile, oneDriveFileClone, new List<String>{
                    'Profile_Image__c'
            })) {
                oneDriveFilesForUpdate.add(oneDriveFile);
            }
        }

        update oneDriveFilesForUpdate;

        return this.response;
    }


}