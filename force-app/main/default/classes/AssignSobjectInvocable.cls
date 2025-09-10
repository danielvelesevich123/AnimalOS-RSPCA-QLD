global without sharing class AssignSobjectInvocable {

    @InvocableMethod(Label='Assign Sobject Invocable')
    global static List<InvocableResponse> process(List<InvocableRequest> requests) {
        List<InvocableResponse> responses = new List<InvocableResponse>();

        for (InvocableRequest requestVar : requests) {
            InvocableResponse response = new InvocableResponse();

            if(requestVar.sourceVar != null && requestVar.targetVar != null) {
                for (String fieldVar : requestVar.sourceVar.getPopulatedFieldsAsMap().keySet()) {
                    requestVar.targetVar.put(fieldVar, requestVar.sourceVar.get(fieldVar));
                }
            }
            response.targetVar = requestVar.targetVar;

            responses.add(response);
        }

        return responses;
    }

    global class InvocableRequest {
        @InvocableVariable(Label='Source')
        global SObject sourceVar;

        @InvocableVariable(Label='Target')
        global SObject targetVar;
    }

    global class InvocableResponse {
        @InvocableVariable(Label='Target')
        global SObject targetVar;
    }

}