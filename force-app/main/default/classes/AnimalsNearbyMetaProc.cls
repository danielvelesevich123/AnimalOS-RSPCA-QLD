public class AnimalsNearbyMetaProc extends vertic_MetadataProcessor implements Database.AllowsCallouts {

    Set<String> animalReferralFields = new Set<String>{
            'animalos__Animal__r.Id',
            'animalos__Animal__r.Name',
            'animalos__Animal__r.animalos__Type__c',
            'animalos__Job__c',
            'animalos__Job__r.Name',
            'animalos__Job__r.CreatedDate',
            'animalos__Job__r.animalos__Full_Address__c',
            'animalos__Job__r.animalos__Advisory__c',
            'animalos__Job__r.animalos__Status__c',
            'animalos__Job__r.OwnerId',
            'animalos__Job__r.Owner.Name'
    };

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        super.process(this.request);

        this.doInit();

        return this.response;
    }

    private void doInit() {
        String recordId = this.request.getRequiredString('recordId');
        Decimal distance = this.request.getDecimal('distance') == null ? 1 : this.request.getDecimal('distance');
        String animalStatusFilter = this.request.getString('animalStatusFilter');

        animalos__Job__c jobVar = (animalos__Job__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, animalos__Full_Address__c, animalos__Address__c
                FROM animalos__Job__c
                WHERE Id = :recordId
        ]);

        List<animalos__Job__c> jobsNearby = [
                SELECT Id
                FROM animalos__Job__c
                WHERE DISTANCE(animalos__Address__c, :jobVar.animalos__Address__c, 'km') < :distance
                AND Id != :recordId
        ];

        Set<Id> jobsNearByIds = vertic_Utils.sObjects.getIdFieldValues(jobsNearby, animalos__Job__c.Id);

        List<String> conditions = new List<String>{
                '(animalos__Job__c IN :jobsNearByIds)'
        };

        if (String.isNotBlank(animalStatusFilter)) {
            animalStatusFilter = '\'' + String.join(animalStatusFilter.split(','), '\',\'') + '\'';
            conditions.add('(animalos__Animal__r.animalos__Status__c IN (' + animalStatusFilter + '))');
        }

        String animalReferralSOQL = new fflib_QueryFactory(animalos__Animal_Referral__c.SObjectType)
                .selectFields(animalReferralFields)
                .setCondition(String.join(conditions, ' AND '))
                .toSOQL();

        List<animalos__Animal_Referral__c> animalReferrals = Database.query(animalReferralSOQL);
        Set<Id> jobIds = vertic_Utils.sObjects.getIdFieldValues(animalReferrals, animalos__Animal_Referral__c.animalos__Job__c);

        List<List<SObject>> animalReferralsByJobs = new List<List<SObject>>();
        Map<String, List<SObject>> animalReferralsByJobIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap(animalReferrals, animalos__Animal_Referral__c.animalos__Job__c);

        for(String jobId : animalReferralsByJobIds.keySet()) {
            animalReferralsByJobs.add(animalReferralsByJobIds.get(jobId));
        }

        this.response.getMapper().mapAnyValue('animalReferralsByJobs', animalReferralsByJobs);
    }
}