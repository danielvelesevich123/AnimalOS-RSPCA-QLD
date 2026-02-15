public with sharing class ShelterBuddyGetAnimalsProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        Integer page = vertic_Utils.objects.defaultIfNull(this.request.getInteger('page'), 1);
        Integer pageSize = vertic_Utils.objects.defaultIfNull(this.request.getInteger('pageSize'), 10);
        Integer startIndex = vertic_Utils.objects.defaultIfNull(this.request.getInteger('startIndex'), 0);

        ShelterBuddyAPIUtils shelterBuddyAPIUtils = new ShelterBuddyAPIUtils();
        HttpResponse animalListResponse = new HttpResponse();

        try{
            animalListResponse = shelterBuddyAPIUtils.commonRequest('getAnimalList', new List<String>{
                    '' + page,
                    '' + pageSize,
                    '' + startIndex
            }, null);
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        finally{
            shelterBuddyAPIUtils.saveAccessToken();
        }
        
        if (animalListResponse.getStatusCode() != 200) {
            throw new vertic_Structs.ProcessException(animalListResponse.getStatusCode() + '\n\n\n' + animalListResponse.getStatus() + animalListResponse.getBody());
        }

        vertic_DTO responseDTO = new vertic_DTO(animalListResponse.getBody());
        List<vertic_DTO> dataDTOs = responseDTO.getListAsDTONonNull('Data');

        List<aos_Async_Process__c> vaps = new List<aos_Async_Process__c>();

        for (vertic_DTO dataDTO : dataDTOs) {
            vaps.add(new aos_Async_Process__c(
                aos_Processor__c = '' + AnimalUpsertProc.class,
                    aos_Payload__c = JSON.serializePretty(new Map<String, Object>{
                    'animalJSON' => JSON.serializePretty(dataDTO.getMap())
                }),
                    aos_Group_Key__c = dataDTO.getString('Id'),
                    aos_Description__c = 'Load Animal',
                    aos_Priority__c = 1,
                    aos_Run_After__c = Datetime.now().addMinutes(20),
                    aos_Is_Queueable__c = true
            ));
        }

        if (responseDTO.get('Paging.Next') != null && page < 3) {
            vaps.add(0, new aos_Async_Process__c(
                    aos_Processor__c = '' + ShelterBuddyGetAnimalsProc.class,
                    aos_Payload__c = JSON.serializePretty(new Map<String, Object>{
                    'page' => ++page,
                    'pageSize' => pageSize
                }),
                    aos_Description__c = 'Load Animals',
                    aos_Priority__c = 10,
                    aos_Autorun__c = true // TODO: comment out to sync all.
            ));
        }

        insert vaps;

        return this.response;
    }

    public static void startLoad(Integer pageSize) {
        insert new aos_Async_Process__c(
                aos_Processor__c = '' + ShelterBuddyGetAnimalsProc.class,
                aos_Payload__c = JSON.serializePretty(new Map<String, Object>{
                'page' => 1,
                'pageSize' => pageSize
            }),
                aos_Description__c = 'Load Animals',
                aos_Priority__c = 10
        );
    }

}