public without sharing class payment_ProcessorFactory {

    public static vertic_AbstractProcessor getPaymentProcessor(npe01__OppPayment__c payment) {
        return getPaymentProcessor(payment.npe01__Payment_Method__c);
    }

//    public static vertic_AbstractProcessor getPaymentProcessor(Payment_Token__c paymentToken) {
//        String paymentMethod = vertic_Utils.sObjects.recordTypeNameById(Payment_Token__c.SObjectType, paymentToken.RecordTypeId);
//        return getPaymentProcessor(paymentMethod);
//    }

    public static vertic_AbstractProcessor getPaymentProcessor(String paymentMethod) {
        String processorName = 'payment_' + paymentMethod + 'PaymentProcessor';

        Type processorType = Type.forName(processorName);
        if (processorType == null) {
            processorName = 'payment_' + paymentMethod + 'Processor';
            processorType = Type.forName(processorName);
        }
        vertic_AbstractProcessor paymentProcessor;
        if (processorType != null) {
            paymentProcessor = (vertic_AbstractProcessor) processorType.newInstance();
        }

        if (processorType == null || paymentProcessor == null) {
            throw new vertic_Structs.NotFoundException('Payment Processor with name \'' + processorName + '\' not found.');
        }

        return paymentProcessor;
    }

    public static SObject getGatewayCredentials(npe01__OppPayment__c payment) {
        return getGatewayCredentials(payment.npe01__Payment_Method__c);
    }

//    public static SObject getGatewayCredentials(Payment_Token__c paymentToken) {
//        String paymentMethod = vertic_Utils.sObjects.recordTypeNameById(Payment_Token__c.SObjectType, paymentToken.RecordTypeId);
//        return getGatewayCredentials(paymentMethod, paymentToken.Sub_Type__c);
//    }

    public static SObject getGatewayCredentials(String paymentMethod) {
        return getGatewayCredentials(paymentMethod, null);
    }

    private static Map<String, SObject> gatewayCredentialsCache = new Map<String, SObject>();

    public static SObject getGatewayCredentials(String paymentMethod, String subType) {

        if (Test.isRunningTest()) {
            if ('EziDebit'.equalsIgnoreCase(paymentMethod)) {
                return new Payment_EziDebit_Settings__mdt(
                    Endpoint__c = 'https://api.demo.ezidebit.com.au/v3-5',
                    Digital_Key__c = 'test'
                );
            }
        }


        String cacheKey = String.format('{0}-{1}', new List<String>{
            paymentMethod, subType
        });
        if (gatewayCredentialsCache.containsKey(cacheKey)) {
            return gatewayCredentialsCache.get(cacheKey);
        }

        SObjectType paymentSettingSObjType = Schema.getGlobalDescribe().get('Payment_' + paymentMethod + '_Settings__mdt');

        if (paymentSettingSObjType == null) {
            return null;
        }

        String settingName = (String.isNotBlank(subType) ? subType + '_' : '').toUpperCase() + 'PAYMENT_GATEWAY_INSTANCE';

        SObject credentials = vertic_SettingService.getMetadataType(
            paymentSettingSObjType,
            vertic_SettingService.getValue(
                settingName,
                vertic_SettingService.getValue(
                    'PAYMENT_GATEWAY_INSTANCE',
                    'Sandbox'
                )
            )
        );

        if (credentials == null) {
            throw new vertic_Structs.MissingDataException('No active Payment Credentials for payment method: ' + cacheKey);
        }

        gatewayCredentialsCache.put(cacheKey, credentials);

        return credentials;
    }

}