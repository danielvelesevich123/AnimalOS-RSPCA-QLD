public class aos_AnimalsNearbyMetaProc extends aos_MetadataProcessor implements Database.AllowsCallouts {

    Set<String> animalReferralFields = new Set<String>{
            'animalos__Animal__r.Id',
            'animalos__Animal__r.Name',
            'animalos__Animal__r.animalos__Type__c',
            'animalos__Job__c'
    };

    Set<String> jobFields = new Set<String>{
            'Id',
            'Name',
            'CreatedDate',
            'animalos__Full_Address__c',
            'animalos__Address__c',
            'animalos__Address__Latitude__s',
            'animalos__Address__Longitude__s',
            'animalos__Address__Street__s',
            'animalos__Address__City__s',
            'animalos__Address__StateCode__s',
            'animalos__Address__PostalCode__s',
            'animalos__Address__CountryCode__s',
            'animalos__Description__c',
            'animalos__Status__c',
            'animalos__Advisory__c',
            'OwnerId',
            'Owner.Name'
    };

    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

        super.process(this.request);

        this.doInit();

        return this.response;
    }

    private void doInit() {
        String recordId = this.request.getRequiredString('recordId');
        Decimal distance = this.request.getDecimal('distance') == null ? 1 : this.request.getDecimal('distance');
        String animalStatusFilter = this.request.getString('animalStatusFilter');

        animalos__Job__c jobVar = (animalos__Job__c) aos_Utils.arrays.firstOrException([
                SELECT Id, animalos__Full_Address__c, animalos__Address__c, animalos__Address__Longitude__s, animalos__Address__Latitude__s,
                        animalos__Address__StateCode__s, animalos__Address__PostalCode__s, animalos__Address__CountryCode__s, animalos__Address__Street__s,
                        animalos__Address__City__s, Name, animalos__Description__c
                FROM animalos__Job__c
                WHERE Id = :recordId
        ]);

        List<String> animalReferralConditions = new List<String>();

        if (String.isNotBlank(animalStatusFilter)) {
            animalStatusFilter = '\'' + String.join(animalStatusFilter.split(','), '\',\'') + '\'';
            animalReferralConditions.add('(animalos__Animal__r.animalos__Status__c IN (' + animalStatusFilter + '))');
        }

        aos_QueryFactory jobsSOQL = new aos_QueryFactory(animalos__Job__c.SObjectType)
                .selectFields(this.jobFields)
                .setCondition('(DISTANCE(animalos__Address__c, :jobAddress, \'km\') < :distance) AND Id != :recordId');

        jobsSOQL.subselectQuery(animalos__Animal_Referral__c.SObjectType)
                .selectFields(this.animalReferralFields)
                .setCondition(String.join(animalReferralConditions, ' AND '));


        List<animalos__Job__c> jobs = Database.queryWithBinds(jobsSOQL.toSOQL(), new Map<String, Object>{
                'jobAddress' => jobVar.animalos__Address__c,
                'recordId' => recordId,
                'distance' => distance
        }, AccessLevel.USER_MODE);

        //leave only jobs with referrals
        List<animalos__Job__c> jobsWithReferrals = new List<animalos__Job__c>();
        for (animalos__Job__c jobItem : jobs) {
            if (jobItem.animalos__Animal_Referrals__r != null && !jobItem.animalos__Animal_Referrals__r.isEmpty()) {
                jobsWithReferrals.add(jobItem);
            }
        }

        this.response.getMapper()
                .mapFromListSObjects('jobs', jobsWithReferrals)
                .mapFromSObject('currentJob', jobVar);
    }
}