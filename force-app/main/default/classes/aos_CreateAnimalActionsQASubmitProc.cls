public class aos_CreateAnimalActionsQASubmitProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    private vertic_UnitOfWork uow = new vertic_UnitOfWork(
            new List<SObjectType>{
                    animalos__Animal_Action__c.SObjectType,
                    animalos__Medicine_Used__c.SObjectType
            }
    );

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        List<vertic_DTO> animalActionDTOs = this.request.getDTOs('animalActions');

        for (vertic_DTO animalActionDTO : animalActionDTOs) {
            animalos__Animal_Action__c animalAction = new animalos__Animal_Action__c();
            animalActionDTO.getMapper().mapToSObject(animalAction);
            this.uow.registerNew(animalAction);

            String medicineId = animalActionDTO.getString('medicineId');

            if (String.isNotBlank(medicineId)) {
                animalos__Medicine_Used__c medicineUsed = new animalos__Medicine_Used__c(
                        animalos__Medicine__c = medicineId,
                        animalos__Animal__c = animalAction.animalos__Animal__c,
                        animalos__Vet_Consult__c = animalAction.animalos__Vet_Consult__c
                );
                this.uow.registerNew(medicineUsed, animalos__Medicine_Used__c.animalos__Animal_Action__c, animalAction);
            }
        }

        this.uow.commitWork();
    }

}
