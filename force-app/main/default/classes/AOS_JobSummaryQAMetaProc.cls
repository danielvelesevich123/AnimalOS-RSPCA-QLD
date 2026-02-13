public with sharing class AOS_JobSummaryQAMetaProc extends vertic_MetadataProcessor {

    private vertic_Response tablesData;
    private String jobId;

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new MetadataRequest() : (MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{

        };

        super.process(this.request);
        this.initMetadata();
        this.initComponents();

        return this.response;
    }

    private void initMetadata() {
        vertic_MetadataProcessor.MetadataRequest request = new vertic_MetadataProcessor.MetadataRequest();

        this.jobId = this.request.getRequiredString('jobId');

        request.put('jobId', this.jobId);
        request.put('isVisualForce', true);
    }

    private void initComponents() {

        List<Object> components = new List<Object>();
        vertic_DTO dto = new vertic_DTO();

        Set<String> jobIds = new Set<String>(this.jobId.split(','));

        List<animalos__Job__c> jobs = [
                SELECT Id, Name, animalos__Area__c, animalos__Area__r.Name, animalos__Description__c,
                        animalos__Address__c, animalos__Codes__c, animalos__Full_Address__c,
                        animalos__Property_Directions__c, animalos__Location_Of_Interest__c, animalos__Important_Notes__c,
                        animalos__Address__Street__s, animalos__Address__Latitude__s, animalos__Address__Longitude__s,
                        animalos__Animal_Report_Summary__c, CreatedDate, Owner.Name, animalos__Priority__c,
                        animalos__Job_Outcome__c, Job_Outcome_Multi__c, (
                        SELECT Id
                        FROM animalos__Job_Activities2__r
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                )
                FROM animalos__Job__c
                WHERE Id IN :jobIds
        ];

        Set<Id> locationIds = vertic_Utils.sObjects.getIdFieldValues(jobs, animalos__Job__c.animalos__Location_Of_Interest__c);

        Map<String, Object> jobNotesByJobId = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, animalos__Interaction_Date_Time__c, animalos__Subject__c, animalos__Content__c, animalos__Job__c, CreatedDate, CreatedBy.Name
                FROM animalos__Job_Note__c
                WHERE animalos__Job__c IN :jobIds
        ], animalos__Job_Note__c.animalos__Job__c);

        Map<String, Object> jobContactsByJobId = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, animalos__Job__c, animalos__Contact_Type__c, animalos__Contact__r.Name,
                        animalos__Contact__r.MobilePhone, animalos__Contact__r.Phone, animalos__Contact__r.HomePhone,
                        animalos__Contact__r.Email,

                        animalos__Contact__r.Full_Address__c, animalos__Contact__r.npe01__WorkPhone__c,
                        animalos__Contact__r.animalos__POI_Description__c
                FROM animalos__Job_Contact__c
                WHERE animalos__Job__c IN :jobIds AND animalos__Contact__c != NULL
        ], animalos__Job_Contact__c.animalos__Job__c);

        Map<String, List<SObject>> relatedJobsByMainJobId = new Map<String, List<SObject>>();
        List<animalos__Job__c> jobsFromTheSameLocations = [
                SELECT Id, Name, animalos__Start_Date__c, animalos__Codes__c, animalos__Location_Of_Interest__c
                FROM animalos__Job__c
                WHERE animalos__Location_Of_Interest__c IN :locationIds
        ];
        for (animalos__Job__c jobVar : jobs) {
            relatedJobsByMainJobId.put(jobVar.Id, new List<SObject>());
            for (animalos__Job__c jobFromTheSameLocations : jobsFromTheSameLocations) {
                if (String.isNotBlank(jobVar.animalos__Location_Of_Interest__c) &&
                        String.isNotBlank(jobFromTheSameLocations.animalos__Location_Of_Interest__c) &&
                        jobVar.Id != jobFromTheSameLocations.Id &&
                        jobVar.animalos__Location_Of_Interest__c.equals(jobFromTheSameLocations.animalos__Location_Of_Interest__c)) {
                    relatedJobsByMainJobId.get(jobVar.Id).add(jobFromTheSameLocations);
                }
            }
        }

        vertic_AutoMapper autoMapper = new vertic_AutoMapper(dto)
                .getOptions()
                .setIsVisualforce(true)
                .setIsAllFields(true)
                .setDefaultFieldValue(' ')
                .getMapper()
                .mapFromListSObjects(
                        'jobs',
                        jobs,
                        new vertic_AutoMapper.BinderQueue(
                                new JobBinder(jobs, relatedJobsByMainJobId, jobNotesByJobId, jobContactsByJobId)
                        )
                );

        Boolean isEmail = this.request.getBoolean('isEmail') == true;

        dto.put('isEmail', isEmail);

        String contactId = this.request.getString('contactId');

        Boolean hasContact = String.isNotBlank(contactId);

        if (isEmail == true && hasContact) {

            Contact contactVar = (Contact) vertic_Utils.arrays.firstOrDefault([
                SELECT Id, Name
                FROM Contact
                WHERE Id = :contactId
            ], new Contact(FirstName = '', LastName = ''));
            hasContact = contactVar.Id != null;
            dto.put('contact', contactVar);
        }

        dto.put('hasContact', hasContact);

        components.add(new Component.AOS_JobSummary(
                dto = dto.getMap()
        ));

        this.response.dto.put('components', components);
        this.response.dto.put('head-component', new Component.AOS_JobSummaryStyles(
            isEmail = isEmail
        ));

    }

    /**
     * ==============================================================================================================
     *                                         STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */

    public class JobBinder extends vertic_AutoMapper.AbstractBinder {

        List<animalos__Job__c> jobs;
        Map<String, Object> relatedJobsByMainJobId;
        Map<String, Object> jobNotesByJobId;
        Map<String, Object> jobContactsByJobId;

        public JobBinder(
                List<animalos__Job__c> jobs,
                Map<String, Object> relatedJobsByMainJobId,
                Map<String, Object> jobNotesByJobId,
                Map<String, Object> jobContactsByJobId
        ) {
            this.jobs = jobs;
            this.relatedJobsByMainJobId = relatedJobsByMainJobId;
            this.jobNotesByJobId = jobNotesByJobId;
            this.jobContactsByJobId = jobContactsByJobId;
        }

        public void bind(SObject jobVar, Map<String, Object> dtoMap) {

            animalos__Job__c job = (animalos__Job__c) jobVar;

            dtoMap.put(
                    'animalos__Property_Directions__c',
                    String.isBlank(job.animalos__Property_Directions__c)
                            ? String.isBlank(job.animalos__Property_Directions__c)
                            ? '' : job.animalos__Property_Directions__c
                            : job.animalos__Property_Directions__c
            );

            List<animalos__Job_Note__c> jobNotes = (List<animalos__Job_Note__c>) jobNotesByJobId.get(job.Id);
            List<animalos__Job_Contact__c> jobContacts = (List<animalos__Job_Contact__c>) jobContactsByJobId.get(job.Id);
            List<animalos__Job_Contact__c> informants = new List<animalos__Job_Contact__c>();
            List<animalos__Job_Contact__c> POIs = new List<animalos__Job_Contact__c>();
            List<animalos__Job_Contact__c> others = new List<animalos__Job_Contact__c>();


            animalos__Assigned_Resource__c assignedInspector;

            if (!job.animalos__Job_Activities2__r.isEmpty()) {
                // TODO: AOS SOQL in loop
                assignedInspector = (animalos__Assigned_Resource__c) vertic_Utils.arrays.firstOrNull([
                        SELECT Id, animalos__Resource__r.Name
                        FROM animalos__Assigned_Resource__c
                        WHERE animalos__Job_Activity__c = :job.animalos__Job_Activities2__r[0].Id
                ]);
            }

            List<animalos__Job__c> relatedJobs = (List<animalos__Job__c>) relatedJobsByMainJobId.get(job.Id);
            dtoMap.put('hasRelatedJobs', false);
            dtoMap.put('jobsAtSameAddress', relatedJobs?.size() ?? 0);

            if (relatedJobs != null && !relatedJobs.isEmpty()) {
                // TODO: AOS SOQL in loop
                List<animalos__Assigned_Resource__c> assignedInspectors = [
                        SELECT Id, animalos__Resource__r.Name, animalos__Job_Activity__r.animalos__Job__c
                        FROM animalos__Assigned_Resource__c
                        WHERE animalos__Job_Activity__r.animalos__Job__c IN :relatedJobs AND animalos__Resource__r.Name != NULL
                        ORDER BY CreatedDate ASC
                ];

                Map<String, Object> assignedInspectorsByJobId = new Map<String, Object>();

                for (animalos__Assigned_Resource__c assignedInspectorVar : assignedInspectors) {
                    assignedInspectorsByJobId.put(assignedInspectorVar.animalos__Job_Activity__r.animalos__Job__c, assignedInspectorVar);
                }

                dtoMap.put('relatedJobs', relatedJobsListToMap(relatedJobs, assignedInspectorsByJobId));
                dtoMap.put('hasRelatedJobs', true);
            }

            String POIDescription = '';

            if (jobContacts != null) {
                for (animalos__Job_Contact__c jobContact : jobContacts) {
                    String phone = '';
                    if (!String.isBlank(jobContact.animalos__Contact__r.MobilePhone)) {
                        phone = phone + '<p>' + jobContact.animalos__Contact__r.MobilePhone + '</p>';
                    }

                    // TODO: AOS remove npe01__WorkPhone__c from the logic
                    if (!String.isBlank(jobContact.animalos__Contact__r.npe01__WorkPhone__c)) {
                        phone = phone + '<p>' + jobContact.animalos__Contact__r.npe01__WorkPhone__c + '</p>';
                    }
                    if (!String.isBlank(jobContact.animalos__Contact__r.HomePhone)) {
                        phone = phone + '<p>' + jobContact.animalos__Contact__r.HomePhone + '</p>';
                    }

                    jobContact.animalos__Contact__r.Phone = phone;

                    // TODO: AOS remove Full_Address__c from the logic
                    if (String.isBlank(jobContact.animalos__Contact__r.Full_Address__c)) {
                        jobContact.animalos__Contact__r.MailingStreet = 'No Address';
                    } else {
                        jobContact.animalos__Contact__r.MailingStreet = jobContact.animalos__Contact__r.Full_Address__c;
                    }

                    if ('Informant'.equals(jobContact.animalos__Contact_Type__c) || 'Informant Secondary'.equals(jobContact.animalos__Contact_Type__c)) {
                        informants.add(jobContact);
                    } else if ('Person Of Interest'.equals(jobContact.animalos__Contact_Type__c) || 'POI Secondary'.equals(jobContact.animalos__Contact_Type__c)) {
                        POIs.add(jobContact);
                    } else {
                        others.add(jobContact);
                    }

                    if (!String.isBlank(jobContact.animalos__Contact__r.animalos__POI_Description__c)) {
                        POIDescription += jobContact.animalos__Contact__r.animalos__POI_Description__c + '\n';
                    }
                }
            }

            if (jobNotes != null) {
                for (animalos__Job_Note__c jobNoteVar : jobNotes) {
                    if (!String.isBlank(jobNoteVar.animalos__Subject__c)) {
                        jobNoteVar.animalos__Content__c = '<p><b>' + jobNoteVar.animalos__Subject__c + '</b></p>' + jobNoteVar.animalos__Content__c;
                    }

                    jobNoteVar.animalos__Interaction_Date_Time__c = jobNoteVar.CreatedDate.date();

                    for (Integer i = 0; i < jobNoteVar.animalos__Content__c.countMatches('</a>'); i++) {
                        String link;
                        if (i == 0) {
                            link = jobNoteVar.animalos__Content__c.substringBetween('<a', '</a>');
                        } else {
                            link = jobNoteVar.animalos__Content__c.substringAfterLast('Link</a>').substringBetween('<a', '</a>');
                        }
                        String linkText = link.substring(link.indexOf('>') + 1);
                        jobNoteVar.animalos__Content__c = jobNoteVar.animalos__Content__c.replace(linkText, 'Link');

                    }
                }
            }

            dtoMap.put('isLast', jobs.indexOf(job) == jobs.size() - 1 ? true : false);
            dtoMap.put('containsArea', !String.isBlank(job.animalos__Area__c) ? true : false);
            dtoMap.put('assignedInspector', assignedInspector != null ? assignedInspector.animalos__Resource__r.Name : '');
            dtoMap.put('hasNotes', jobNotes == null ? false : true);
            dtoMap.put('jobNotes', jobNotes);
            dtoMap.put('hasAnimalReportSummary', String.isNotBlank(job.animalos__Animal_Report_Summary__c));
            dtoMap.put('hasInformants', informants.size() > 0);
            dtoMap.put('informants', informants);
            dtoMap.put('hasPOIs', POIs.size() > 0);
            dtoMap.put('POIs', POIs);
            dtoMap.put('hasOtherJobContacts', others.size() > 0);
            dtoMap.put('otherJobContacts', others);
            dtoMap.put('POIDescription', POIDescription);
        }

        private List<Object> relatedJobsListToMap(List<animalos__Job__c> relatedJobs, Map<String, Object> assignedInspectorsByJobId) {

            List<Object> mappedJobs = new List<Object>();

            for (animalos__Job__c jobVar : relatedJobs) {
                Map<String, Object> mappedJob = new Map<String, Object>();

                mappedJob.put('jobNumber', jobVar.Name);

                if (jobVar.animalos__Start_Date__c != null) {
                    TimeZone tz = UserInfo.getTimeZone();
                    mappedJob.put('animalos__Start_Date__c', jobVar.animalos__Start_Date__c + tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0));
                } else {
                    mappedJob.put('animalos__Start_Date__c', '');
                }

                mappedJob.put('animalos__Codes__c', String.isBlank(jobVar.animalos__Codes__c) ? '' : jobVar.animalos__Codes__c);
                // mappedJob.put('Outcome_Notes__c', String.isBlank(jobVar.Outcome_Notes__c) ? '' : jobVar.Outcome_Notes__c);

                animalos__Assigned_Resource__c assignedInspectorVar = (animalos__Assigned_Resource__c) assignedInspectorsByJobId.get(jobVar.Id);
                mappedJob.put('assignedInspector', assignedInspectorVar == null ? '' : assignedInspectorVar.animalos__Resource__r.Name);

                mappedJobs.add(mappedJob);
            }

            return mappedJobs;
        }
    }
}