public class aos_PartnersUserSetupDeactivateUserProc extends aos_AbstractProcessor {

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {

        String recordId = this.request.getRequiredString('recordId');

        Contact contactVar = (Contact) aos_Utils.arrays.firstOrException([
                SELECT Id
                FROM Contact
                WHERE Id = :recordId
        ]);

        User userVar = (User) aos_Utils.arrays.firstOrException([
                SELECT Id
                FROM User
                WHERE ContactId = :contactVar.Id
        ]);

        userVar.IsActive = false;
        update userVar;

    }


}