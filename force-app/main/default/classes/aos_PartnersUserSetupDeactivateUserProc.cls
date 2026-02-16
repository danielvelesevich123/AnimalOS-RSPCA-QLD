public class aos_PartnersUserSetupDeactivateUserProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {

        String recordId = this.request.getRequiredString('recordId');

        Contact contactVar = (Contact) vertic_Utils.arrays.firstOrException([
                SELECT Id
                FROM Contact
                WHERE Id = :recordId
        ]);

        User userVar = (User) vertic_Utils.arrays.firstOrException([
                SELECT Id
                FROM User
                WHERE ContactId = :contactVar.Id
        ]);

        userVar.IsActive = false;
        update userVar;

    }


}