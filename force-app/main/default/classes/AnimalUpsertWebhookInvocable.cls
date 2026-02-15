global without sharing class AnimalUpsertWebhookInvocable {

    @InvocableMethod(Label='Animal Upsert Invocable')
    global static List<InvocableResponse> process(List<InvocableRequest> requests) {
        List<InvocableResponse> responses = new List<InvocableResponse>();

        for (InvocableRequest requestVar : requests) {
            InvocableResponse response = new InvocableResponse();

            response.animalVar = (Animal__c) new AnimalUpsertProc()
                .process(new Map<String, Object>{
                    'animalJSON' => JSON.serialize(new vertic_DTO(requestVar.requestJSON).get('dto'))
                })
                .get('animal');

            responses.add(response);
        }

        return responses;
    }

    global class InvocableRequest {
        @InvocableVariable(Label='Animal JSON')
        global String requestJSON;
    }

    global class InvocableResponse {
        @InvocableVariable(Label='Animal')
        global Animal__c animalVar;
    }

}
