public without sharing class SendEmailAsyncProcessInvocable {

    @InvocableMethod(label='Send Email Async Process Invocable')
    public static void process(List<InvocableRequest> requests) {

        process(requests.get(0));

    }

    private static void process(InvocableRequest request) {

        String defaultOrgWideEmail = String.isNotBlank(request.settingsOrgWideEmailAddress)
                                    ? vertic_SettingService.getValue(request.settingsOrgWideEmailAddress, request.orgWideEmailAddress)
                                    : request.orgWideEmailAddress;

//        vertic_SendEmailProc.EmailAsyncProcess emailAsyncProcessVar;

        Map<String, Object> emailParametersMap = getEmailParametersMap(request);

        emailParametersMap.put('renderAs', 'html');

        // contentPreviewJSONParams
        // '{\"cmp\": \"AOS_JobSummaryQA\", \"jobId\": \"'
        // + {!recordId.Id}
        // + '\", \"contactId\": \"'
        // + {!contactVar.Id}
        // + '\", \"renderAs\": \"pdf\", \"fileName\": \"Job Summary\"}'

        // emailParametersMap
        // "vfComponent=AOS_JobSummaryQA;jobId=" &
        // {!recordId.Id} &
        // ";contactId=" &
        // {!contactVar.Id}

//        emailAsyncProcessVar = new vertic_SendEmailProc.EmailAsyncProcess(
//            (String) emailParametersMap.get('vfComponent'),
//                emailParametersMap
//        ).setTargetId(request.contactId)
//                .setOrgWideEmail(defaultOrgWideEmail)
//                .setSaveAsActivity(request.saveAsActivity)
//                .setSubject(request.subject);

//        Vertic_Async_Process__c asyncProc = emailAsyncProcessVar.toAsyncProcess();
//
//        asyncProc.Group_Key__c = request.recordId;
//
//        new vertic_AsyncProcess().add(asyncProc).enqueue();

    }

    private static Map<String, Object> getEmailParametersMap(InvocableRequest request) {

        Map<String, Object> emailParametersMap = new Map<String, Object>();

        if (String.isNotBlank(request.emailParametersMap)) {
            // Example format: key1=value1;key2=value2;key3=value3
            List<String> pairs = request.emailParametersMap.split(';');
            for (String pair : pairs) {
                if (pair.contains('=')) {
                    List<String> kv = pair.split('=');
                    if (kv.size() == 2) {
                        emailParametersMap.put(kv[0].trim(), kv[1].trim());
                    }
                }
            }
        }

        return emailParametersMap;
    }

    public class InvocableRequest {

        @InvocableVariable(label='Contact Id')
        public String contactId;

        @InvocableVariable(label='Record Id')
        public String recordId;

        @InvocableVariable(label='Email Parameters Map')
        public String emailParametersMap;

        @InvocableVariable(label='Org Wide Email Address')
        public String orgWideEmailAddress;

        @InvocableVariable(label='Setting Org Wide Email Address')
        public String settingsOrgWideEmailAddress;

        @InvocableVariable(label='Save As Activity')
        public Boolean saveAsActivity;

        @InvocableVariable(label='Email Subject')
        public String subject;

    }
}