public with sharing class rspcaqldCampaignSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        List<Schema.SObjectField> sObjectFieldList = Schema.getGlobalDescribe().get('Campaign').getDescribe().fields.getMap().values();
        return sObjectFieldList;
    }

    public rspcaqldCampaignSelector() {
        super(false, false, false);
    }

    public Schema.SObjectType getSObjectType() {
        return Campaign.SObjectType;
    }

    public List<Campaign> getPortalActiveCampaigns() {
        final String recordTypeName = 'Event';
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(Campaign.SObjectType);
        return Database.query(queryFactory.selectFields(this.getSObjectFieldList())
                .selectField('Event_Location__Street__s')
                .selectField('Event_Location__City__s')
                .selectField('Event_Location__StateCode__s')
                .selectField('Event_Location__PostalCode__s')
                .selectField('RecordType.DeveloperName')
                .setCondition('StartDate != NULL AND EndDate != NULL AND EndDate >= TODAY AND Show_on_Website__c = TRUE AND RecordType.DeveloperName =:recordTypeName')
                .addOrdering('Featured_Event__c', fflib_QueryFactory.SortOrder.DESCENDING)
                .addOrdering('EndDate', fflib_QueryFactory.SortOrder.ASCENDING)
                .addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING).toSOQL());
    }

    public List<Campaign> getCampaignsByIds(List<String> ids) {
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(Campaign.SObjectType);
        return Database.query(queryFactory.selectFields(this.getSObjectFieldList())
                .selectField('Event_Location__Street__s')
                .selectField('Event_Location__City__s')
                .selectField('Event_Location__StateCode__s')
                .selectField('Event_Location__PostalCode__s')
                .selectField('RecordType.DeveloperName')
                .setCondition('Id IN: ids')
                .addOrdering('Featured_Event__c', fflib_QueryFactory.SortOrder.DESCENDING)
                .addOrdering('EndDate', fflib_QueryFactory.SortOrder.ASCENDING).toSOQL());
    }

    public Campaign getCampaignById(String recordId) {
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(Campaign.SObjectType);
        List<Campaign> lst = Database.query(queryFactory.selectFields(this.getSObjectFieldList())
                .selectField('Event_Location__Street__s')
                .selectField('Event_Location__City__s')
                .selectField('Event_Location__StateCode__s')
                .selectField('Event_Location__PostalCode__s')
                .selectField('RecordType.DeveloperName')
                .setCondition('Id =: recordId AND EndDate >= TODAY AND Show_on_Website__c = TRUE').toSOQL());
        return !lst.isEmpty() ? lst[0] : new Campaign();
    }
}