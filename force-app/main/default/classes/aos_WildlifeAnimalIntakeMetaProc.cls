public with sharing class aos_WildlifeAnimalIntakeMetaProc extends aos_MetadataProcessor {

    private Set<String> animalLookupFields = new Set<String>{
            'animalos__Animal_Name__c',
            'animalos__Class__c',
            'animalos__Gender__c',
            'animalos__Type__c',
            'animalos__Primary_Breed__c',
            'animalos__Primary_Breed__r.Name',
            'animalos__Secondary_Breed__c',
            'animalos__Secondary_Breed__r.Name',
            'animalos__Primary_Colour__c',
            'animalos__Secondary_Colour__c',
            'animalos__Stage__c',
            'animalos__Status__c',
            'animalos__Age_Group__c',
            'animalos__Shelter_ID__c',
            'aos_KRS_Number__c'
    };

    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                animalos__Animal__c.animalos__Class__c,
                animalos__Animal__c.animalos__Primary_Colour__c,
                animalos__Animal__c.animalos__Secondary_Colour__c,
                animalos__Animal__c.animalos__Gender__c,
                animalos__Animal__c.animalos__Type__c,
                animalos__Animal__c.animalos__Age_Group__c,
                animalos__Movement__c.animalos__Movement_Reason__c
        };

        this.request.dependentFieldsBySObjectType = new Map<SObjectType, Map<SObjectField, SObjectField>>{
                animalos__Animal__c.SObjectType => new Map<SObjectField, SObjectField>{
                        animalos__Animal__c.animalos__Status__c => animalos__Animal__c.animalos__Stage__c,
                        animalos__Animal__c.animalos__Type__c => animalos__Animal__c.animalos__Class__c,
                        animalos__Animal__c.animalos__Age_Group__c => animalos__Animal__c.animalos__Type__c
                }
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {

        animalos__Referral__c referral = new animalos__Referral__c();
        this.request.getMapper().mapToSObject('referral', referral);
        this.response.getMapper().mapFromSObject('referral', referral);

        String referralRecordTypeDeveloperName = aos_Utils.sObjects.recordTypeAPINameById(animalos__Referral__c.SObjectType, referral.RecordTypeId) ?? '';
        aos_Utils.strings.throwIfBlank(referralRecordTypeDeveloperName, 'Referral Record Type is required.');

        this.response.put('animalLookupFields', String.join(new List<String>(this.animalLookupFields), ', '));
        this.response.put('hasEnhancedAccess', this.hasEnhancedAccess());
        this.response.put('recordTypeDeveloperName', referralRecordTypeDeveloperName);
        this.response.selectOptions.put('animalosStageOptions', aos_Utils.picklists.getPicklistValuesAsSelectOptions(animalos__Animal__c.animalos__Stage__c));

        animalos__Setting__c startReferralSetting = (animalos__Setting__c) aos_Utils.arrays.firstOrNull([
                SELECT Id, animalos__Setting__c
                FROM animalos__Setting__c
                WHERE RecordType.DeveloperName = 'Start_Referral'
                WITH USER_MODE
        ]);

        if (startReferralSetting == null || String.isBlank(startReferralSetting.animalos__Setting__c)) {
            return;
        }

        aos_DTO settingDTO = new aos_DTO(startReferralSetting.animalos__Setting__c);

        String blockCondition = settingDTO.getString('blockCondition');

        if (String.isNotBlank(blockCondition)) {
            List<String> conditions = new List<String>{
                    'RecordType.DeveloperName = \'Block\''
            };

            conditions.add(aos_Utils.templates.compose(blockCondition, referral.getPopulatedFieldsAsMap(), false));

            animalos__Location__c blockLocation = (animalos__Location__c) aos_Utils.arrays.firstOrNull(
                    Database.query(new aos_QueryFactory(animalos__Location__c.SObjectType)
                            .setCondition(String.join(conditions, ' AND '))
                            .setLimit(1)
                            .toSOQL()
                    )
            );

            if (blockLocation != null) {
                this.response.put('defaultBlock', blockLocation.Id);
            }

        }

        List<String> inboundRecordTypes = settingDTO.getListAsStrings('inboundRecordTypes');
        Boolean isInboundRecordType = (inboundRecordTypes == null)
                || (inboundRecordTypes != null && !inboundRecordTypes.isEmpty() && inboundRecordTypes.contains(referralRecordTypeDeveloperName));

        this.response.put('isInboundRecordType', isInboundRecordType);

        if (isInboundRecordType) {
            this.response.selectOptions.put('animalosStageOptions', aos_Utils.picklists.getPicklistValuesAsSelectOptions(
                    animalos__Animal__c.animalos__Stage__c,
                    new Set<String>{
                            'Out'
                    })
            );
        }

        this.initAnimalAdditionalFields(settingDTO.getDTO('additionalFields'), referralRecordTypeDeveloperName);
        this.initAnimalReferralAdditionalFields(settingDTO.getDTO('animalReferralFields'), referralRecordTypeDeveloperName);
    }

    private void initAnimalAdditionalFields(aos_DTO fieldsSettingDTO, String referralRecordTypeDeveloperName) {
        Map<String, Map<String, Object>> animalFieldsMap = aos_Utils.sObjects.getFieldsInfo(animalos__Animal__c.SObjectType);
        List<Map<String, Object>> additionalFieldsInfo = new List<Map<String, Object>>();
        List<aos_DTO> animalAdditionalFields = fieldsSettingDTO.get(referralRecordTypeDeveloperName) == null ?
                fieldsSettingDTO.getDTOs('default') :
                fieldsSettingDTO.getDTOs(referralRecordTypeDeveloperName);

        for (aos_DTO fieldSettingMap : animalAdditionalFields) {
            if (animalFieldsMap.containsKey(fieldSettingMap.getRequiredString('field'))) {
                this.animalLookupFields.add(fieldSettingMap.getString('field'));
                Map<String, Object> fieldMap = (animalFieldsMap.get(fieldSettingMap.getString('field'))).clone();
                additionalFieldsInfo.add(this.initField(fieldMap, fieldSettingMap.getMap()));
            }
        }

        this.response.put('additionalFields', additionalFieldsInfo);
        this.response.put('animalLookupFields', String.join(new List<String>(this.animalLookupFields), ', '));
    }

    private void initAnimalReferralAdditionalFields(aos_DTO fieldsSettingDTO, String referralRecordTypeDeveloperName) {
        Map<String, Map<String, Object>> animalReferralFieldsMap = aos_Utils.sObjects.getFieldsInfo(animalos__Animal_Referral__c.SObjectType);
        List<Map<String, Object>> animalReferralFieldsInfo = new List<Map<String, Object>>();
        List<aos_DTO> fieldsSetting = fieldsSettingDTO.get(referralRecordTypeDeveloperName) == null ?
                fieldsSettingDTO.getDTOs('default') :
                fieldsSettingDTO.getDTOs(referralRecordTypeDeveloperName);

        for (aos_DTO fieldSettingMap : fieldsSetting) {
            if (animalReferralFieldsMap.containsKey(fieldSettingMap.getRequiredString('field'))) {
                Map<String, Object> fieldMap = (animalReferralFieldsMap.get(fieldSettingMap.getString('field'))).clone();
                animalReferralFieldsInfo.add(this.initField(fieldMap, fieldSettingMap.getMap()));
            }
        }

        this.response.put('animalReferralFields', animalReferralFieldsInfo);
    }

    private Map<String, Object> initField(Map<String, Object> fieldMap, Map<String, Object> recordTypeFieldSettingMap) {

        for (String attr : recordTypeFieldSettingMap.keySet()) {
            fieldMap.put(attr, recordTypeFieldSettingMap.get(attr));
        }
        fieldMap.put('required', (Boolean) fieldMap.get('required') || (Boolean) recordTypeFieldSettingMap.get('required'));

        if (recordTypeFieldSettingMap.containsKey('defaultValue')) {
            String defaultValueMergeField = String.valueOf(recordTypeFieldSettingMap.get('defaultValue'));

            switch on defaultValueMergeField {
                when '{!NOW}' {
                    fieldMap.put('defaultValue', Datetime.now());
                }
                when '{!TODAY}' {
                    fieldMap.put('defaultValue', Date.today());
                }
            }
        }
        return fieldMap;
    }

    public Boolean hasEnhancedAccess() {
        return [
                SELECT COUNT()
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
                AND PermissionSet.Name = 'AnimalOS_Start_Referral_Enhanced_Access'
        ] > 0;
    }
}