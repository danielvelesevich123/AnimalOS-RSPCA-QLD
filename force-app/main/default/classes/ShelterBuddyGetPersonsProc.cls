public with sharing class ShelterBuddyGetPersonsProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        Integer page = vertic_Utils.objects.defaultIfNull(this.request.getInteger('page'), 1);
        Integer pageSize = vertic_Utils.objects.defaultIfNull(this.request.getInteger('pageSize'), 10);
        Integer startIndex = vertic_Utils.objects.defaultIfNull(this.request.getInteger('startIndex'), 0);

        ShelterBuddyAPIUtils shelterBuddyAPIUtils = new ShelterBuddyAPIUtils();
        HttpResponse personListResponse = shelterBuddyAPIUtils.commonRequest('getPersonList', new List<String>{
            '' + page,
            '' + pageSize,
            '' + startIndex
        }, null);

        System.debug(personListResponse);

        if (personListResponse.getStatusCode() != 200) {
            throw new vertic_Structs.ProcessException(personListResponse.getStatusCode() + '\n\n\n' + personListResponse.getStatus() + personListResponse.getBody());
        }

        vertic_DTO responseDTO = new vertic_DTO(personListResponse.getBody());
        List<vertic_DTO> dataDTOs = responseDTO.getListAsDTONonNull('Data');

        List<aos_Async_Process__c> vaps = new List<aos_Async_Process__c>();

        System.debug('dataDTOs.size(): '+ dataDTOs.size());

        for (vertic_DTO dataDTO : dataDTOs) {
            vaps.add(new aos_Async_Process__c(
                    aos_Processor__c = '' + PersonUpsertProc.class,
                    aos_Payload__c = JSON.serializePretty(new Map<String, Object>{
                    'personJSON' => JSON.serialize(dataDTO.getMap())
                }),
                    aos_Group_Key__c = dataDTO.getString('Id'),
                    aos_Description__c = 'Load Person',
                    aos_Priority__c = 1
            ));
        }

        if (responseDTO.get('Paging.Next') != null) {
            vaps.add(0, new aos_Async_Process__c(
                    aos_Processor__c = '' + ShelterBuddyGetPersonsProc.class,
                    aos_Payload__c = JSON.serializePretty(new Map<String, Object>{
                    'page' => ++page,
                    'pageSize' => pageSize
                }),
                    aos_Description__c = 'Load Persons',
                    aos_Priority__c = 10,
                    aos_Autorun__c = false // TODO: comment out to sync all.
            ));
        }

        System.debug('vaps.size(): '+ vaps.size());

        insert vaps;

        return this.response;
    }

    public static void startLoad(Integer pageSize) {
        insert new aos_Async_Process__c(
                aos_Processor__c = '' + ShelterBuddyGetPersonsProc.class,
                aos_Payload__c = JSON.serializePretty(new Map<String, Object>{
                'page' => 1,
                'pageSize' => pageSize
            }),
                aos_Description__c = 'Load Persons',
                aos_Priority__c = 10
        );
    }

}