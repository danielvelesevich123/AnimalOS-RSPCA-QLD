public without sharing class rspcaqldCtaFormCtrl {
    @AuraEnabled(cacheable=true)
    public static void doSubmit(String contactString, String caseString) {
        doSubmitFuture(contactString, caseString);
    }

    @future
    private static void doSubmitFuture(String contactString, String caseString) {
        Map<String, Object> contactMap = (Map<String, Object>) JSON.deserializeUntyped(contactString);
        Map<String, Object> caseMap = (Map<String, Object>) JSON.deserializeUntyped(caseString);
        Contact cntct = handleContact(contactMap);
        String partnershipType = (String) caseMap.get('partnershipType');
        String educationType = (String) caseMap.get('educationType');
        String reason = (String) caseMap.get('reason');
        String organisation = (String) contactMap.get('organisation');
        String location = (String) caseMap.get('location');
        String preferredContactMethod = (String) caseMap.get('preferredContactMethod');
        Boolean volunteerDeclaration = (Boolean) caseMap.get('volunteerDeclaration');
        Boolean marketingOptin = (Boolean) caseMap.get('marketingOptin');

        Case cs = new Case(
            ContactId = cntct.Id,
            AccountId = cntct.AccountId,
            Partnership_Enquiry_Type__c = String.isNotEmpty(partnershipType) ? partnershipType.replaceAll('; ', ';') : null,
            Education_Enquiry_Type__c = String.isNotEmpty(educationType) ? educationType.replaceAll('; ', ';') : null,
            Description = (String) caseMap.get('description'),
            Marketing_OptIn__c = marketingOptin,
            Marketing_OptIn_Date__c = marketingOptin ? System.now() : null,
            Privacy_Policy__c = true,
            Status = 'New',
            Origin = 'Web',
            Priority = 'Medium',
            Type = 'Question',
            Reason = reason,
            Subject = String.format('{0} {1}', new List<String>{reason, cntct.LastName}),
            SuppliedEmail = cntct.Email,
            SuppliedName = cntct.Name,
            SuppliedCompany = String.isNotEmpty(organisation) ? organisation : cntct.Account.Name,
            SuppliedPhone = cntct.Phone,
            Preferred_Location__c = location,
            Preferred_Contact_Method__c = preferredContactMethod,
            Volunteer_Declaration__c = volunteerDeclaration != null ? volunteerDeclaration : false
        );
        insert cs;
    }

    private static Contact handleContact(Map<String, Object> contactMap) {
        Contact cntct = initContact(contactMap);

        if (cntct.Id == null) {
            String phone = (String) contactMap.get('phone');
            String organisation = (String) contactMap.get('organisation');

            if (String.isNotEmpty(organisation)) cntct.npsp__Primary_Affiliation__c = initAccount(organisation);
            initPhone(cntct, phone);

            upsert cntct;
            cntct = [SELECT Id, AccountId, Account.Name, LastName, Email, Phone, Name FROM Contact WHERE Id =: cntct.Id LIMIT 1];
        }

        return cntct;
    }

    public static Contact initContact(Map<String, Object> contactMap) {
        String phone = (String) contactMap.get('phone');
        String firstName = (String) contactMap.get('firstName');
        String lastName = (String) contactMap.get('lastName');
        String email = (String) contactMap.get('email');

        List<Contact> cntctList = [SELECT Id, AccountId, Account.Name, LastName, Email, Phone, Name
                                   FROM Contact
                                   WHERE FirstName =: firstName AND
                                         LastName =: lastName AND (
                                                npe01__AlternateEmail__c =: email OR
                                                npe01__HomeEmail__c =: email OR
                                                npe01__WorkEmail__c =: email OR
                                                HomePhone =: phone OR
                                                npe01__WorkPhone__c =: phone OR
                                                MobilePhone =: phone
                                         )
        ];

        Contact cntct = !cntctList.isEmpty() ? cntctList[0] : new Contact(
            FirstName = firstName,
            LastName = lastName,
            npe01__HomeEmail__c = email,
            npe01__Preferred_Email__c = 'Personal'
        );

        return cntct;
    }

    private static Id initAccount(String organisation) {
        List<Account> accntList = [SELECT Id FROM Account WHERE Name =: organisation LIMIT 1];
        Account accnt = !accntList.isEmpty() ? accntList[0] : new Account(Name = organisation);
        if (accnt.Id == null) insert accnt;
        return accnt.Id;
    }

    public static void initPhone(Contact cntct, String phone) {
        if (phone.startsWith('04')) {
            Pattern p = Pattern.compile('(\\d{4})-?(\\d{3})-?(\\d{3})');
            Matcher m = p.matcher(phone);
            cntct.npe01__PreferredPhone__c = 'Mobile';
            if (m.find()) cntct.MobilePhone = m.group(1) + '-' + m.group(2) + '-' + m.group(3);
        } else {
            Pattern p = Pattern.compile('(\\d{2})-?(\\d{4})-?(\\d{4})');
            Matcher m = p.matcher(phone);
            cntct.npe01__PreferredPhone__c = 'Home';
            if (m.find()) cntct.HomePhone = m.group(1) + '-' + m.group(2) + '-' + m.group(3);
        }
    }
}