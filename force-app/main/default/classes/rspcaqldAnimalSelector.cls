public with sharing class rspcaqldAnimalSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        List<Schema.SObjectField> sObjectFieldList = Schema.getGlobalDescribe().get('Animal__c').getDescribe().fields.getMap().values();
        return sObjectFieldList;
    }

    public rspcaqldAnimalSelector() {
        super(false, false, false);
    }

    public Schema.SObjectType getSObjectType() {
        return Animal__c.SObjectType;
    }

    public Animal__c getAnimalById(String animalId) {
        if (String.isNotEmpty(animalId)) {
            fflib_QueryFactory queryFactory = new fflib_QueryFactory(Animal__c.SObjectType);
            List<Animal__c> animalList = Database.query(queryFactory.selectFields(this.getSObjectFieldList()).selectField('Location__r.Geolocation__c').selectField('Location__r.Location_Type__c')
                    .setCondition('Portal_Active__c = TRUE AND Id =: animalId').toSOQL());
            return animalList.size() > 0 ? animalList[0] : new Animal__c();
        }
        return new Animal__c();
    }

    public List<Animal__c> getAnimalsByAccountId(String accountId) {
        if (String.isNotEmpty(accountId)) {
            fflib_QueryFactory queryFactory = new fflib_QueryFactory(Animal__c.SObjectType);
            return Database.query(queryFactory.selectFields(this.getSObjectFieldList())
                    .setCondition('Portal_Active__c = TRUE AND Location__c =: accountId').toSOQL());
        }
        return new List<Animal__c>();
    }

    public List<Animal__c> getAnimalsByCategoryExcludeId(String animalId, String category) {
        if (String.isNotEmpty(animalId) && String.isNotEmpty(category)) {
            fflib_QueryFactory queryFactory = new fflib_QueryFactory(Animal__c.SObjectType);
            return Database.query(queryFactory.selectFields(this.getSObjectFieldList())
                    .setCondition('Portal_Active__c = TRUE AND Id !=: animalId AND Animal_Category__c =: category')
                    .addOrdering('Animal_Name__c', fflib_QueryFactory.SortOrder.ASCENDING).toSOQL());
        }
        return new List<Animal__c>();
    }

    public List<Animal__c> getPortalActiveAnimals() {
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(Animal__c.SObjectType);
        return Database.query(queryFactory.selectFields(this.getSObjectFieldList()).selectField('Location__r.Geolocation__c')
                .setCondition('Portal_Active__c = TRUE')
                .addOrdering('Featured__c', fflib_QueryFactory.SortOrder.DESCENDING)
                .addOrdering('Status_Date__c', fflib_QueryFactory.SortOrder.DESCENDING)
                .addOrdering('Animal_Name__c', fflib_QueryFactory.SortOrder.ASCENDING)
                .addOrdering('Age_Group__c', fflib_QueryFactory.SortOrder.ASCENDING).toSOQL());
    }
}