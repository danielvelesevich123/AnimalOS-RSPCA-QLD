public without sharing class rspcaqldPageWelfareComplaintCtrl {
    @AuraEnabled
    public static void doSubmit(String contactString, String caseString, String welfareString, String filesString, String locationFilesString) {
        Map<String, Object> contactMap = (Map<String, Object>) JSON.deserializeUntyped(contactString);
        Map<String, Object> caseMap = (Map<String, Object>) JSON.deserializeUntyped(caseString);
        Map<String, Object> welfareMap = (Map<String, Object>) JSON.deserializeUntyped(welfareString);
        List<FileWrapper> files = (List<FileWrapper>) JSON.deserialize(filesString, List<FileWrapper>.class);
        List<FileWrapper> locationFiles = (List<FileWrapper>) JSON.deserialize(locationFilesString, List<FileWrapper>.class);
        files.addAll(locationFiles);

        Contact cntct = handleContact(contactMap, caseMap);
        Welfare_Report__c welfare = handleWelfare(cntct, welfareMap);
        Case cs = handleCase(cntct, caseMap, 'Related_Welfare_Report__c', welfare.Id, 'Animal Welfare Report', 'Welfare form lodgement', 'Animal Welfare Report');
        welfare.Case__c = cs.Id;
        update welfare;

        if (files != null && !files.isEmpty()) insertContentDocumentLinks(welfare.Id, files);
    }

    public static Contact handleContact(Map<String, Object> contactMap, Map<String, Object> caseMap) {
        Contact cntct = rspcaqldCtaFormCtrl.initContact(contactMap);
        Boolean marketingOptIn = (Boolean) caseMap.get('marketingOptIn');

        if (cntct.Id == null) {
            String phone = (String) contactMap.get('phone');
            rspcaqldCtaFormCtrl.initPhone(cntct, phone);

            cntct.OtherPhone = (String) contactMap.get('alternatePhone');
            cntct.MailingStreet = (String) contactMap.get('street');
            cntct.MailingState = (String) contactMap.get('state');
            cntct.MailingCity = (String) contactMap.get('city');
            cntct.MailingPostalCode = (String) contactMap.get('postalCode');
            cntct.MailingCountry = (String) contactMap.get('country');
            if (contactMap.containsKey('birthdate')) cntct.Birthdate = initDatetime((String) contactMap.get('birthdate'), null).date();

            if (marketingOptIn) {
                cntct.eNews_Subscriber__c = TRUE;
                cntct.eNews_Subscription_Date__c = Datetime.now();
            }

            upsert cntct;
            cntct = [SELECT Id, AccountId, Account.Name, LastName, Email, Phone, Name FROM Contact WHERE Id =: cntct.Id LIMIT 1];
        }

        return cntct;
    }

    public static Case handleCase(Contact cntct, Map<String, Object> caseMap, String relationField, String relationvalue, String caseType, String caseReason, String caseSubject) {
        Boolean marketingOptIn = (Boolean) caseMap.get('marketingOptIn');

        Case cs = new Case(
            ContactId = cntct.Id,
            AccountId = cntct.AccountId,
            Priority = 'Medium',
            Marketing_OptIn__c = marketingOptin,
            Marketing_OptIn_Date__c = marketingOptin ? System.now() : null,
            Privacy_Policy__c = true,
            Origin = 'Web',
            Type = caseType,
            Status = 'New',
            Reason = caseReason,
            Subject = String.format('{0} {1}', new List<String>{caseSubject, cntct.LastName}),
            SuppliedEmail = cntct.Email,
            SuppliedName = cntct.Name,
            SuppliedPhone = cntct.Phone
        );
        cs.put(relationField, relationvalue);
        insert cs;

        return cs;
    }

    private static Welfare_Report__c handleWelfare(Contact cntct, Map<String, Object> welfareMap) {
        Welfare_Report__c welfareReport = new Welfare_Report__c(
            Contact__c = cntct.Id,
            Welfare_Declaration__c = true,
            POI_Age_Declaration__c = (String) welfareMap.get('poiAgeDeclaration'),
            POI_First_Name__c = (String) welfareMap.get('firstName'),
            POI_Last_Name__c = (String) welfareMap.get('lastName'),
            POI_Establishment__c = (String) welfareMap.get('establishmentName'),
            Relationship_to_POI__c = (String) welfareMap.get('personOfInterest'),
            POI_Street_Number__c = (String) welfareMap.get('locationHouseNumber'),
            POI_Street_Name__c = (String) welfareMap.get('locationStreet'),
            POI_City__c = (String) welfareMap.get('locationCity'),
            POI_State__c = (String) welfareMap.get('locationState'),
            POI_Postcode__c = (String) welfareMap.get('locationPostcode'),
            POI_Geo_Location__c = (String) welfareMap.get('geolocation'),
            POI_Description__c = (String) welfareMap.get('poiDescription'),
            Inspector_Hazard__c = (String) welfareMap.get('inspectorHazard'),
            Directions__c = (String) welfareMap.get('directions'),
            Observations__c = (String) welfareMap.get('observations'),
            Number_of_Animals__c = Integer.valueOf((String) welfareMap.get('animalsNumber')),
            Animal_Description__c = (String) welfareMap.get('animalDescription'),
            Animal_Injuries__c = (String) welfareMap.get('injuries'),
            Incident_Date_and_Time__c = initDatetime((String) welfareMap.get('date'), (String) welfareMap.get('time')),
            Animal_Last_Seen__c = initDatetime((String) welfareMap.get('lastSeenDate'), (String) welfareMap.get('lastSeenTime'))
        );
        insert welfareReport;
        return welfareReport;
    }

    private static Datetime initDatetime(String dateString, String timeString) {
        List<String> dateArray = dateString.split('-');
        Date dt = Date.newInstance(Integer.valueOf(dateArray[0]), Integer.valueOf(dateArray[1]), Integer.valueOf(dateArray[2]));
        if (String.isNotEmpty(timeString)) {
            String minute;
            Integer hour = Integer.valueOf(timeString.split(':')[0]);
            if (timeString.endsWithIgnoreCase('am') || timeString.endsWithIgnoreCase('pm')) {
                minute = timeString.split(':')[1].removeEndIgnoreCase('am').removeEndIgnoreCase('pm');
                minute = minute.replaceAll(' ', '');

                if (timeString.endsWithIgnoreCase('am')) {
                    if (hour == 12) hour = 00;
                } else {
                    if (hour != 12) hour += 12;
                }
            } else {
                minute = timeString.split(':')[1];
            }

            Time tm = Time.newInstance(hour, Integer.valueOf(minute), 0, 0);

            return Datetime.newInstance(dt, tm);
        } else {
            return Datetime.newInstance(dt.year(), dt.month(), dt.day());
        }
    }

    public static void insertContentDocumentLinks(String parentId, List<FileWrapper> files) {
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();

        Set<String> contentVersionIds = new Set<String>();
        for (FileWrapper file : files) {
            if (String.isNotEmpty(file.contentVersionId)) contentVersionIds.add(file.contentVersionId);
        }

        List<ContentVersion> cvList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionIds];

        for (ContentVersion cv : cvList) {
            contentDocumentLinkList.add(
                new ContentDocumentLink(
                    LinkedEntityId = parentId,
                    ContentDocumentId = cv.ContentDocumentId,
                    ShareType = 'V'
                )
            );
        }
        insert contentDocumentLinkList;
    }

    public class FileWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String documentId;
        @AuraEnabled public String contentVersionId;
    }
}