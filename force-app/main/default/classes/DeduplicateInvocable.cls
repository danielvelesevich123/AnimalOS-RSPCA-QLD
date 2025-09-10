public without sharing class DeduplicateInvocable {

    @InvocableMethod(label='Deduplicate Invocable')
    public static List<SObject> checkingForDuplicateEntries(List<SObject> sObjects) {
        convertFlowPicklistFieldValues(sObjects[0]);
        vertic_Utils.sObjects.deduplicate(sObjects[0], null);
        return sObjects;
    }

    /*
        Flow returns the SObject with picklits value in JSON format like:
        StageName = {"value": "ClosedWon"}
        This method converts the JSON value to String value: {"value": "ClosedWon"} => "ClosedWon"
        By using the Field get method as it always returns correct string
     */

    public static void convertFlowPicklistFieldValues(SObject recordVar) {
        if(recordVar == null){ return;}

        Set<SObjectField> picklistFields = vertic_Utils.sObjects.getFieldsByTypes(recordVar.getSObjectType(), new Set<DisplayType>{
            DisplayType.PICKLIST
        });
        Map<String, Object> populatedFieldsMap = recordVar.getPopulatedFieldsAsMap();
        for (SObjectField fieldVar : picklistFields) {
            if (!populatedFieldsMap.containsKey('' + fieldVar)) {  continue; }

            try {
                Object val = recordVar.get(fieldVar);

                if (val == null) { continue; }

                String strVal = '' + val;
                recordVar.put(fieldVar, strVal);
            } catch (Exception e) {
            }
        }
    }
}