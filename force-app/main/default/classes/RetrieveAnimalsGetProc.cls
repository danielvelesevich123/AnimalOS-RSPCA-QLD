public class RetrieveAnimalsGetProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    final Set<String> animalFields = new Set<String>{
            'Adaptability__c',
            'animalos__Adoption_Profile__c',
            'Adopter_Experience__c',
            'Adoption_EOI_Required__c',
            'animalos__Adoption_Fee__c',
            'Age_Restriction__c',
            'Age_for_Adoption_Website__c',
            'animalos__Primary_Breed__r.Id',
            'animalos__Primary_Breed__r.Name',
            'animalos__Class__c',
            'animalos__Current_Block__c',
            'animalos__Current_Block__r.Name',
            'animalos__Current_Site__c',
            'animalos__Current_Site__r.Name',
            'animalos__Current_Unit__c',
            'animalos__Current_Unit__r.Name',
            'Dog_Sociability__c',
            'Gallery_Updated_Date__c',
            'Home_Requirements__c',
            'Indoors_Outdoors_Preference__c',
            'LastModifiedDate',
            'Lifestyle__c',
            'animalos__Microchip_Number__c',
            'Name',
            'Other_Animals__c',
            'animalos__Primary_Colour__c',
            'animalos__Secondary_Breed__r.Id',
            'animalos__Secondary_Breed__r.Name',
            'animalos__Secondary_Colour__c',
            'Special_Needs_Animal__c',
            'animalos__Status_Changed_Date__c',
            'animalos__Animal_Name__c',
            'animalos__Status__c',
            'animalos__Date_of_Birth__c',
            'animalos__Gender__c',
            'animalos__Neutered_Spayed__c',
            'animalos__Size__c',
            'animalos__Type__c',
            'Senior_Pet__c',
            'Longterm_Resident__c',
            'animalos__Days_at_Site__c',
            'animalos__Days_in_Status__c',
            'Fencing_Requirements__c',
            'General_Requirements__c',
            'Activity_level_playfulness__c',
            'Cat_Home_Requirements__c',
            'About_Me_Adoptapet__c'
    };

    final Set<String> oneDriveFileFields = new Set<String>{
            'Id',
            'Name',
            'Is_Primary__c',
            'Is_Deleted__c',
            'Folder_Name__c',
            'File_Link__c',
            'File_ID__c',
            'Web_URL__c'
    };

    final Set<String> supportRequestFields = new Set<String>{
            'Id',
            'Request_Status__c'
    };

    public override vertic_Response process(vertic_Request request) {
        this.request = (vertic_RestService.Request) request;
        this.response = (vertic_RestService.Response) super.response;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {

        fflib_QueryFactory queryFactory = new fflib_QueryFactory(animalos__Animal__c.SObjectType)
                .selectFields(this.animalFields);

        Datetime lastModifiedDate;
        String dateTimeString;
        Integer queryLimit = String.isBlank(request.params.get('Limit')) ? null : Integer.valueOf(request.params.get('Limit'));

        if (String.isNotBlank(request.params.get('LastModifiedDate'))) {
            dateTimeString = request.params.get('LastModifiedDate');
            if (String.isNotBlank(request.params.get('Time'))) {
                dateTimeString += 'T' + request.params.get('Time') + ':00.000Z';
            } else {
                dateTimeString += 'T00:00:00.000Z';
            }
        }

        if (String.isNotBlank(dateTimeString)) {
            lastModifiedDate = (DateTime) json.deserialize('"' + dateTimeString + '"', datetime.class);
        }


        List<String> statuses = new List<String>();
        String animalStatus = request.params.get('AnimalStatus');

        List<String> conditions = new List<String>();
        List<String> totalConditions;

        if (String.isNotBlank(this.request.params.get('AnimalId'))) {
            String animalId = this.request.params.get('AnimalId');
            conditions.add('Id = :animalId');
        } else {
            if (String.isNotBlank(animalStatus)) {
                statuses = animalStatus.split(',');
                conditions.add('animalos__Status__c IN :statuses');
            }

            if (lastModifiedDate != null) {
                conditions.add('LastModifiedDate > :lastModifiedDate');
            }

            if (String.isNotBlank(this.request.params.get('StatusChangedDate'))) {
                conditions.add('animalos__Status_Changed_Date__c > ' + this.request.params.get('StatusChangedDate'));
            }

            if (String.isNotBlank(this.request.params.get('GalleryChangedDate'))) {
                conditions.add('Gallery_Updated_Date__c > ' + this.request.params.get('GalleryChangedDate'));
            }

            totalConditions = conditions.clone();

            if (String.isNotBlank(request.params.get('LastRecordId'))) {
                conditions.add('Id > \'' + request.params.get('LastRecordId') + '\'');
            }

            if (queryLimit != null) {
                queryFactory.setLimit(queryLimit);
            }
        }

        if (!conditions.isEmpty()) {
            queryFactory.setCondition(String.join(conditions, ' AND '));
        }

        queryFactory.setOrdering(animalos__Animal__c.Id, fflib_QueryFactory.SortOrder.ASCENDING);

        List<String> oneDriveFilesCondition = new List<String>();
        oneDriveFilesCondition.add('Is_Public__c = TRUE');
        oneDriveFilesCondition.add('Folder_Name__c LIKE \'%PHOTO%\'');
        oneDriveFilesCondition.add('Is_Deleted__c = FALSE');

        queryFactory.subselectQuery(OneDrive_File__c.SObjectType)
                .selectFields(this.oneDriveFileFields).setCondition(String.join(oneDriveFilesCondition, ' AND '));

        List<String> supportRequestConditions = new List<String>{
                'RecordType.DeveloperName = \'Foster_Care_Request\''
        };

        queryFactory.subselectQuery(Support_Request__c.SObjectType)
                .selectFields(this.supportRequestFields)
                .setCondition(String.join(supportRequestConditions, ' AND '))
                .setOrdering(Support_Request__c.CreatedDate, fflib_QueryFactory.SortOrder.DESCENDING, true)
                .setLimit(1);

        List<animalos__Animal__c> animals = Database.query(queryFactory.toSOQL());

        Integer recordsLeft = (Integer) Database.countQuery(('SELECT COUNT() FROM animalos__Animal__c WHERE ' + String.join(conditions, ' AND '))) - (queryLimit == null ? 0 : queryLimit);
        this.response.put('animals', animals);

        if (String.isBlank(this.request.params.get('AnimalId'))) {
            Integer totalNumberOfRecords = (Integer) Database.countQuery(('SELECT COUNT() FROM animalos__Animal__c WHERE ' + String.join(totalConditions, ' AND ')));
            this.response.put('recordsLeft', recordsLeft < 0 || String.isBlank(request.params.get('Limit')) ? 0 : recordsLeft);
            this.response.put('totalNumberOfRecords', totalNumberOfRecords);
        }
    }


    private vertic_RestService.Response response;

    protected override vertic_Response getResponseInstance() {
        return new vertic_RestService.Response();
    }

    /** ============================================================================================================= */

    private vertic_RestService.Request request;
}