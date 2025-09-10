global without sharing class SyncAnimalOwnerHistory_TDTM extends npsp.TDTM_Runnable implements TDTM_Manager.InitHandler {
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        Map<Id, SObject> oldMap = oldlist == null ? null : new Map<Id, SObject>(oldlist);

        List<Vertic_Async_Process__c> vaps = new List<Vertic_Async_Process__c>();

        List<Animal__c> animals = (List<Animal__c>) newlist;
        Set<String> animalIds = vertic_Utils.sObjects.getStringFieldValues(animals, Animal__c.Id);

        List<Vertic_Async_Process__c> existingVaps = [
                SELECT Id, Group_Key__c
                FROM Vertic_Async_Process__c
                WHERE Processor__c = :('' + ShelterBuddySyncPersonProc.class) AND Status__c = 'Pending' AND Autorun__c = TRUE
                AND Group_Key__c IN :animalIds
        ];

        Map<String, SObject> existingVapsMap = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(existingVaps, Vertic_Async_Process__c.Group_Key__c);

        for (Animal__c animalVar : (List<Animal__c>) newlist) {

            if(SyncAnimalOwnerHistoryProc.IS_SYNC_ENABLED != true){
                return new npsp.TDTM_Runnable.DmlWrapper();
            }

            if(String.isBlank(animalVar.Shelterbuddy_ID__c)){
                continue;
            }

            if(existingVapsMap.containsKey(animalVar.Id)){ // Avoid duplicate VAPs on multiple contact updates from Flows and other automations.
                continue;
            }

            vaps.add(new Vertic_Async_Process__c(
                Processor__c = '' + SyncAnimalOwnerHistoryProc.class,
                Payload__c = JSON.serialize(new Map<String, String>{
                    'recordId' => animalVar.Id
                }),
                Autorun__c = true,
                Description__c = 'Sync Animal Owner History',
                Group_Key__c = animalVar.Id
            ));
        }

        insert vaps;

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        return dmlWrapper;
    }

    public npsp__Trigger_Handler__c initHandler() {
        return new npsp__Trigger_Handler__c(
            npsp__Active__c = true,
            npsp__Class__c = '' + SyncAnimalOwnerHistory_TDTM.class,
            npsp__Object__c = '' + Animal__c.SObjectType,
            npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate',
            npsp__User_Managed__c = true
        );
    }
}