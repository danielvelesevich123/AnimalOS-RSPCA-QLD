public class RetrieveSheltersGetProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    Set<String> locationFields = new Set<String>{
        'Name',
        'aos_Street_Address__c',
        'aos_Operating_Hours__c',
        'aos_Site_Phone__c',
        'aos_State__c',
        'aos_Suburb__c',
        'aos_Postcode__c',
        'aos_AdoptAPet_Location_Name__c',
        'aos_Monday_Open__c',
        'aos_Monday_Close__c',
        'aos_Tuesday_Open__c',
        'aos_Tuesday_Close__c',
        'aos_Wednesday_Open__c',
        'aos_Wednesday_Close__c',
        'aos_Thursday_Open__c',
        'aos_Thursday_Close__c',
        'aos_Friday_Open__c',
        'aos_Friday_Close__c',
        'aos_Saturday_Open__c',
        'aos_Saturday_Close__c',
        'aos_Sunday_Open__c',
        'aos_Sunday_Close__c',
        'aos_Online_Adoptions__c',
        'aos_AdoptAPet_Location_Ranking__c'
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