public class ContactPhoneFormatComponent {

    /**
    * @description Contact Phone Format Request
    */
    public class ContactPhoneFormatRequest {

        /**
        * @description Contact Record
        */
        @InvocableVariable(label='Contact' required=true)
        public Contact record;

    }

    /**
    * @description Contact Phone Format Response
    */
    public class ContactPhoneFormatResponse {

        /**
        * @description Contact Record
        */
        @InvocableVariable(label='Contact' required=true)
        public Contact record;

    }

    /**
    * @description Converts phone numbers for a Contact record
    * @param requestList A list of requests created and injected by the flow engine
    * @return A list of resulting response to be returned to the flow engine
    */
    @InvocableMethod
    public static List<ContactPhoneFormatResponse> process(List<ContactPhoneFormatRequest> requestList) {
        List<ContactPhoneFormatResponse> responseList = new List<ContactPhoneFormatResponse>();

        List<String> phoneFields = new List<String>{
            'MobilePhone',
            'HomePhone',
            'npe01__WorkPhone__c',
            'OtherPhone'
        };

        for (ContactPhoneFormatRequest request : requestList) {
            ContactPhoneFormatResponse response = new ContactPhoneFormatResponse();
            response.record = request.record;

            if (response.record != null) {
                for (String phoneField : phoneFields) {
                    String fieldValue = (String) response.record.get(phoneField);
                    String parsedFieldValue = PhoneFormatService.formatPhone(fieldValue);
                    response.record.put(phoneField, parsedFieldValue);
                }
            }

            responseList.add(response);
        }

        return responseList;
    }

}