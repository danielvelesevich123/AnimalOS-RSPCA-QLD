public with sharing class aos_WildlifeAnimalIntakeChildsSubmitProc extends aos_AbstractProcessor {

    private aos_UnitOfWork uow = new aos_UnitOfWork(new List<SObjectType>{
            animalos__Animal__c.SObjectType,
            animalos__Referral__c.SObjectType,
            animalos__Animal_Referral__c.SObjectType
    });

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        try {
            animalos__Animal__c animal = new animalos__Animal__c();
            this.request.getMapper().mapToSObject('animal', animal);
            this.uow.registerUpsert(animal);

            animalos__Referral__c referral = new animalos__Referral__c();
            this.request.getMapper().mapToSObject('referral', referral);
            this.uow.registerNew(referral);

            animalos__Animal_Referral__c animalReferral = new animalos__Animal_Referral__c();
            if (this.request.has('animal.animalReferral')) {
                this.request.getMapper().mapToSObject('animal.animalReferral', animalReferral);
            }
            this.uow.registerNew(animalReferral, animalos__Animal_Referral__c.animalos__Animal__c, animal);
            this.uow.registerRelationship(animalReferral, animalos__Animal_Referral__c.animalos__Referral__c, referral);

            Savepoint sp = Database.setSavepoint();
            this.uow.commitWork();
            Database.rollback(sp);
        } catch (Exception ex) {
            this.response.put('errorMessage', ex.getMessage());
        }
    }

}