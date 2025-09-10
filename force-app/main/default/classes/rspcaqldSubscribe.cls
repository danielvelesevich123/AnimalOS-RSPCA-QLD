public without sharing class rspcaqldSubscribe {
    @AuraEnabled(cacheable=true)
    public static void doSubscribe(String firstName, String lastName, String email) {
        doSubscribeFuture(firstName, lastName, email);
    }

    @future
    private static void doSubscribeFuture(String firstName, String lastName, String email) {
        Contact cntct = upsertContact(firstName, lastName, email);
        createCase(cntct.Id);
    }

    private static Contact upsertContact(String firstName, String lastName, String email) {
        List<Contact> cntctList = [SELECT Id
                                    FROM Contact
                                    WHERE FirstName =: firstName AND
                                    LastName =: lastName AND (
                                            npe01__AlternateEmail__c =: email OR
                                            npe01__HomeEmail__c =: email OR
                                            npe01__WorkEmail__c =: email
                                    )
        ];

        Contact cntct = !cntctList.isEmpty() ? cntctList[0] : new Contact(
            FirstName = firstName,
            LastName = lastName,
            npe01__HomeEmail__c = email,
            npe01__Preferred_Email__c = 'Personal'
        );

        cntct.eNews_Subscriber__c = TRUE;
        cntct.Privacy_Policy_and_Terms_and_Conditions__c = TRUE;
        cntct.eNews_Subscription_Date__c = Datetime.now();
        cntct.npsp__Do_Not_Contact__c = FALSE;
        cntct.HasOptedOutOfEmail = FALSE;

        upsert cntct;
        return cntct;
    }

    private static void createCase(Id cntctId) {
        Contact cntct = [SELECT Id, AccountId, Account.Name, LastName, Email, Phone, Name FROM Contact WHERE Id =: cntctId LIMIT 1];

        Case cs = new Case(
            ContactId = cntct.Id,
            AccountId = cntct.AccountId,
            Marketing_OptIn__c = true,
            Marketing_OptIn_Date__c = System.now(),
            Privacy_Policy__c = true,
            Status = 'New',
            Origin = 'Web',
            Priority = 'Medium',
            Type = 'Question',
            Reason = 'Email Subscribe',
            Subject = String.format('{0} {1}', new List<String>{'Email Subscribe', cntct.LastName}),
            SuppliedEmail = cntct.Email,
            SuppliedName = cntct.Name,
            SuppliedCompany = cntct.Account.Name,
            SuppliedPhone = cntct.Phone
        );
        insert cs;
    }
}