public class aos_VolunteerRescueReqReceiptMetaProc extends vertic_MetadataProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new MetadataRequest() : (MetadataRequest) request;

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {

        // https://rspcaqld2--adev--c.sandbox.vf.force.com/apex/AOS_JobSummary?renderAs=pdf&jobId=a3FOg000000WBoLMAW&contactId=003Og00000HDZRIIA5&proc=VolunteerRescueRequestReceipt&fileName=Job+Summary

        this.response.dto.putAll(new Map<String, Object>{
                'page-styles' => 'margin-top: 0.3in; margin-bottom: 0.3in',
                'font-family' => '"Arial", sans-serif',
                'renderAs' => vertic_Utils.objects.defaultIfNull(this.request.getString('renderAs'), 'html')
        });

        String jobId = this.request.getString('jobId');
        vertic_Utils.objects.throwIfBlank(jobId, 'No jobId param');

        String contactId = this.request.getString('contactId');
        vertic_Utils.objects.throwIfBlank(contactId, 'No contactId param');

        Contact contactVar = (Contact) vertic_Utils.arrays.firstOrException([
            SELECT Id, Name
            FROM Contact
            WHERE Id = :contactId
        ]);

        animalos__Job__c jobVar = (animalos__Job__c) vertic_Utils.arrays.firstOrException([
            SELECT Id
                ,Name
                ,animalos__Address__City__s
                ,animalos__Priority__c
                ,CreatedDate
                ,animalos__Area__r.animalos__Parent_Area__r.Name
                ,animalos__Area__r.Name
                ,animalos__Codes__c
                ,CreatedBy.Name
                ,animalos__Important_Notes__c
                ,animalos__Location_Of_Interest__c
                ,animalos__Reported_Physical_Violence__c
                ,animalos__Observed_Physical_Violence__c
                ,animalos__Reported_Verbal_Abuse__c
                ,animalos__Observed_Verbal_Abuse__c
            FROM animalos__Job__c
            WHERE Id = :jobId
        ]);

        String jobCodesSplitted;

        if (String.isNotBlank(jobVar.animalos__Codes__c)) {
            jobCodesSplitted = String.join(new List<String>(jobVar.animalos__Codes__c.split(';')), ', ');
        }

        List<animalos__Job_Contact__c> jobContactsVar = [
            SELECT Id
                ,Name
                ,animalos__Contact__c
                ,animalos__Contact__r.Name
                ,animalos__Contact__r.MailingStreet
                ,animalos__Contact__r.MailingCity
                ,animalos__Contact__r.MailingState
                ,animalos__Contact__r.MailingPostalCode
                ,animalos__Contact__r.Phone
                ,animalos__Contact__r.Email
                ,animalos__Contact_Type__c
                ,animalos__Reported_Physical_Violence__c
                ,animalos__Observed_Physical_Violence__c
                ,animalos__Reported_Verbal_Abuse__c
                ,animalos__Observed_Verbal_Abuse__c
            FROM animalos__Job_Contact__c
            WHERE animalos__Job__c = :jobVar.Id
        ];

        animalos__Location_Of_Interest__c locationOfInterestVar = (animalos__Location_Of_Interest__c) vertic_Utils.arrays.firstOrDefault([
            SELECT Id
                ,Name
                ,animalos__Reported_Physical_Violence__c
                ,animalos__Observed_Physical_Violence__c
                ,animalos__Reported_Verbal_Abuse__c
                ,animalos__Observed_Verbal_Abuse__c
            FROM animalos__Location_Of_Interest__c
            WHERE Id = :jobVar.animalos__Location_Of_Interest__c
        ], new animalos__Location_Of_Interest__c());

        Integer locationOfInterestJobCount = [SELECT Count() FROM animalos__Job__c WHERE animalos__Location_Of_Interest__c = :locationOfInterestVar.Id];

        List<Object> components = new List<Object>();

        vertic_DTO dto = new vertic_DTO();

        dto.put('contact', contactVar);
        dto.put('job', jobVar);
        dto.put('jobContacts', jobContactsVar);
        dto.put('locationOfInterest', locationOfInterestVar);
        dto.put('locationOfInterestJobCount', locationOfInterestJobCount);
        dto.put('jobCodesSplitted', jobCodesSplitted);
        dto.put('todayFormatted', system.today().format());
        dto.put('renderAs', vertic_Utils.objects.defaultIfNull(this.request.getString('renderAs'), 'html'));

        components.add(this.setTemplate(dto));

        this.response.dto.put('components', components);
        this.response.dto.put('head-component', new Component.VolunteerRescueRequestReceiptStyles());

        System.debug(this.response.dto);
    }

    private Object setTemplate(vertic_DTO dto){
        return new Component.VolunteerRescueRequestReceipt(
                dto = dto.getMap()
        );
    }

     public static Map<Id, vertic_SendEmailProc.EmailAsyncProcess> getDeclineDonationEmailsAsyncProcesses(Set<Id> donationsIds) {

         List<Opportunity> donations = [
                 SELECT npsp__Primary_Contact__r.Email,
                         npsp__Primary_Contact__r.IsEmailBounced,
                         Account.npe01__One2OneContact__r.Email,
                         Account.npe01__One2OneContact__r.IsEmailBounced
                 FROM Opportunity
                 WHERE Id IN :donationsIds
         ];

         String defaultOrgWideEmail = vertic_SettingService.getValue('DEFAULT_ORG_WIDE_ADDRESS', 'kuc@kuc.org.au');

         Map<Id, vertic_SendEmailProc.EmailAsyncProcess> asyncProcesses = new Map<Id, vertic_SendEmailProc.EmailAsyncProcess>();

         for (Opportunity opportunityVar : donations) {
             vertic_SendEmailProc.EmailAsyncProcess emailAsyncProcessVar;

             Contact contactVar = opportunityVar.npsp__Primary_Contact__r;
             Id targetId = null;

             Boolean isOpportunityContactNotValid = contactVar == null || String.isBlank(contactVar.Email);
             Boolean isAccountContactValid = opportunityVar.Account != null && opportunityVar.Account.npe01__One2OneContact__c != null;
             if(isOpportunityContactNotValid && isAccountContactValid){
                 contactVar = opportunityVar.Account.npe01__One2OneContact__r;
             }

             if (targetId == null) {
                 continue;
             }

             Map<String, Object> emailParametersMap = new Map<String, Object>{
                     'ids' => opportunityVar.Id, 'renderAs' => 'html'
             };

             emailAsyncProcessVar = new vertic_SendEmailProc.EmailAsyncProcess(
                     'DonationDeclineReceipt',
                     emailParametersMap
             ).setTargetId(targetId)
                     .setOrgWideEmail(defaultOrgWideEmail)
                     .setSaveAsActivity(true)
                     .setSubject('Please update your details to continue your support');

             asyncProcesses.put(opportunityVar.Id, emailAsyncProcessVar);
         }

         return asyncProcesses;

     }
}