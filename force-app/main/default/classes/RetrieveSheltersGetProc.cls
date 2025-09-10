public class RetrieveSheltersGetProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    Set<String> locationFields = new Set<String>{
        'Name',
        'Street_Address__c',
        'Operating_Hours__c',
        'Site_Phone__c',
        'State__c',
        'Suburb__c',
        'Postcode__c',
        'AdoptAPet_Location_Name__c',
        'Monday_Open__c',
        'Monday_Close__c',
        'Tuesday_Open__c',
        'Tuesday_Close__c',
        'Wednesday_Open__c',
        'Wednesday_Close__c',
        'Thursday_Open__c',
        'Thursday_Close__c',
        'Friday_Open__c',
        'Friday_Close__c',
        'Saturday_Open__c',
        'Saturday_Close__c',
        'Sunday_Open__c',
        'Sunday_Close__c',
        'Online_Adoptions__c',
        'AdoptAPet_Location_Ranking__c'
    };

    public override vertic_Response process(vertic_Request request) {
        this.request = (vertic_RestService.Request) request;
        this.response = (vertic_RestService.Response) super.response;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {

        fflib_QueryFactory queryFactory = new fflib_QueryFactory(animalos__Location__c.SObjectType);
        queryFactory.selectFields(this.locationFields);

        Datetime lastModifiedDate;
        String dateTimeString;

        if (!String.isBlank(request.params.get('LastModifiedDate'))) {
            dateTimeString = request.params.get('LastModifiedDate') + 'T00:00:00.000Z';
        }

        if (!String.isBlank(dateTimeString)) {
            lastModifiedDate = (Datetime) JSON.deserialize('"' + dateTimeString + '"', Datetime.class);
        }

        List<String> conditions = new List<String>();

        conditions.add('(RecordType.DeveloperName = \'Site\' OR RecordType.DeveloperName = \'Offsite\')');

        if (lastModifiedDate != null) {
            conditions.add('LastModifiedDate > :lastModifiedDate');
        }

        if (!conditions.isEmpty()) {
            queryFactory.setCondition(String.join(conditions, ' AND '));
        }

        List<animalos__Location__c> locations = Database.query(queryFactory.toSOQL());

        this.response.getMapper().mapFromListSObjects('locations', locations);

    }


    private vertic_RestService.Response response;

    protected override vertic_Response getResponseInstance() {
        return new vertic_RestService.Response();
    }

    /** ============================================================================================================= */

    private vertic_RestService.Request request;

}