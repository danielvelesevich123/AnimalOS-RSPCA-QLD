global without sharing class InsightRaffleImportMobileFormat {

    @InvocableMethod(label='get Formatted Mobile Phone')
    global static List<InvocableResponse> getFormattedMobilePhone(List<InvocableRequest> requests) {
        List<InvocableResponse> responses = new List<InvocableResponse>();

        for (InvocableRequest request : requests){
            InvocableResponse response = new InvocableResponse();

            if (String.isBlank(request.phoneNumber) == true) {
                response.formattedPhoneNumber = '';
                response.isMobilePhone = false;
            } else {
                String phone = vertic_Utils.strings.removeNonNumeric(request.phoneNumber);

                if (phone.length() == 9) {
                    response.formattedPhoneNumber = '0' + phone;
                    response.isMobilePhone = false;
                } else {
                    if (phone.length() == 10) {
                        if (phone.startsWith('04')) {
                            response.formattedPhoneNumber = phone.substring(0, 4) + ' ' + phone.substring(4, 7) + ' ' + phone.substring(7, 10);
                            response.isMobilePhone = true;
                        } else {
                            response.formattedPhoneNumber = phone.substring(0, 2) + ' ' + phone.substring(2, 6) + ' ' + phone.substring(6, 10);
                            response.isMobilePhone = false;
                        }
                    } else {
                        if (phone.length() == 11 && phone.startsWith('61')) {
                            response.formattedPhoneNumber = '0' + phone.substring(2, 3) + ' ' + phone.substring(3, 7) + ' ' + phone.substring(7, 11);
                            response.isMobilePhone = false;
                        } else {
                            response.isMobilePhone = false;
                            response.formattedPhoneNumber = phone;
                        }
                    }
                }

            }

            responses.add(response);
        }

        return responses;
    }

    global class InvocableRequest {

        @InvocableVariable(label='Input phoneNumber')
        global String phoneNumber;
    }

    global class InvocableResponse {
        @InvocableVariable(label='Phone number')
        global String formattedPhoneNumber;

        @InvocableVariable(label='Is Mobile Phone')
        global Boolean isMobilePhone;
    }

}