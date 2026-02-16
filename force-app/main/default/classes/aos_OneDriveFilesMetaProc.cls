public class aos_OneDriveFilesMetaProc extends aos_MetadataProcessor {

    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                // SObject Fields, e.g. Contact.Salutation
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        this.response.put('hasEnhancedAccess', this.hasEnhancedAccess());
    }

    public Boolean hasEnhancedAccess() {
        return [
                SELECT COUNT()
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
                AND PermissionSet.Name = 'One_Drive_Files_Enhanced_Access'
        ] > 0;
    }
}