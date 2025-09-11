public class ResourcesNearbyMetaProc extends vertic_MetadataProcessor implements Database.AllowsCallouts {

    Set<String> resourceFields = new Set<String>{
            'animalos__User__r.Id',
            'animalos__User__r.Name',
            'animalos__User__r.CompanyName',
            'animalos__User__r.Phone',
            'animalos__User__r.Email',
            'animalos__User__r.MobilePhone',
            'Current_Location__c'
    };

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        super.process(this.request);

        this.doInit();

        return this.response;
    }

    private void doInit() {
        String recordId = this.request.getRequiredString('recordId');

        animalos__Job__c jobVar = (animalos__Job__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, animalos__Full_Address__c, animalos__Address__c
                FROM animalos__Job__c
                WHERE Id = :recordId
                AND animalos__Address__Latitude__s != NULL
                AND animalos__Address__Longitude__s != NULL
                LIMIT 1
        ]);

        Decimal distance = this.request.getDecimal('distance') == null ? 1 : this.request.getDecimal('distance');
        Address jobVarAddress = jobVar.animalos__Address__c;
        List<String> conditions = new List<String>{
                '(DISTANCE(Current_Location__c, :jobVarAddress, \'km\') < :distance)',
                'animalos__Active__c = true',
                'animalos__User__c != null'
        };

        String selectedSkills = this.request.getString('selectedSkills');
        if (String.isNotBlank(selectedSkills)) {
            selectedSkills = '\'' + String.join(selectedSkills.split(','), '\',\'') + '\'';
            conditions.add(('Id IN (SELECT animalos__Resource__c FROM animalos__Resource_Skill__c WHERE animalos__Skill__r.Name IN (' + selectedSkills + '))'));
        }

        fflib_QueryFactory resourcesSOQL = new fflib_QueryFactory(animalos__Resource__c.SObjectType)
                .selectFields(this.resourceFields)
                .setCondition(String.join(conditions, ' AND '));


        resourcesSOQL.subselectQuery(animalos__Resource_Skill__c.SObjectType)
                .selectFields(new Set<String>{
                        'animalos__Skill__r.Name'
                });


        System.debug(resourcesSOQL.toSOQL());
        this.response.addSelectOptions('skillsOptions', vertic_Utils.sObjects.toSelectOptions([SELECT Id, Name FROM animalos__Skill__c], 'Name', 'Name'));
        this.response.getMapper().mapAnyValue('resources', Database.queryWithBinds(resourcesSOQL.toSOQL(), new Map<String, Object>{
                'jobVarAddress' => jobVarAddress,
                'distance' => distance
        }, AccessLevel.USER_MODE));
    }
}


