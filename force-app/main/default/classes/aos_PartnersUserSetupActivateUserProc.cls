public class aos_PartnersUserSetupActivateUserProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String recordId = this.request.getRequiredString('recordId');
        Boolean isLog = this.request.has('isLog') && this.request.getBoolean('isLog');

        Contact contactVar = (Contact) vertic_Utils.arrays.firstOrException([
                SELECT Id
                FROM Contact
                WHERE Id = :recordId
        ]);

        User userVar = new User();
        this.request.getMapper().mapToSObject('user', userVar);

        try {


            if (userVar.Id == null) {
                userVar.Alias = ((String.isNotBlank(userVar.FirstName) ? userVar.FirstName?.substring(0, 1) : '') + userVar.LastName.substring(0, 1)).toLowerCase();
                userVar.TimeZoneSidKey = 'Australia/Brisbane';
                userVar.LocaleSidKey = 'en_AU';
                userVar.EmailEncodingKey = 'UTF-8';
                userVar.LanguageLocaleKey = 'en_US';
                userVar.IsActive = true;
                insert userVar;
            } else if (userVar.Id != null) {
                if (isLog) {
                    List<aos_Location_Volunteer__c> locationVolunteers = [
                            SELECT Id
                            FROM aos_Location_Volunteer__c
                            WHERE aos_User__c = :userVar.Id
                    ];

                    for (aos_Location_Volunteer__c locationVolunteer : locationVolunteers) {
                        locationVolunteer.aos_Status__c = 'Active';
                    }
                    update locationVolunteers;
                }

                if (!isLog) {
                    userVar.IsActive = true;
                    update userVar;

                    System.enqueueJob(new aos_ProcessLogQueueable(new List<animalos__Log__c>{
                            new animalos.Logging()
                                    .setProcess('aos_PartnersUserSetupActivateUserProc')
                                    .addPayload(
                                            new vertic_DTO().getMapper()
                                                    .mapAnyValue('recordId', recordId)
                                                    .mapAnyValue('isLog', true)
                                                    .mapFromSObject('user', userVar)
                                                    .getMap()
                                    )
                                    .build()
                    }));
                }
            }
        } catch (Exception e) {
            if (e.getMessage().containsIgnoreCase('The username already exists in this or another Salesforce organization.')) {
                throw new vertic_Structs.ProcessException('The username already exists. Please choose a different username.');
            }
            if (e.getMessage().containsIgnoreCase('Username must be in the form of an email address (for example, john@acme.com)')) {
                throw new vertic_Structs.ProcessException('Username must be in the form of an email address (for example, john@acme.com)');
            }
            throw e;
        }
    }

}