public class ImportAnimalsBatch implements Database.Batchable<Integer>, Database.AllowsCallouts {

    private static Integer PAGE_SIZE = 200;

    private String filter;

    public ImportAnimalsBatch(String filter){
        this.filter = filter;
    }

    public Iterable<Integer> start(Database.BatchableContext BC) {

        Integer totalPages = getTotalPages(filter);

        List<Integer> pages = new List<Integer>();
        for (Integer i = 1; i <= totalPages; i++) {
            pages.add(i);
        }
        return pages;
    }

    public static Integer getTotalPages(String filter) {
        HttpResponse animalListResponse = new HttpResponse();
        ShelterBuddyAPIUtils shelterBuddyAPIUtils = new ShelterBuddyAPIUtils();

        try{
            animalListResponse = shelterBuddyAPIUtils.commonRequest('getAnimalList', new List<String>{
                    '1', '' + PAGE_SIZE, '0'
            }, filter);
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
        Integer totalPages = responseDTO.getInteger('Paging.TotalPages');
        return totalPages;
    }

    public static Integer getTotals(String filter) {
        HttpResponse animalListResponse = new ShelterBuddyAPIUtils().commonRequest('getAnimalList', new List<String>{
            '1', '' + PAGE_SIZE, '0'
        }, filter);

        if (animalListResponse.getStatusCode() != 200) {
            throw new vertic_Structs.ProcessException(animalListResponse.getStatusCode() + '\n\n\n' + animalListResponse.getStatus() + animalListResponse.getBody());
        }

        vertic_DTO responseDTO = new vertic_DTO(animalListResponse.getBody());
        Integer totalPages = responseDTO.getInteger('Paging.TotalResults');
        return totalPages;
    }

    public void execute(Database.BatchableContext BC, List<Integer> pages) {

        Integer page = pages.get(0);
        Integer pageSize = PAGE_SIZE;

        Map<String, Object> requestMap = new Map<String, Object>{
            'page' => page,
            'pageSize' => pageSize,
            'filter' => this.filter
        };

        try {
            new ImportAnimalsBatchProc().process(requestMap);
        } catch (Exception e) {
            insert new aos_Async_Process__c(
                    aos_Processor__c = '' + ImportAnimalsBatchProc.class,
                    aos_Payload__c = JSON.serialize(requestMap),
                    aos_Description__c = 'Load Animals',
                    aos_Priority__c = 1,
                    aos_Group_Key__c = '' + BC.getJobId(),
                    aos_Autorun__c = false,
                    aos_Status__c = 'Failed',
                    aos_Details__c = e.getMessage()
            );
        }
    }

    public void finish(Database.BatchableContext BC) {

    }

    public static Id start(String filter){
        return Database.executeBatch(new ImportAnimalsBatch(filter), 1);
    }
}