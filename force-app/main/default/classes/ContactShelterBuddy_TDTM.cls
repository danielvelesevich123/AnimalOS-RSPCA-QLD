global without sharing class ContactShelterBuddy_TDTM extends npsp.TDTM_Runnable implements TDTM_Manager.InitHandler {

    private List<SObjectField> fieldsToSync = new List<SObjectField>{
            Contact.FirstName,
            Contact.LastName,
            Contact.ShelterBuddy_ID_PID__c,
            Contact.Salutation,
            Contact.Nickname__c,
            Contact.Gender__c,
            Contact.MiddleName,
            Contact.Birthdate,
            Contact.MailingStreet,
            Contact.MailingPostalCode,
            Contact.MailingCity,
            Contact.MailingState,
            Contact.MailingCountry,
            Contact.OtherStreet,
            Contact.OtherPostalCode,
            Contact.OtherCity,
            Contact.OtherState,
            Contact.OtherCountry,
            Contact.HomePhone,
            Contact.MobilePhone,
            Contact.npe01__WorkPhone__c,
            Contact.Last_ShelterBuddy_Sync__c,
            Contact.Last_ShelterBuddy_Sync_String__c,
            Contact.Email,
            Contact.npe01__WorkEmail__c,
            Contact.npe01__HomeEmail__c,
            Contact.npe01__AlternateEmail__c,
            Contact.npe01__Preferred_Email__c
    };

    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        Map<Id, SObject> oldMap = oldlist == null ? null : new Map<Id, SObject>(oldlist);
        List<Vertic_Async_Process__c> vaps = new List<Vertic_Async_Process__c>();

        if (ShelterBuddySyncPersonProc.IS_SYNC_ENABLED != true) {
            return dmlWrapper;
        }

        System.debug('RUN');
        List<Contact> contacts = (List<Contact>) newlist;
        Set<String> contactIds = vertic_Utils.sObjects.getStringFieldValues(contacts, Contact.Id);

        List<Vertic_Async_Process__c> existingVaps = [
            SELECT Id, Group_Key__c
            FROM Vertic_Async_Process__c
            WHERE Processor__c = :('' + ShelterBuddySyncPersonProc.class) AND Status__c = 'Pending' AND Autorun__c = TRUE
            AND Group_Key__c IN :contactIds
        ];
        Map<String, SObject> existingVapsMap = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(existingVaps, Vertic_Async_Process__c.Group_Key__c);

        for (Contact contactVar : contacts) {

            Boolean isSyncEnabled = areRequiredFieldsPopulated(contactVar); // String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c);
            if (isSyncEnabled != true) {
                continue;
            }

            Boolean isInsert = triggerAction == npsp.TDTM_Runnable.Action.AfterInsert;
            Boolean isUpdate = triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate;

            if(oldMap != null){
                if(!vertic_Utils.sObjects.isSomeFieldChanged(contactVar, oldMap.get(contactVar.Id), fieldsToSync)){
                    continue;
                }
            }

            if(existingVapsMap.containsKey(contactVar.Id)){ // Avoid duplicate VAPs on multiple contact updates from Flows and other automations.
                continue;
            }

            if (isInsert || isUpdate) {
                vaps.add(syncShelterBuddyPersons(contactVar));
            }
        }

        ShelterBuddySyncPersonProc.IS_SYNC_ENABLED = false;

        insert vaps;

        return dmlWrapper;
    }

    private Vertic_Async_Process__c syncShelterBuddyPersons(Contact contactVar) {
        return new Vertic_Async_Process__c(
            Processor__c = '' + ShelterBuddySyncPersonProc.class,
            Payload__c = JSON.serialize(new Map<String, String>{
                'recordId' => contactVar.Id
            }),
            Autorun__c = true,
            Description__c = 'Sync ShelterBuddy Person',
            Group_Key__c = contactVar.Id
        );
    }

    public npsp__Trigger_Handler__c initHandler() {
        return new npsp__Trigger_Handler__c(
            npsp__Active__c = true,
            npsp__Class__c = '' + ContactShelterBuddy_TDTM.class,
            npsp__Object__c = '' + Contact.SObjectType,
            npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate',
            npsp__User_Managed__c = true
        );
    }

    private Boolean areRequiredFieldsPopulated(Contact contactVar) {
        List<SObjectField> fields = new List<SObjectField>{
            Contact.FirstName, Contact.LastName
        };

        for (SObjectField fieldVar : fields) {
            String fieldValue = String.valueOf(contactVar.get(fieldVar));
            if (String.isBlank(fieldValue)) {
                return false;
            }
        }

        return true;
    }

    private Boolean isOneOptionalFieldPopulated(SObject objectVar, List<SObjectField> fields) {

        for (SObjectField fieldVar : fields) {
            if (String.isNotBlank(String.valueOf(objectVar.get(fieldVar)))) {
                return true;
            }
        }

        return false;
    }
}