public without sharing class JobFinalisationNotificationQASubmitProc extends vertic_AbstractProcessor{
    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.sendJobFinalisationNotification();

        return this.response;
    }

    private void sendJobFinalisationNotification(){
        String contactId = this.request.getString('contactId');
        String emailTemplateDeveloperName = this.request.getString('emailTemplateDeveloperName');
        String jobId = this.request.getString('jobId');

        System.debug(contactId);

        System.debug(emailTemplateDeveloperName);

        System.debug(jobId);

        Contact contactVar = (Contact)vertic_Utils.arrays.firstOrNull(
                [
                        SELECT
                                Id,
                                Name,
                                Email
                        FROM Contact
                        WHERE Id = :contactId
                ]
        );

        EmailTemplate emailTemplateVar = (EmailTemplate)vertic_Utils.arrays.firstOrNull(
                [
                        SELECT
                                Id,
                                DeveloperName
                        FROM EmailTemplate
                        WHERE DeveloperName = :emailTemplateDeveloperName
                ]
        );

        animalos__Job__c jobVar = (animalos__Job__c)vertic_Utils.arrays.firstOrNull(
                [
                        SELECT
                                Id,
                                Name,
                                aos_Old_Job_Number__c
                        FROM animalos__Job__c
                        WHERE Id = :jobId
                ]
        );

        OrgWideEmailAddress orgWideEmailAddressVar = (OrgWideEmailAddress)vertic_Utils.arrays.firstOrNull(
                [
                        SELECT
                                Id,
                                DisplayName,
                                Address
                        FROM OrgWideEmailAddress
                        WHERE DisplayName = 'Supporter Care'
                ]
        );

        if(
                contactVar != null
                        && emailTemplateVar != null
                        && jobVar != null
                        && orgWideEmailAddressVar != null
                        && String.isNotBlank(contactVar.Email)
        ) {
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setTargetObjectId(contactVar.Id);
            emailMessage.setOrgWideEmailAddressId(orgWideEmailAddressVar.Id);
            emailMessage.setTemplateId(emailTemplateVar.Id);
            emailMessage.setWhatId(jobVar.Id);
            emailMessage.setSaveAsActivity(true);

            emailMessages.add(emailMessage);

            if(emailMessages.size() > 0){
                Messaging.sendEmail(emailMessages);
            }
        }
    }
}