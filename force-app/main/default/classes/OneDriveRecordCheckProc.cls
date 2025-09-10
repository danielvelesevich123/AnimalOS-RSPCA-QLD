public class OneDriveRecordCheckProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        this.checkIsRecordHasFiles();
    }


    private void checkIsRecordHasFiles() {
        Id recordId = this.request.getRequiredString('recordId');
        Integer numberOfFiles = this.request.getInteger('numberOfFiles');

        SObjectType sObjectType = recordId.getSobjectType();

        SObject record = sObjectType.newSObject(recordId);

        if (isFieldExists(sObjectType, 'Media__c')) {
            if (numberOfFiles == 0) {
                record.put('Media__c', false);
            } else if (numberOfFiles > 0) {
                record.put('Media__c', true);
            }

            update record;
        }
    }

    private Boolean isFieldExists(SObjectType sObjectType, String fieldToCheck) {

        Set<String> allObjectFields = sObjectType.getDescribe().fields.getMap().keySet();

        if (allObjectFields.contains(fieldToCheck.toLowerCase())) {
            return true;
        }

        return false;
    }
}