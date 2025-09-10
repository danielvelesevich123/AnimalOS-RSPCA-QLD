global without sharing class ContactPhoneFormat_TDTM extends npsp.TDTM_Runnable implements TDTM_Manager.InitHandler {
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {


        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            for(Contact contactVar : (List<Contact>)newlist){
                formatContactPhones(contactVar);
            }
        }

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        return dmlWrapper;
    }

    private void formatContactPhones(Contact contactVar) {
        if (contactVar == null) return;

        List<String> phoneFields = new List<String>{
                'MobilePhone',
                'HomePhone',
                'npe01__WorkPhone__c',
                'OtherPhone'
        };

        for (String phoneField : phoneFields) {
            contactVar.put(phoneField, PhoneFormatService.formatPhone((String) contactVar.get(phoneField)));
        }
    }

    public npsp__Trigger_Handler__c initHandler() {
        return new npsp__Trigger_Handler__c(
                npsp__Active__c = true,
                npsp__Class__c = '' + ContactPhoneFormat_TDTM.class,
                npsp__Object__c = '' + Contact.SObjectType,
                npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate',
                npsp__User_Managed__c = true
        );
    }
}