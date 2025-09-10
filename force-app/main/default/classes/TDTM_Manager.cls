public class TDTM_Manager {

    public interface InitHandler {
        npsp__Trigger_Handler__c initHandler();
    }

    public final static Set<Type> TDTM = new Set<Type>{
        ContactPhoneFormat_TDTM.class,
        ContactShelterBuddy_TDTM.class,
        SyncAnimalOwnerHistory_TDTM.class,

        ContactRollup_TDTM.class,
        CampaignMemberRollup_TDTM.class,
        OpportunityRollup_TDTM.class,

        OpportunityCallRDUpdate_TDTM.class,
        RDConsecutiveClosedLostOpps_TDTM.class
    };

    public static void init(Set<Type> TDTMsToInit) {
        List<npsp__Trigger_Handler__c> triggerHandlers = new List<npsp__Trigger_Handler__c>();

        for (Type tdtmVar : TDTMsToInit) {
            Object tdtmInstanceVar = tdtmVar.newInstance();
            if ((tdtmInstanceVar instanceof InitHandler) != true) {
                throw new npsp_plus.vertic_Structs.ProcessException('TDTM should implement TDTM_Manager.InitHandler interface');
            }

            npsp__Trigger_Handler__c triggerHandlerVar = ((InitHandler) tdtmInstanceVar).initHandler();
            triggerHandlers.add(triggerHandlerVar);
        }

        Set<String> classes = npsp_plus.vertic_Utils.sObjects.getStringFieldValues(triggerHandlers, npsp__Trigger_Handler__c.npsp__Class__c);

        delete [
            SELECT Id, npsp__Object__c, npsp__Class__c
            FROM npsp__Trigger_Handler__c
            WHERE npsp__Class__c IN :classes
        ];

        insert triggerHandlers;
    }

    public static void init() {
        init(TDTM_Manager.TDTM);
    }


    public static Boolean IS_KEEP_OLD_SALES_PRICE = false;
}