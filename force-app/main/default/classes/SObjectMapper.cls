public class SObjectMapper {

    public static SObject mapAllFields(SObject source, String sourceNamespace, SObject target, String targetNamespace) {
        Map<String, SObjectField> SObjectToMigrateFieldsMap = source.getSObjectType().getDescribe().fields.getMap();
        List<SObjectField> newSObjectFields = target.getSObjectType().getDescribe().fields.getMap().values();

        for (SObjectField sObjectFieldVar : newSObjectFields) {
            DescribeFieldResult newFieldDescribe = sObjectFieldVar.getDescribe();

            if ((newFieldDescribe.isCustom() || 'Name'.equals(newFieldDescribe.getName()) || 'OwnerId'.equals(newFieldDescribe.getName())) && newFieldDescribe.isUpdateable()) {
                String newSObjectField = sObjectFieldVar + '';
                SObjectField SObjectToMigrateField = SObjectToMigrateFieldsMap.get(
                    (String.isNotBlank(sourceNamespace) ? sourceNamespace + '__' : '') +
                        (String.isNotBlank(targetNamespace) ? newSObjectField.toLowerCase().substringAfter('__') : newSObjectField.toLowerCase())
                );

                if (SObjectToMigrateField == null) {
                    SObjectToMigrateField = SObjectToMigrateFieldsMap.get(
                        String.isNotBlank(targetNamespace) ?
                            newSObjectField.toLowerCase().replace(targetNamespace + '__', '') :
                            newSObjectField.toLowerCase()
                    );

                    if (SObjectToMigrateField == null) {
                        continue;
                    }
                }

                DescribeFieldResult fieldToMigrateDescribe = SObjectToMigrateField.getDescribe();
                if (newFieldDescribe.getType() == fieldToMigrateDescribe.getType() && ((newFieldDescribe.getType() == DisplayType.REFERENCE && newFieldDescribe.getReferenceTo()[0] == fieldToMigrateDescribe.getReferenceTo()[0])
                    || newFieldDescribe.getType() != DisplayType.REFERENCE)) {
                    target.put(newSObjectField + '', source.get(SObjectToMigrateField + ''));
                }
            }
        }
        return target;
    }

    public static SObject mapAuditFields(SObject source, SObject target) {
        if(source != null && target != null) {
            target.put('CreatedDate', source.get('CreatedDate'));
            target.put('CreatedById', source.get('CreatedById'));
            target.put('LastModifiedDate', source.get('LastModifiedDate'));
            target.put('LastModifiedById', source.get('LastModifiedById'));
        }

        return target;
    }
}