public without sharing class OneDriveFileDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {

    public OneDriveFileDomain(List <sObject> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OneDriveFileDomain(sObjectList);
        }
    }

    public override void onBeforeInsert() {
    }

    public override void onAfterInsert() {
        this.updateAnimalGalleryUpdatedDate(this.Records);
        this.uploadAnimalToPetRescue(this.Records, null);
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        this.updateAnimalGalleryUpdatedDate(this.Records);
        this.uploadAnimalToPetRescue(this.Records, existingRecords);
        this.sendDeletedOneDriveFileId(this.Records, existingRecords);
    }

    private void updateAnimalGalleryUpdatedDate(List<sObject> records) {
        Set<Id> animalIds = vertic_Utils.sObjects.getIdFieldValues(
                records,
                aos_OneDrive_File__c.aos_Animal__c
        );

        List<animalos__Animal__c> animalsForUpdate = new List<animalos__Animal__c>();

        for (animalos__Animal__c animal : [
                SELECT Id
                FROM animalos__Animal__c
                WHERE Id IN :animalIds
        ]) {
            animal.aos_Gallery_Updated_Date__c = Date.today();

            animalsForUpdate.add(animal);
        }

        update animalsForUpdate;
    }

    private void uploadAnimalToPetRescue(List<sObject> records, Map<Id, sObject> existingRecords) {

        Set<Id> animalIds = new Set<Id>();

        for (aos_OneDrive_File__c oneDriveFile : (List<aos_OneDrive_File__c>) records) {
            Boolean isCreated = Trigger.isInsert && existingRecords == null;
            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingRecords.get(oneDriveFile.Id) != null &&
                    vertic_Utils.sObjects.isSomeFieldChanged(
                            oneDriveFile,
                            existingRecords.get(oneDriveFile.Id),
                            new List<sObjectField>{
                                    aos_OneDrive_File__c.aos_Is_Public__c,
                                    aos_OneDrive_File__c.aos_Is_Deleted__c,
                                    aos_OneDrive_File__c.aos_Is_Primary__c
                            }
                    );

            if (((isCreated && (oneDriveFile.aos_Is_Public__c || oneDriveFile.aos_Is_Primary__c) && !oneDriveFile.aos_Is_Deleted__c) || isUpdated)
                    && oneDriveFile.aos_Animal__c != null
                    && String.isNotBlank(oneDriveFile.aos_Folder_Name__c) && oneDriveFile.aos_Folder_Name__c.containsIgnoreCase('photos')) {
                animalIds.add(oneDriveFile.aos_Animal__c);
            }
        }

        if (!animalIds.isEmpty()) {
            List<animalos__Animal__c> animals = new List<animalos__Animal__c>();

            for (Id animalId : animalIds) {
                animals.add(new animalos__Animal__c(Id = animalId));
            }

            TDTM_aos_AnimalPostToPetRescue.uploadToPetRescueIgnoringUpdateConditions = true;
            update animals;
        }
    }

    private void sendDeletedOneDriveFileId(List<sObject> records, Map<Id, sObject> existingRecords) {
        vertic_AsyncProcess verticAsyncProcess = new vertic_AsyncProcess();

        for (aos_OneDrive_File__c oneDriveFile : (List<aos_OneDrive_File__c>) records) {
            Boolean isUpdated = existingRecords != null && existingRecords.get(oneDriveFile.Id) != null &&
                    vertic_Utils.sObjects.isSomeFieldChanged(
                            oneDriveFile,
                            existingRecords.get(oneDriveFile.Id),
                            new List<SObjectField>{
                                    aos_OneDrive_File__c.aos_Is_Deleted__c,
                                    aos_OneDrive_File__c.aos_Is_Public__c
                            }
                    );

            if (isUpdated && (oneDriveFile.aos_Is_Deleted__c || !oneDriveFile.aos_Is_Public__c)) {
                aos_Async_Process__c vap = vertic_AsyncProcess.create(
                        SendDeletedOneDriveFileIdProc.class,
                        new Map<String, Object>{
                                'recordId' => oneDriveFile.Id
                        }
                );
                vap.aos_Group_Key__c = oneDriveFile.Id;

                verticAsyncProcess.add(vap);
            }
        }

        verticAsyncProcess.enqueue();
    }
}