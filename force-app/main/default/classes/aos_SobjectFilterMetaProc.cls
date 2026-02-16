public class aos_SobjectFilterMetaProc extends aos_MetadataProcessor implements Database.AllowsCallouts {

    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

        super.process(this.request);

        this.doInit();
        this.initOperatorOptions();

        return this.response;
    }

    private void doInit() {
        String sobjectApiName = this.request.getRequiredString('sobjectApiName');
        SObjectType sObjectTypeVar = Schema.getGlobalDescribe().get(sobjectApiName);
        Map<String, Map<String, Object>> fieldsInfoMap = aos_Utils.sObjects.getFieldsInfo(sObjectTypeVar);

        Map<String, SObjectField> sObjectFieldByName = sObjectTypeVar.getDescribe().fields.getMap();
        List<aos_Structs.SelectOption> fieldOptions = new List<aos_Structs.SelectOption>();

        for (String fieldName : sObjectFieldByName.keySet()) {
            DescribeFieldResult describeFieldResultVar = sObjectFieldByName.get(fieldName).getDescribe();

            if (!describeFieldResultVar.isAccessible()) {
                fieldsInfoMap.remove(describeFieldResultVar.getName());
                continue;
            }

            if (fieldsInfoMap.containsKey(describeFieldResultVar.getName())) {
                fieldOptions.add(new aos_Structs.SelectOption(
                        describeFieldResultVar.getName(),
                        describeFieldResultVar.getLabel()
                ));
            }
        }

        this.response.addSelectOptions('fieldOptions', fieldOptions);
        this.response.put('fieldsInfoMap', fieldsInfoMap);
    }

    private void initOperatorOptions() {
        this.response.addSelectOptions('operatorLimitedOptions', new List<aos_Structs.SelectOption>{
                new aos_Structs.SelectOption(aos_Service.operator2string(aos_Service.Operator.EQUALS)),
                new aos_Structs.SelectOption(aos_Service.operator2string(aos_Service.Operator.NOT_EQUAL_TO))
        });
        this.response.addSelectOptions('operatorExtendedOptions', this.response.selectOptions.get('operatorLimitedOptions'));
        this.response.addSelectOptions('operatorExtendedOptions', new List<aos_Structs.SelectOption>{
                new aos_Structs.SelectOption(aos_Service.operator2string(aos_Service.Operator.LESS_THAN)),
                new aos_Structs.SelectOption(aos_Service.operator2string(aos_Service.Operator.LESS_OR_EQUAL)),
                new aos_Structs.SelectOption(aos_Service.operator2string(aos_Service.Operator.GREATER_THAN)),
                new aos_Structs.SelectOption(aos_Service.operator2string(aos_Service.Operator.GREATER_OR_EQUAL))
        });
        this.response.addSelectOptions('operatorAllOptions', this.response.selectOptions.get('operatorExtendedOptions'));
        this.response.addSelectOptions('operatorAllOptions', new List<aos_Structs.SelectOption>{
                new aos_Structs.SelectOption(aos_Service.operator2string(aos_Service.Operator.CONTAINS)),
                new aos_Structs.SelectOption(aos_Service.operator2string(aos_Service.Operator.DOES_NOT_CONTAIN)),
                new aos_Structs.SelectOption(aos_Service.operator2string(aos_Service.Operator.STARTS_WITH)),
                new aos_Structs.SelectOption(aos_Service.operator2string(aos_Service.Operator.ENDS_WITH))
        });
    }
}