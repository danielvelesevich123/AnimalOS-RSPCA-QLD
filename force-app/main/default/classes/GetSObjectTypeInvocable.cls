global class GetSObjectTypeInvocable {

    @InvocableMethod(label='Get SObject Type' Description='Get SObject Type of provided Id')
    global static List<InvocableResponse> process(List<InvocableRequest> requests) {

        List<InvocableResponse> responses = new List<InvocableResponse>();

        for (InvocableRequest request : requests) {
            InvocableResponse response = new InvocableResponse();

            if (String.isNotBlank(request.recordId)) {
                response.sObjectType = ((Id) request.recordId).getSobjectType().getDescribe().getName();
            } 

            responses.add(response);
        }

        return responses;
    }

    global class InvocableRequest {
        @InvocableVariable(label='Record Id')
        global String recordId;
    }

    global class InvocableResponse {
        @InvocableVariable(label='SObjectType')
        global String sObjectType;
    }
}