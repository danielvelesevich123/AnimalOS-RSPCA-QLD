global without sharing class AccountPhoneFormat_TDTM extends npsp.TDTM_Runnable implements TDTM_Manager.InitHandler {
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {


        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            for(Account accountVar : (List<Account>)newlist){
                formatAccountPhones(accountVar);
            }
        }

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        return dmlWrapper;
    }

    private void formatAccountPhones(Account accountVar) {
        List<String> phoneFields = new List<String>{
                'Phone'
        };

        for (String phoneField : phoneFields) {
            accountVar.put(phoneField, PhoneFormatService.formatPhone((String) accountVar.get(phoneField)));
        }
    }

    public npsp__Trigger_Handler__c initHandler() {
        return new npsp__Trigger_Handler__c(
                npsp__Active__c = true,
                npsp__Class__c = '' + AccountPhoneFormat_TDTM.class,
                npsp__Object__c = '' + Account.SObjectType,
                npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate',
                npsp__User_Managed__c = true
        );
    }
}