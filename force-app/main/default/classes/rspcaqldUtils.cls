public without sharing class rspcaqldUtils {
    @AuraEnabled
    public static Map<String, String> getContentData(List<String> ids) {
        Map<String, String> dataMap = new Map<String, String>();
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId, VersionData FROM ContentVersion WHERE Id IN: ids];
        for (ContentVersion cv : contentVersionList) {
            dataMap.put(cv.Id, EncodingUtil.base64Encode(cv.VersionData));
        }

        return dataMap;
    }

    @AuraEnabled
    public static void deleteDocument(String documentId) {
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: documentId];
        delete [SELECT Id FROM ContentDocument WHERE Id =:contentVersionList[0].ContentDocumentId];
    }

    @AuraEnabled(cacheable=true)
    public static Portal_Settings__c getPortalCustomSetting() {
        Portal_Settings__c portalSettings = Portal_Settings__c.getOrgDefaults();
        return portalSettings;
    }

    @AuraEnabled(cacheable=true)
    public static Portal_Setting__mdt getPortalSetting(String customMetadataName) {
        Portal_Setting__mdt cm = Portal_Setting__mdt.getInstance(String.isNotEmpty(customMetadataName) ? customMetadataName : 'Main');
        return cm != null ? cm : (String.isNotEmpty(customMetadataName) ? Portal_Setting__mdt.getInstance('Main') : null);
    }

    @AuraEnabled(cacheable=true)
    public static List<SelectOption> getPicklistValues(String fieldName) {
        List<String> fieldList = fieldName.split('\\.');
        Schema.SObjectField sObjField = Schema.getGlobalDescribe().get(fieldList[0]).getDescribe().fields.getMap().get(fieldList[1]);
        List<Schema.PicklistEntry> pickListEntries = sObjField.getDescribe().getPicklistValues();
        List<SelectOption> sList = new List<SelectOption>();

        for( Schema.PicklistEntry pickListEntry : pickListEntries){
            sList.add(new SelectOption(pickListEntry.getValue(), pickListEntry.getLabel()));
        }

        return sList;
    }

    //----------Stripe Methods----------
    @AuraEnabled(cacheable=true)
    public static String getStripePublishableKey() {
        return npsp_plus.SettingsService.getStripePublishableKey();
    }

    @AuraEnabled
    public static String getHttp(String strURL) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req);
        return res.getBody();
    }

    public class SelectOption {
        @AuraEnabled public String value;
        @AuraEnabled public String label;
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
}