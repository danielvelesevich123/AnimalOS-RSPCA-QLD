public class aos_PetRescueSyncQASubmitProc extends aos_AbstractProcessor {

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String recordId = this.request.getRequiredString('recordId');
        String locationId = this.request.getRequiredString('locationId');
        String status = this.request.getRequiredString('status');

        new aos_AnimalToPetRescueProc().process(new Map<String, Object>{
                'locationId' => locationId,
                'recordId' => recordId,
                'status' => status
        });
    }

}