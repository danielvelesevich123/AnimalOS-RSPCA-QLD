public class aos_PetRescueSyncQASubmitProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String recordId = this.request.getRequiredString('recordId');
        String locationId = this.request.getRequiredString('locationId');
        String status = this.request.getRequiredString('status');

        new AnimalToPetRescueProc().process(new Map<String, Object>{
                'locationId' => locationId,
                'recordId' => recordId,
                'status' => status
        });
    }

}