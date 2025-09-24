public class SobjectFilterMetaProc extends vertic_MetadataProcessor implements Database.AllowsCallouts {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        super.process(this.request);

        this.doInit();
        this.initOperatorOptions();

        return this.response;
    }

    private void doInit() {
        String sobjectApiName = this.request.getRequiredString('sobjectApiName');
        SObjectType sObjectTypeVar = Schema.getGlobalDescribe().get(sobjectApiName);
        Map<String, Map<String, Object>> fieldsInfoMap = vertic_Utils.sObjects.getFieldsInfo(sObjectTypeVar);

        Map<String, SObjectField> sObjectFieldByName = sObjectTypeVar.getDescribe().fields.getMap();
        List<vertic_Structs.SelectOption> fieldOptions = new List<vertic_Structs.SelectOption>();

        for (String fieldName : sObjectFieldByName.keySet()) {
            DescribeFieldResult describeFieldResultVar = sObjectFieldByName.get(fieldName).getDescribe();


            if (!describeFieldResultVar.isAccessible()) {
                fieldsInfoMap.remove(describeFieldResultVar.getName());
                continue;
            }

            if (fieldsInfoMap.containsKey(describeFieldResultVar.getName())) {
                fieldOptions.add(new vertic_Structs.SelectOption(
                        describeFieldResultVar.getName(),
                        describeFieldResultVar.getLabel()
                ));
            }
        }

        this.response.addSelectOptions('fieldOptions', fieldOptions);
        this.response.put('fieldsInfoMap', fieldsInfoMap);
    }

    private void initOperatorOptions() {
        this.response.addSelectOptions('operatorLimitedOptions', new List<vertic_Structs.SelectOption>{
                new vertic_Structs.SelectOption(Service.operator2string(Service.Operator.EQUALS)),
                new vertic_Structs.SelectOption(Service.operator2string(Service.Operator.NOT_EQUAL_TO))
        });
        this.response.addSelectOptions('operatorExtendedOptions', this.response.selectOptions.get('operatorLimitedOptions'));
        this.response.addSelectOptions('operatorExtendedOptions', new List<vertic_Structs.SelectOption>{
                new vertic_Structs.SelectOption(Service.operator2string(Service.Operator.LESS_THAN)),
                new vertic_Structs.SelectOption(Service.operator2string(Service.Operator.LESS_OR_EQUAL)),
                new vertic_Structs.SelectOption(Service.operator2string(Service.Operator.GREATER_THAN)),
                new vertic_Structs.SelectOption(Service.operator2string(Service.Operator.GREATER_OR_EQUAL))
        });
        this.response.addSelectOptions('operatorAllOptions', this.response.selectOptions.get('operatorExtendedOptions'));
        this.response.addSelectOptions('operatorAllOptions', new List<vertic_Structs.SelectOption>{
                new vertic_Structs.SelectOption(Service.operator2string(Service.Operator.CONTAINS)),
                new vertic_Structs.SelectOption(Service.operator2string(Service.Operator.DOES_NOT_CONTAIN)),
                new vertic_Structs.SelectOption(Service.operator2string(Service.Operator.STARTS_WITH)),
                new vertic_Structs.SelectOption(Service.operator2string(Service.Operator.ENDS_WITH))
        });
    }
}