public without sharing class animalos_MovementDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {

    private vertic_UnitOfWork uow = new vertic_UnitOfWork(
            new List<SObjectType>{
                    Contact.SObjectType,
                    animalos__Referral__c.SObjectType
            }
    );

    public animalos_MovementDomain(List<sObject> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new animalos_MovementDomain(sObjectList);
        }
    }

    public override void onAfterInsert() {
        this.handleAssignToIncomingAnimals(this.Records, null);
    }

    // public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    //     this.handleAdoptedStage(this.Records, existingRecords);
    // }

    private void handleAssignToIncomingAnimals(List<SObject> records, Map<Id, SObject> existingRecords) {

        List<animalos__Movement__c> movementsWithCondition = new List<animalos__Movement__c>();

        Set<Id> locationIds = vertic_Utils.sObjects.getIdFieldValues(records, animalos__Movement__c.animalos__Location__c);

        Map<String, animalos__Location__c> locationsById = new Map<String, animalos__Location__c>([
            SELECT Id, Name, Sync_All_Animals__c
            FROM animalos__Location__c
            WHERE Id IN :locationIds
                AND RecordType.DeveloperName != 'Foster'
                AND RecordType.DeveloperName != 'Offsite'
        ]);

        for (animalos__Movement__c movementItem : (List<animalos__Movement__c>) records) {

            if (movementItem.animalos__Location__c != null && movementItem.animalos__Current__c == true) {
                animalos__Location__c locationVar = locationsById.get(movementItem.animalos__Location__c);

                if (locationVar != null && movementItem.animalos__Location__c == locationVar.Id) {
                    movementsWithCondition.add(movementItem);
                }
            }
        }

        if (movementsWithCondition.isEmpty()) return;

        Set<Id> animalsIds = vertic_Utils.sObjects.getIdFieldValues(movementsWithCondition, animalos__Movement__c.animalos__Animal__c);

        List<SObject> animalsRecords = [
            SELECT Id, animalos__Stage__c, animalos__Type__c
            FROM animalos__Animal__c
            WHERE Id IN :animalsIds
                AND animalos__Stage__c != 'Pre-Intake'
                AND animalos__Stage__c != 'Out'
        ];

        if (animalsRecords.isEmpty()) return;

        animalos_AssignToIncomingAnimalsService.handleAssignToIncomingAnimals(animalsRecords);
    }
}