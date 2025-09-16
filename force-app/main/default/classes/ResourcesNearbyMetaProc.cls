public class ResourcesNearbyMetaProc extends vertic_MetadataProcessor implements Database.AllowsCallouts {

    Set<String> resourceFields = new Set<String>{
            'Id',
            'animalos__Contact__r.Id',
            'animalos__Contact__r.Name',
            'animalos__Contact__r.Account.Name',
            'animalos__Contact__r.Phone',
            'animalos__Contact__r.Email',
            'animalos__Contact__r.MobilePhone',
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
        List<String> selectedSkillsList = new List<String>();
        if (String.isNotBlank(selectedSkills)) {
            selectedSkillsList = selectedSkills.split(';');
        }

        fflib_QueryFactory resourcesSOQL = new fflib_QueryFactory(animalos__Resource__c.SObjectType)
                .selectFields(this.resourceFields)
                .setCondition(String.join(conditions, ' AND '));


        resourcesSOQL.subselectQuery(animalos__Resource_Skill__c.SObjectType)
                .selectFields(new Set<String>{
                        'Name',
                        'animalos__Skill__r.Name'
                });


        List<animalos__Resource__c> resources = Database.queryWithBinds(resourcesSOQL.toSOQL(), new Map<String, Object>{
                'jobVarAddress' => jobVarAddress,
                'distance' => distance
        }, AccessLevel.USER_MODE);

        List<animalos__Resource__c> resourcesToRender = new List<animalos__Resource__c>();

        for (animalos__Resource__c res : resources) {
            if (!selectedSkillsList.isEmpty()) {
                Boolean hasSkills = res.animalos__Resource_Skills__r != null && !res.animalos__Resource_Skills__r.isEmpty();

                if (hasSkills) {
                    Set<String> existingSkillsNames = new Set<String>();

                    for (animalos__Resource_Skill__c resSkill : res.animalos__Resource_Skills__r) {
                        existingSkillsNames.add(resSkill.animalos__Skill__r.Name);
                    }

                    for (String skillName : selectedSkillsList) {
                        if (!existingSkillsNames.contains(skillName)) {
                            hasSkills = false;
                            break;
                        }
                    }
                }

                if (hasSkills) {
                    resourcesToRender.add(res);
                }
            } else {
                resourcesToRender.add(res);
            }
        }

        this.response.addSelectOptions('skillsOptions', vertic_Utils.sObjects.toSelectOptions([SELECT Id, Name FROM animalos__Skill__c], 'Name', 'Name'));
        this.response.getMapper().mapAnyValue('resources', resourcesToRender);
    }
}