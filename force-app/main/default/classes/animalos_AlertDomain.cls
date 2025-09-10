public without sharing class animalos_AlertDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {

    public animalos_AlertDomain(List<sObject> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new animalos_AlertDomain(sObjectList);
        }
    }

    public override void onBeforeInsert() {
        this.populateAnimalLookupField(this.Records);
    }

    public override void onAfterInsert() {
    }
    

    public void populateAnimalLookupField(List<sObject> records) {

        for (animalos__Alert__c alert : (List<animalos__Alert__c>) records) {

            if (String.isNotBlank(alert.animalos__Target_Record_Id__c) && 'animalos__Animal__c'.equalsIgnoreCase(alert.animalos__Target_Object__c)) {
                alert.Animal__c = alert.animalos__Target_Record_Id__c;
            }
        }
    }
}