public class aos_CreateAnimalActionsQAMetaProc extends aos_MetadataProcessor {

    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                animalos__Animal_Action__c.animalos__Action_Status__c
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        this.initRecords();
        this.initRecordTypeOptions();
    }

    private void initRecords() {
        String recordId = this.request.getRequiredString('recordId');

        animalos__Animal__c animal = (animalos__Animal__c) aos_Utils.arrays.firstOrException([
                SELECT Id
                FROM animalos__Animal__c
                WHERE Id IN (
                        SELECT animalos__Animal__c
                        FROM animalos__Vet_Consult__c
                        WHERE Id = :recordId
                )
        ]);

        this.response.put('animalId', animal.Id);

        this.response.getMapper().mapFromListSObjects('animalActions', new List<animalos__Animal_Action__c>{
                new animalos__Animal_Action__c(
                        animalos__Animal__c = animal.Id,
                        animalos__Action_Status__c = 'Scheduled',
                        animalos__Date_Time_of_Action__c = Datetime.now(),
                        animalos__Vet_Consult__c = recordId
                )
        });
    }

    private void initRecordTypeOptions() {
        List<aos_Structs.SelectOption> recordTypeOptions = new List<aos_Structs.SelectOption>();

        for (RecordTypeInfo recordTypeInfo : animalos__Animal_Action__c.SObjectType.getDescribe().recordTypeInfos) {
            if (!'Master'.equals(recordTypeInfo.getDeveloperName()) && recordTypeInfo.isActive() && recordTypeInfo.isAvailable()) {
                recordTypeOptions.add(new aos_Structs.SelectOption(recordTypeInfo.getRecordTypeId(), recordTypeInfo.getName()));
            }
        }

        this.response.addSelectOptions('recordTypeOptions', recordTypeOptions);
    }

}