public class DownloadJobActivitiesQAMetaProc extends vertic_MetadataProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                // SObject Fields, e.g. Contact.Salutation
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        this.initComponents();
    }

    private void initComponents() {
        String jobId = this.request.getRequiredString('jobId');

        List<Object> components = new List<Object>();
        Map<String, Object> dto = new Map<String, Object>();

        animalos__Job__c job = (animalos__Job__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, Name, CreatedDate, Owner.Name,
                        animalos__Area__r.Name, animalos__Codes__c, animalos__Priority__c
                FROM animalos__Job__c
                WHERE Id = :jobId
        ]);


//        Routine_Inspection__c, Action__c, Contact.Name, WorkType.Name,Inspector_Name__c,FSL__Auto_Schedule__c,
//                        Sheltermate_User__c, FSL__Schedule_Mode__c, FSL__Scheduling_Policy_Used__r.Name,
        List<animalos__Job_Activity__c> inspectorateActivities = [
                SELECT
                        Id, Name, animalos__Status__c, animalos__Subject__c, animalos__Description__c, animalos__Services_Provided__c, animalos__Written_Directions__c,
                        animalos__Address__Street__s, animalos__Address__City__s, animalos__Address__StateCode__s, animalos__Activity_Note__c,
                        animalos__Start_Date_Time__c, animalos__End_Date_Time__c, animalos__Type_of_Work__c, CreatedBy.Name, LastModifiedBy.Name,
                        animalos__Job__r.animalos__Area__r.Name, animalos__Notebook_Number__c, animalos__Page_Number__c, animalos__Job__r.Owner.Name,
                        animalos__Awaiting_Response__c, animalos__Recheck__c, (
                        SELECT Id, animalos__Resource__r.Name
                        FROM animalos__Assigned_Resources__r
                )
                FROM animalos__Job_Activity__c
                WHERE animalos__Job__c = :job.Id
        ];

        for (animalos__Job_Activity__c inspectorateActivity : inspectorateActivities) {
            Set<String> inspectorNames = new Set<String>();
            inspectorNames.add(inspectorateActivity.animalos__Job__r.Owner.Name);

            for (animalos__Assigned_Resource__c assignedInspector : inspectorateActivity.animalos__Assigned_Resources__r) {
                inspectorNames.add(assignedInspector.animalos__Resource__r.Name);
            }

            dto.put(inspectorateActivity.Id, String.join(inspectorNames, ', '));
        }

        List<animalos__Job_Contact__c> personsOfInterest = [
                SELECT Id, Name, animalos__Contact_Type__c,
                        animalos__Contact__r.Name, animalos__Contact__r.MobilePhone,
                        animalos__Contact__r.Email, animalos__Contact__r.Full_Address__c
                FROM animalos__Job_Contact__c
                WHERE animalos__Job__c = :job.Id AND animalos__Contact_Type__c = 'Person Of Interest'
        ];

        dto.put('job', job);
        dto.put('inspectorateActivities', inspectorateActivities);
        dto.put('numberOfInspectorateActivities', inspectorateActivities.size());
        dto.put('personsOfInterest', personsOfInterest);
        dto.put('numberOfPersonsOfInterest', personsOfInterest.size());

        components.add(new Component.JobActivitiesSummary(
                dto = dto
        ));

        if(ApexPages.currentPage() != null) {
            ApexPages.currentPage()
                    .getHeaders()
                    .put('content-disposition', 'filename=' + 'Inspectorate Activities - ' + job.Name + '.pdf');
        }

        this.response.dto.put('components', components);
        this.response.dto.put('head-component', new Component.JobActivitiesSummaryStyles());
    }
}