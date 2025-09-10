public with sharing class rspcaqldAccountSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        List<Schema.SObjectField> accessibleFieldList = new List<Schema.SObjectField>();
        List<Schema.SObjectField> sObjectFieldList = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().values();
        for (Schema.SObjectField sObjField : sObjectFieldList) {
            if (sObjField.getDescribe().isAccessible()) {
                accessibleFieldList.add(sObjField);
            }
        }

        return accessibleFieldList;
    }

    public rspcaqldAccountSelector() {
        super(false, false, false);
    }

    public Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public List<Account> getLocationAccounts() {
        String LOCATION_RECORD_TYPE = 'Location';
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(Account.SObjectType);
        return Database.query(queryFactory.selectFields(this.getSObjectFieldList())
                .setCondition('RecordType.DeveloperName =: LOCATION_RECORD_TYPE AND Phone != NULL AND Services_Offered__c != NULL AND Location_Type__c != NULL AND ShippingStreet != NULL AND ShippingCity != NULL AND ShippingPostalCode != NULL AND ShippingState != NULL')
                .addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING).toSOQL());
    }

    public Account getAccountById(String recordId) {
        if (String.isNotEmpty(recordId)) {
            fflib_QueryFactory queryFactory = new fflib_QueryFactory(Account.SObjectType);
            List<Account> accntList = Database.query(queryFactory.selectFields(this.getSObjectFieldList())
                    .setCondition('Id =: recordId').toSOQL());
            return !accntList.isEmpty() ? accntList[0] : new Account();
        }
        return new Account();
    }

    public List<Account> getAccountByIds(List<String> recordIds) {
        if (!recordIds.isEmpty()) {
            fflib_QueryFactory queryFactory = new fflib_QueryFactory(Account.SObjectType);
            return Database.query(queryFactory.selectFields(this.getSObjectFieldList())
                    .setCondition('Id IN: recordIds').toSOQL());
        }
        return new List<Account>();
    }
}