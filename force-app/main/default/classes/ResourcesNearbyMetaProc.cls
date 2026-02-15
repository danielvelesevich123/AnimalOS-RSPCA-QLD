public class ResourcesNearbyMetaProc extends vertic_MetadataProcessor implements Database.AllowsCallouts {

    Set<String> resourceFields = new Set<String>{
            'Id',
            'Contact__r.Id',
            'Contact__c',
            'Contact__r.Name',
            'Contact__r.Account.Name',
            'Contact__r.Account.Id',
            'Contact__r.AccountId',
            'Contact__r.Phone',
            'Contact__r.Email',
            'Contact__r.MobilePhone',
            'aos_Current_Location__c',
            'aos_Current_Location__Latitude__s',
            'aos_Current_Location__Longitude__s',
            'aos_Current_Location__Street__s',
            'aos_Current_Location__City__s',
            'aos_Current_Location__StateCode__s',
            'aos_Current_Location__PostalCode__s',
            'aos_Current_Location__CountryCode__s',
            'Name',
            'aos_Full_Current_Location__c'
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
                SELECT Id, animalos__Full_Address__c, animalos__Address__c,
                        animalos__Address__Latitude__s, animalos__Address__Longitude__s, animalos__Address__Street__s,
                        animalos__Address__City__s, animalos__Address__StateCode__s, animalos__Address__PostalCode__s,
                        animalos__Address__CountryCode__s,
                        animalos__Description__c, Name
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

        vertic_DTO resourcesDTO = new vertic_DTO();
        resourcesDTO.getMapper().mapFromListSObjects('resources', resourcesToRender);


        for (vertic_DTO resourceDTO : resourcesDTO.getDTOs('resources')) {
            resourceDTO.put('distance', ((Decimal) Location.getDistance(
                    Location.newInstance(jobVar.animalos__Address__Latitude__s, jobVar.animalos__Address__Longitude__s),
                    Location.newInstance(resourceDTO.getDecimal('aos_Current_Location__Latitude__s'), resourceDTO.getDecimal('aos_Current_Location__Longitude__s')),
                    'km'
            )).setScale(2) + 'km');
        }

        this.response.addSelectOptions('skillsOptions', vertic_Utils.sObjects.toSelectOptions([SELECT Id, Name FROM animalos__Skill__c], 'Name', 'Name'));
        this.response.getMapper()
                .mapAnyValue('resources', resourcesDTO.get('resources'))
                .mapFromSObject('jobVar', jobVar);
    }
}