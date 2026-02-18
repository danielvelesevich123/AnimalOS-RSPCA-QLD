public with sharing class aos_JobContactsMetaProc extends aos_MetadataProcessor {
    private Set<String> fieldsToSelect = new Set<String>{
            'Id',
            'Name',
            'animalos__Contact_Type__c',
            'animalos__Advisory__c',
            'animalos__Reported_Physical_Violence__c',
            'animalos__Reported_Verbal_Abuse__c',
            'animalos__Reported_Firearms_Weapons__c',
            'animalos__Reported_Known_to_Police__c',
            'animalos__Reported_Substance_Abuse__c',
            'animalos__Observed_Physical_Violence__c',
            'animalos__Observed_Verbal_Abuse__c',
            'animalos__Observed_Firearms_Weapons__c',
            'animalos__Observed_Known_to_Police__c',
            'animalos__Observed_Substance_Abuse__c',
            'animalos__Contact__r.Name',
            'animalos__Contact__r.FirstName',
            'animalos__Contact__r.LastName',
            'animalos__Contact__r.Phone',
            'animalos__Contact__r.MobilePhone',
            'animalos__Contact__r.Email',
            'animalos__Contact__r.AccountId',
            'animalos__Contact__r.Birthdate',
            'animalos__Contact__r.aos_ID_Number__c',
            'animalos__Contact__r.aos_ID_Type__c',
            'animalos__Contact__r.MailingStreet',
            'animalos__Contact__r.MailingState',
            'animalos__Contact__r.MailingCity',
            'animalos__Contact__r.MailingPostalCode',
            'animalos__Contact__r.MailingCountry',
            'animalos__Contact__r.animalos__Advisory__c',
            'animalos__Contact__r.animalos__Reported_Verbal_Abuse__c',
            'animalos__Contact__r.animalos__Reported_Physical_Violence__c',
            'animalos__Contact__r.animalos__Reported_Firearms_Weapons__c',
            'animalos__Contact__r.animalos__Reported_Known_to_Police__c',
            'animalos__Contact__r.animalos__Reported_Substance_Abuse__c',
            'animalos__Contact__r.animalos__Observed_Physical_Violence__c',
            'animalos__Contact__r.animalos__Observed_Verbal_Abuse__c',
            'animalos__Contact__r.animalos__Observed_Firearms_Weapons__c',
            'animalos__Contact__r.animalos__Observed_Known_to_Police__c',
            'animalos__Contact__r.animalos__Observed_Substance_Abuse__c',
            'animalos__Contact__r.animalos__Last_Reported_Verbal_Abuse__c',
            'animalos__Contact__r.animalos__Last_Reported_Physical_Violence__c',
            'animalos__Contact__r.animalos__Last_Reported_Firearms_Weapons__c',
            'animalos__Contact__r.animalos__Last_Reported_Known_to_Police__c',
            'animalos__Contact__r.animalos__Last_Reported_Substance_Abuse__c',
            'animalos__Contact__r.animalos__Last_Observed_Verbal_Abuse__c',
            'animalos__Contact__r.animalos__Last_Observed_Physical_Violence__c',
            'animalos__Contact__r.animalos__Last_Observed_Firearms_Weapons__c',
            'animalos__Contact__r.animalos__Last_Observed_Known_to_Police__c',
            'animalos__Contact__r.animalos__Last_Observed_Substance_Abuse__c',
            'animalos__Contact__r.animalos__Number_of_Reported_Verbal_Abuse__c',
            'animalos__Contact__r.animalos__Number_of_Reported_Physical_Violence__c',
            'animalos__Contact__r.animalos__Number_of_Reported_Firearms_Weapons__c',
            'animalos__Contact__r.animalos__Number_of_Reported_Known_to_Police__c',
            'animalos__Contact__r.animalos__Number_of_Reported_Substance_Abuse__c',
            'animalos__Contact__r.animalos__Number_of_Observed_Verbal_Abuse__c',
            'animalos__Contact__r.animalos__Number_of_Observed_Physical_Violence__c',
            'animalos__Contact__r.animalos__Number_of_Observed_Firearms_Weapons__c',
            'animalos__Contact__r.animalos__Number_of_Observed_Known_to_Police__c',
            'animalos__Contact__r.animalos__Number_of_Observed_Substance_Abuse__c',
            'animalos__Job__c',
            'animalos__Job__r.Name',
            'animalos__Job__r.animalos__Status__c',
            'animalos__Job__r.animalos__Start_Date__c',
            'animalos__Job__r.CreatedDate',
            'animalos__Job__r.animalos__Address__Street__s',
            'animalos__Job__r.animalos__Address__PostalCode__s',
            'animalos__Job__r.animalos__Address__StateCode__s',
            'animalos__Job__r.animalos__Address__CountryCode__s',
            'animalos__Job__r.animalos__Address__City__s',
            'animalos__Job__r.animalos__Advisory__c',
            'animalos__Job__r.animalos__Current_Job_Advisory__c',
            'animalos__Job__r.animalos__Reported_Verbal_Abuse__c',
            'animalos__Job__r.animalos__Reported_Physical_Violence__c',
            'animalos__Job__r.animalos__Reported_Firearms_Weapons__c',
            'animalos__Job__r.animalos__Reported_Known_to_Police__c',
            'animalos__Job__r.animalos__Reported_Substance_Abuse__c',
            'animalos__Job__r.animalos__Observed_Verbal_Abuse__c',
            'animalos__Job__r.animalos__Observed_Physical_Violence__c',
            'animalos__Job__r.animalos__Observed_Firearms_Weapons__c',
            'animalos__Job__r.animalos__Observed_Known_to_Police__c',
            'animalos__Job__r.animalos__Observed_Substance_Abuse__c',
            'animalos__Job__r.OwnerId',
            'animalos__Job__r.Owner.Id',
            'animalos__Job__r.Owner.Name',
            'animalos__Job__r.aos_Case__c',
            'animalos__Job__r.aos_Case__r.CaseNumber',
            'animalos__Job__r.aos_Case__r.CreatedDate',
            'animalos__Job__r.animalos__Location_Of_Interest__r.Name',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Advisory__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Reported_Physical_Violence__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Reported_Verbal_Abuse__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Reported_Firearms_Weapons__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Reported_Known_to_Police__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Reported_Substance_Abuse__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Observed_Verbal_Abuse__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Observed_Physical_Violence__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Observed_Firearms_Weapons__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Observed_Known_to_Police__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Observed_Substance_Abuse__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Last_Reported_Physical_Violence__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Last_Reported_Verbal_Abuse__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Last_Reported_Firearms_Weapons__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Last_Reported_Known_to_Police__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Last_Reported_Substance_Abuse__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Last_Observed_Physical_Violence__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Last_Observed_Verbal_Abuse__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Last_Observed_Firearms_Weapons__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Last_Observed_Known_to_Police__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Last_Observed_Substance_Abuse__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Number_of_Reported_Physical_Violence__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Number_of_Reported_Verbal_Abuse__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Number_of_Reported_Firearms_Weapons__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Number_of_Reported_Known_to_Police__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Number_of_Reported_Substance_Abuse__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Number_of_Observed_Physical_Violence__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Number_of_Observed_Verbal_Abuse__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Number_of_Observed_Firearms_Weapons__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Number_of_Observed_Known_to_Police__c',
            'animalos__Job__r.animalos__Location_Of_Interest__r.animalos__Number_of_Observed_Substance_Abuse__c',
            '(SELECT Id, animalos__Caution_Details__c, animalos__Caution_Source__c, animalos__Caution_Type__c FROM animalos__Interaction_Cautions__r)'
    };
    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                animalos__Job_Contact__c.animalos__Contact_Type__c
        };

        super.process(this.request);

        this.doInit();

        return this.response;
    }

    private void doInit() {
        String recordId = this.request.getRequiredString('recordId');
        SObjectType sObjectType = ((Id) recordId).getSobjectType();
        String condition;

        if (sObjectType == Contact.getSObjectType()) {
            condition = 'animalos__Contact__c = :recordId';
            this.response.put('isContact', true);
        }

        if (sObjectType == animalos__Job__c.getSObjectType()) {
            condition = 'animalos__Job__c = :recordId';
            this.response.put('isJob', true);
        }

        if (sObjectType == animalos__Location_Of_Interest__c.getSObjectType()) {
            condition = 'animalos__Job__r.animalos__Location_Of_Interest__c = :recordId';
            this.response.put('isLocation', true);
        }

        List<animalos__Job_Contact__c> jobContacts = Database.query(
                'SELECT ' + String.join(new List<String>(this.fieldsToSelect), ', ') +
                        '\nFROM animalos__Job_Contact__c\n' +
                        'WHERE ' + condition + ' ORDER BY animalos__Job__r.CreatedDate DESC');
        this.response.getMapper().mapFromListSObjects('jobContacts', jobContacts);

        this.response.getMapper().mapAnyValue('isContactCentreUser', ((Profile) aos_Utils.arrays.firstOrException([
                SELECT Name
                FROM Profile
                WHERE Id = :UserInfo.getProfileId()
        ])).Name.contains('Contact Centre'));

        this.response.getMapper().mapAnyValue('isInspector', ((Profile) aos_Utils.arrays.firstOrException([
                SELECT Name
                FROM Profile
                WHERE Id = :UserInfo.getProfileId()
        ])).Name.contains('Inspector'));

        List<List<SObject>> jobContactsByJobs = new List<List<SObject>>();
        Map<String, List<SObject>> jobContactsByJobIds = aos_Utils.sObjects.getSObjectsListByAnyFieldMap(jobContacts, animalos__Job_Contact__c.animalos__Job__c);

        for(String jobId : jobContactsByJobIds.keySet()) {
            jobContactsByJobs.add(jobContactsByJobIds.get(jobId));
        }

        this.response.getMapper().mapAnyValue('jobContactsByJobs', jobContactsByJobs);
    }
}