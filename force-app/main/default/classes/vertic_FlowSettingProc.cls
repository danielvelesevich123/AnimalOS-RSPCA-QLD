public inherited sharing class vertic_FlowSettingProc extends vertic_FlowProc {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private Flow_Setting__mdt flowSetting;

    public vertic_FlowSettingProc() {
    }

    private void doSubmit() {

        if (this.request.has('setting')) {
            this.flowSetting = new Flow_Setting__mdt();
            this.request.getMapper().mapToSObject('setting', this.flowSetting);
        } else {
            this.retrieveFlowSetting();
        }

        this.mapInputs();
        this.processCalloutFlow();
        this.mapOutputs();

        if (String.isBlank(this.flowSetting.Flow_API_Name__c)) {
            return;
        }

        this.request.getMap().putAll(new WOSH().queryFlowDefinitionView(this.flowSetting.Flow_API_Name__c));

        Boolean isCheckOnly = this.request.getBoolean('checkOnly') == true;

        Savepoint savepointVar;
        try {
            savepointVar = Database.setSavepoint();
            super.process(request);
        } catch (Exception ex) {
            if (savepointVar != null) {
                Database.rollback(savepointVar);
                savepointVar = null;
            }
            throw ex;
        } finally {
            if (isCheckOnly == true && savepointVar != null) {
                Database.rollback(savepointVar);
            }
        }

    }

    private void processCalloutFlow() {
        if (String.isNotBlank(this.flowSetting.Callout_Flow_API_Name__c)) {

            Map<String, Object> inputsMap = (Map<String, Object>) this.request.get('inputs');

            Map<String, Object> params = new Map<String, Object>{
                    'inputs' => inputsMap,
                    'outputFields' => mapOutputs(this.flowSetting.Callout_Output__c)
            };

            params.putAll(new WOSH().queryFlowDefinitionView(this.flowSetting.Callout_Flow_API_Name__c));

            vertic_Response calloutFlowResponseVar = new vertic_FlowProc().process(params);

            inputsMap.putAll(calloutFlowResponseVar.getMap());
            this.request.put('inputs', inputsMap);
        }
    }

    private static FlowDefinitionView getFlowInterviewVar(String flowAPIName) {
        FlowDefinitionView flowInterviewVar = (FlowDefinitionView) vertic_Utils.arrays.firstOrException(
                [SELECT Id, ApiName, NamespacePrefix FROM FlowDefinitionView WHERE ApiName = :flowAPIName],
                'No FlowInterview with ApiName: ' + flowAPIName
        );
        return flowInterviewVar;
    }

    private void retrieveFlowSetting() {

        String flowSettingId = this.request.getString('settingId');
        String flowSettingName = this.request.getString('settingName');
        String settingNamespace = this.request.getString('settingNamespace');

        fflib_QueryFactory queryFactory = new fflib_QueryFactory(Flow_Setting__mdt.SObjectType);
        queryFactory.selectFields(new Set<SObjectField>{
                Flow_Setting__mdt.Flow_API_Name__c,
                Flow_Setting__mdt.Input__c,
                Flow_Setting__mdt.Output__c,
                Flow_Setting__mdt.Callout_Flow_API_Name__c,
                Flow_Setting__mdt.Callout_Output__c
        });

        if (String.isNotBlank(flowSettingId)) {
            queryFactory.setCondition('Id = :flowSettingId');
            this.flowSetting = (Flow_Setting__mdt) vertic_Utils.arrays.firstOrException(
                    Database.query(queryFactory.toSOQL()), // CRUD/FLS/Query/Sharing False Positive: This class should have a system permission to query Flow Setting metadata type.
                    'Flow Setting with Id ' + flowSettingId + ' not found.'
            );
        } else if (String.isNotBlank(flowSettingName)) {
            queryFactory.setCondition('DeveloperName = :flowSettingName AND NamespacePrefix = :settingNamespace');
            this.flowSetting = (Flow_Setting__mdt) vertic_Utils.arrays.firstOrException(
                    Database.query(queryFactory.toSOQL()), // CRUD/FLS/Query/Sharing False Positive: This class should have a system permission to query Flow Setting metadata type.
                    vertic_Utils.strings.joinNonBlank(new List<String>{
                            'Flow Setting with API Name ',
                            settingNamespace,
                            flowSettingName,
                            ' not found.'
                    }, ' ')
            );
        } else {
            throw new vertic_Structs.MissingDataException('Flow Setting parameters are missing. Please use the "settingId", "settingNamespace.settingName" or "setting" to init a Flow Setting for processing.');
        }

    }

    private void mapInputs() {
        Map<String, Object> inputsMap = (Map<String, Object>) this.request.get('inputs');
        Map<String, Object> flowSettingInputMap = this.flowSetting.Input__c == null ?
                new Map<String, Object>() :
                (Map<String, Object>) JSON.deserializeUntyped(this.flowSetting.Input__c);

        Map<String, Object> mappedInputs = mapFlowInputs(inputsMap, flowSettingInputMap);
        mappedInputs.put('JSONInput', JSON.serialize(inputsMap));
        this.request.put('inputs', mappedInputs);
    }

    private void mapOutputs() {
        this.request.put('outputFields', mapOutputs(this.flowSetting.Output__c));
    }

    private List<String> mapOutputs(String outputStr) {
        List<String> outputVariables = new List<String>();
        if (String.isNotBlank(outputStr)) {
            outputVariables.addAll(outputStr.split(','));
        }
        return outputVariables;
    }

    @TestVisible
    private static Map<String, Object> mapFlowInputs(Map<String, Object> inputsMap, Map<String, Object> flowSettingInputMap) {
        vertic_DTO inputDTO = new vertic_DTO(inputsMap);
        Map<String, Object> mappedInputsMap = new Map<String, Object>();

        for (String inputVarName : flowSettingInputMap.keySet()) {
            String inputName = inputVarName;

            String valuePath;

            Object inputSetting = flowSettingInputMap.get(inputVarName);
            vertic_DTO inputSettingDTO;
            if (inputSetting instanceof String) {
                valuePath = (String) inputSetting;
                inputSettingDTO = new vertic_DTO();
            } else {
                inputSettingDTO = new vertic_DTO((Map<String, Object>) inputSetting);
                valuePath = inputSettingDTO.getRequiredString('path');
            }

            final Object inputDefault = inputSettingDTO.getString('default');
            final Boolean isTrimValue = inputSettingDTO.has('trimValue') != true ? true : inputSettingDTO.getBoolean('trimValue') == true;
            final Boolean disregardBlankValue = inputSettingDTO.has('disregardBlankValue') != true ? true : inputSettingDTO.getBoolean('disregardBlankValue') == true;

            final String inputType = inputSettingDTO.getString('type');

            Object value = inputDTO.get(valuePath);

            if (vertic_Utils.objects.isBlankValue(value) && inputDefault != null) {
                value = inputDefault;
            }

            if (value instanceof String && value != null && isTrimValue == true) {
                value = ((String) value).trim();
            }

            if (disregardBlankValue == true && vertic_Utils.objects.isBlankValue(value)) {
                continue;
            }

            if (String.isNotBlank(inputType)) {

                if ('Date'.equalsIgnoreCase(inputType)) {
                    String valueStr = value instanceof String ? (String) value : null;
                    String dateFormat = inputSettingDTO.getString('format');
                    if (String.isBlank(dateFormat) || 'ISO'.equalsIgnoreCase(dateFormat)) {
                        dateFormat = 'yyyy-MM-dd';
                    }
                    Date dateVar = String.isBlank(valueStr) ? null :
                            String.isBlank(dateFormat) ?
                                    vertic_Utils.dates.parseDateAusFormat(valueStr) :
                                    vertic_Utils.dates.parseDateAnyFormat(valueStr, dateFormat);

                    value = dateVar == null ? null : vertic_Utils.dates.dateToDateTime(dateVar).format('yyyy-MM-dd');
                } else if ('Datetime'.equalsIgnoreCase(inputType)) {
                    String valueStr = value instanceof String ? (String) value : null;
                    String dateFormat = inputSettingDTO.getString('format');
                    if (String.isBlank(dateFormat) || 'ISO'.equalsIgnoreCase(dateFormat)) {
                        dateFormat = 'yyyy-MM-dd';
                    }
                    DateTime dateTimeVar = String.isBlank(valueStr) ? null :
                            String.isBlank(dateFormat) ?
                                    vertic_Utils.dates.parseDatetimeAusFormat(valueStr) :
                                    vertic_Utils.dates.parseDatetimeAnyFormat(valueStr, dateFormat);

                    value = dateTimeVar == null ? null : dateTimeVar.format('yyyy-MM-dd');
                } else if ('Boolean'.equalsIgnoreCase(inputType)) {

                    String valueStr = value instanceof String ? (String) value : null;

                    if (valueStr != null) {
                        String trueValuesStr = vertic_Utils.objects.defaultIfNull(inputSettingDTO.getString('trueValues'), 'true,yes,1');
                        List<String> trueValues = trueValuesStr.split(',');
                        Set<String> trueValuesFormatted = new Set<String>();
                        for (String val : trueValues) {
                            trueValuesFormatted.add(val.trim().toUpperCase());
                        }
                        value = String.isBlank(valueStr) ? false : trueValuesFormatted.contains(valueStr.trim().toUpperCase());
                    } else if (!(value instanceof Boolean)) {
                        value = false;
                    }
                } else if ('SObject'.equalsIgnoreCase(inputType) && value != null) {
                    String SObjectTypeName = inputSettingDTO.getRequiredString('SObjectType');
                    Schema.SObjectType SObjectTypeVar = Schema.getGlobalDescribe().get(SObjectTypeName);
                    SObject sobjVar = SObjectTypeVar.newSObject();

                    inputDTO.getMapper().mapToSObject(valuePath, sobjVar);
                    value = sobjVar;
                }
            }

            mappedInputsMap.put(inputName, value);
        }
        return mappedInputsMap;
    }

    private without sharing class WOSH {

        private Map<String, Object> queryFlowDefinitionView(String flowAPIName) {
            FlowDefinitionView flowVar = getFlowInterviewVar(flowAPIName);
            return new Map<String, Object>{
                    'flow' => flowVar.ApiName,
                    'namespacePrefix' => flowVar.NamespacePrefix
            };
        }

    }

}