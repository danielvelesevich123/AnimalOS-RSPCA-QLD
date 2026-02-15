public inherited sharing class PersonUpsertProc extends vertic_AbstractProcessor {


    public override vertic_Response process(vertic_Request request) {

        this.request = request;

        String personJSON = this.request.getString('personJSON');

        System.debug(personJSON);

        vertic_DTO dto = new vertic_DTO(personJSON);
        Contact personVar = new Contact();

        System.debug(JSON.serializePretty(dto.getMap()));
        System.debug(dto.getString('LastName'));
        System.debug(dto.getString('Gender'));

        mapPerson(personVar, dto);

        personVar.LastName = vertic_Utils.strings.defaultIfBlank(personVar.LastName, '.');

        if(String.isNotBlank(personVar.ShelterBuddy_ID_PID__c)) {
            Contact existingPersonVar = (Contact) vertic_Utils.arrays.firstOrNull([
                    SELECT Id
                    FROM Contact
                    WHERE ShelterBuddy_ID_PID__c = :personVar.ShelterBuddy_ID_PID__c
            ]);
            if(existingPersonVar != null) {
                personVar.Id = existingPersonVar.Id;
            }
        }
        if(personVar.Id == null) {
            vertic_Utils.sObjects.deduplicate(personVar);
        }

        ShelterBuddySyncPersonProc.IS_SYNC_ENABLED = false; // Turn off Person Sync in the Contact TDTM.
        upsert personVar;

        insert new aos_Async_Process__c(
                aos_Processor__c = '' + PersonUpsertProc.class,
                aos_Payload__c = JSON.serializePretty(new Map<String, Object>{
                        'personJSON' => personJSON,
                        'personDTO' => dto.getMap()
                }),
                aos_Details__c = JSON.serializePretty(personVar),
                aos_Autorun__c = false,
                aos_Status__c = 'Completed',
                aos_Description__c = 'Person Webhook',
                aos_Group_Key__c = personVar.Id
        );

//        insert new aos_Async_Process__c(
//            Processor__c = '' + ShelterBuddyDispatchPersonProc.class,
//            Payload__c = JSON.serialize(new Map<String, String>{
//                'recordId' => personVar.Id
//            }),
//            Autorun__c = true,
//            Description__c = 'Dispatch Person',
//            Group_Key__c = personVar.Id
//        );

        this.response.put('person', personVar);

        return this.response;
    }

    private static void mapPerson(Contact contactVar, vertic_DTO dto){
        Map<SObjectField, String> SFToShelterBuddyMap = new Map<SObjectField, String> {
                Contact.ShelterBuddy_ID_PID__c => 'Id',
                Contact.Salutation => 'Title',
                Contact.Nickname__c => 'Nickname',
                Contact.LastName => 'LastName',
                Contact.FirstName => 'FirstName',
                Contact.MiddleName => 'MiddleName',
                Contact.MailingStreet => 'MailingAddress.Line1',
                Contact.MailingPostalCode => 'MailingAddress.Postcode',
                Contact.MailingCity => 'MailingAddress.Suburb.Name',
                Contact.MailingState => 'MailingAddress.State.Abbreviation',
                Contact.MailingCountry => 'MailingAddress.Country.Name',
                Contact.OtherStreet => 'PhysicalAddress.Line1',
                Contact.OtherPostalCode => 'PhysicalAddress.Postcode',
                Contact.OtherCity => 'PhysicalAddress.Suburb.Name',
                Contact.OtherState => 'PhysicalAddress.State.Abbreviation',
                Contact.OtherCountry => 'PhysicalAddress.Country.Name',
                Contact.HomePhone => 'HomePhone.PhoneNumber',
                Contact.MobilePhone => 'MobilePhone.PhoneNumber',
                Contact.npe01__WorkPhone__c => 'WorkPhone.PhoneNumber',
                Contact.Last_ShelterBuddy_Sync__c => 'LastUpdateDateTimeUtc',
                Contact.Last_ShelterBuddy_Sync_String__c => 'LastUpdateDateTimeUtc'
        };

        ShelterBuddyService.mapShelterBuddyToSobject(SFToShelterBuddyMap, dto, contactVar);

        if('UNKNOWN'.equalsIgnoreCase(contactVar.MailingStreet)){
            contactVar.MailingStreet = null;
            contactVar.MailingState = null;
            contactVar.MailingCity = null;
            contactVar.MailingCountry = null;
            contactVar.MailingPostalCode = null;
        }

        if(dto.getISODate('DateOfBirthUtc') != null){
            contactVar.Birthdate = dto.getISODate('DateOfBirthUtc');
        }

        setEmails(contactVar, dto.getList('Emails'));
        setBPayNumbers(contactVar, dto.getList('BPayNumbers'));
        setGender(contactVar, dto.getString('Gender'));
    }

    private static void setGender(Contact contactVar, String gender){
        Set<String> genders = new Set<String>{'Male', 'Female'};
        Set<String> sfOnlyGenders = new Set<String>{'Non-Binary', 'Prefer not to say'};

        if (String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c)) {
            Contact existingPersonVar = (Contact) vertic_Utils.arrays.firstOrNull([
                    SELECT Id, Gender__c
                    FROM Contact
                    WHERE ShelterBuddy_ID_PID__c = :contactVar.ShelterBuddy_ID_PID__c
            ]);
            if (existingPersonVar != null) {

                System.debug('person found');
                System.debug(existingPersonVar);
                System.debug(String.isNotBlank(existingPersonVar.Gender__c));
                System.debug(genders.contains(existingPersonVar.Gender__c));
                System.debug(sfOnlyGenders.contains(existingPersonVar.Gender__c));
                System.debug(String.isBlank(gender));

                if(String.isNotBlank(existingPersonVar.Gender__c) && genders.contains(existingPersonVar.Gender__c) && String.isBlank(gender)){
                    return;
                } else if(String.isNotBlank(existingPersonVar.Gender__c) && sfOnlyGenders.contains(existingPersonVar.Gender__c)){
                    return;
                } else if(String.isBlank(existingPersonVar.Gender__c) || (String.isNotBlank(existingPersonVar.Gender__c) && genders.contains(existingPersonVar.Gender__c)) && String.isNotBlank(gender)){
                    contactVar.Gender__c = gender;
                }
            } else {
                contactVar.Gender__c = gender;
            }
        }
    }

    private static void setEmails(Contact contactVar, List<Object> emails) {
        List<SObjectField> fields = new List<SObjectField>();

        List<SObjectField> preferredPersonalFields = new List<SObjectField>{
                Contact.npe01__WorkEmail__c, Contact.npe01__AlternateEmail__c
        };

        List<SObjectField> preferredWorkFields = new List<SObjectField>{
                Contact.npe01__HomeEmail__c, Contact.npe01__AlternateEmail__c
        };

        List<SObjectField> preferredAlternateFields = new List<SObjectField>{
                Contact.npe01__HomeEmail__c, Contact.npe01__WorkEmail__c
        };

        Map<String, SObjectField> emailFieldsByName = new Map<String, SObjectField>{
                'Work' => Contact.npe01__WorkEmail__c,
                'Personal' => Contact.npe01__HomeEmail__c,
                'Alternate' => Contact.npe01__AlternateEmail__c
        };

        if (String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c)) {
            Contact existingPersonVar = (Contact) vertic_Utils.arrays.firstOrNull([
                    SELECT Id, npe01__Preferred_Email__c
                    FROM Contact
                    WHERE ShelterBuddy_ID_PID__c = :contactVar.ShelterBuddy_ID_PID__c
            ]);
            if (existingPersonVar != null) {
                contactVar.npe01__Preferred_Email__c = existingPersonVar.npe01__Preferred_Email__c;
            } else{
                contactVar.npe01__Preferred_Email__c = 'Personal';
            }
        }

        switch on contactVar.npe01__Preferred_Email__c {
            when 'Personal'{
                fields.addAll(preferredPersonalFields);
            }
            when 'Work'{
                fields.addAll(preferredWorkFields);
            }
            when 'Alternate'{
                fields.addAll(preferredAlternateFields);
            }
            when else{
                fields.addAll(preferredPersonalFields);
            }
        }

        if (emails == null || emails.isEmpty()) {
//            for (SObjectField field : fields) {
//                contactVar.put(field, null);
//            }
            return;
        }

        Integer primaryIndex = 0;

        for(Object emailObject : emails){
            vertic_DTO dto = new vertic_DTO((Map<String, Object>) emailObject);
            Boolean isPrimary = dto.getBoolean('IsPrimary');

            if(isPrimary){
                primaryIndex = emails.indexOf(emailObject);
            }
        }

        Object primaryEmailObject = emails.get(primaryIndex);

        String primaryEmail = new vertic_DTO((Map<String, Object>) emails.remove(primaryIndex)).getString('EmailAddress');

        System.debug(contactVar.npe01__Preferred_Email__c);
        System.debug(emailFieldsByName.get(contactVar.npe01__Preferred_Email__c));
        System.debug(primaryEmail);

        contactVar.put(emailFieldsByName.get(contactVar.npe01__Preferred_Email__c != null ? contactVar.npe01__Preferred_Email__c : 'Personal'), primaryEmail);

        System.debug(emails);
        System.debug(emails.size());


        Integer index = 0;
        for (Object emailObj : emails) {
            if(index == 2){
                break;
            }

            vertic_DTO dto = new vertic_DTO((Map<String, Object>) emailObj);
            String email = dto.getString('EmailAddress');
            Boolean isPrimary = dto.getBoolean('IsPrimary');

            contactVar.put(fields[index], email);


            index++;
        }

        emails.add(primaryEmailObject);
    }

    private static void setBPayNumbers(Contact contactVar, List<Object> bPayNumbers) {
        List<SObjectField> fields = new List<SObjectField>{
                Contact.BPAY_CRN__c, Contact.BPAY_CRN_History__c
        };
        if (bPayNumbers == null || bPayNumbers.isEmpty()) {
            for (SObjectField field : fields) {
                contactVar.put(field, null);
            }
            return;
        }

        if (String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c)) {
            Contact existingPersonVar = (Contact) vertic_Utils.arrays.firstOrNull([
                    SELECT Id, BPAY_CRN__c, BPAY_CRN_History__c
                    FROM Contact
                    WHERE ShelterBuddy_ID_PID__c = :contactVar.ShelterBuddy_ID_PID__c
            ]);
            if (existingPersonVar != null) {
                if(String.isNotBlank(existingPersonVar.BPAY_CRN__c)){
                    List<String> sfBpayIds = new List<String>();
                    List<String> sbBpayIds = new List<String>();

                    Set<String> historyBpayIds = new Set<String>();

                    sfBpayIds.add(existingPersonVar.BPAY_CRN__c);

                    if(String.isNotBlank(existingPersonVar.BPAY_CRN_History__c)){
                        sfBpayIds.addAll(existingPersonVar.BPAY_CRN_History__c.split(','));
                    }

                    for (Object bPayObj : bPayNumbers) {
                        vertic_DTO dto = new vertic_DTO((Map<String, Object>) bPayObj);
                        sbBpayIds.add(dto.getString('Number'));
                    }

                    historyBpayIds.addAll(sfBpayIds);
                    historyBpayIds.addAll(sbBpayIds);

                    if(historyBpayIds.contains(existingPersonVar.BPAY_CRN__c)){
                        historyBpayIds.remove(existingPersonVar.BPAY_CRN__c);
                    }

                    contactVar.BPAY_CRN_History__c = String.join(new List<String>(historyBpayIds), ',');

                    return;
                } else{
                    List<String> sfBpayIds = new List<String>();
                    List<String> sbBpayIds = new List<String>();

                    Set<String> historyBpayIds = new Set<String>();

                    if(String.isNotBlank(existingPersonVar.BPAY_CRN_History__c)){
                        sfBpayIds.addAll(existingPersonVar.BPAY_CRN_History__c.split(','));
                    }

                    String bpayCRN = '';

                    for (Object bPayObj : bPayNumbers) {
                        vertic_DTO dto = new vertic_DTO((Map<String, Object>) bPayObj);

                        if(dto.getBoolean('IsHistory') == false){
                            bpayCRN = dto.getString('Number');
                            continue;
                        }

                        sbBpayIds.add(dto.getString('Number'));
                    }

                    historyBpayIds.addAll(sfBpayIds);
                    historyBpayIds.addAll(sbBpayIds);

                    if(historyBpayIds.contains(bpayCRN)){
                        historyBpayIds.remove(bpayCRN);
                    }

                    contactVar.BPAY_CRN__c = bpayCRN;
                    contactVar.BPAY_CRN_History__c = String.join(new List<String>(historyBpayIds), ',');

                    return;
                }
            }
        }

        Object removedBpayNumber = bPayNumbers.get(bPayNumbers.size() - 1);

        vertic_DTO lastNumber = new vertic_DTO((Map<String, Object>) bPayNumbers.remove(bPayNumbers.size() - 1));
        contactVar.BPAY_CRN__c = lastNumber.getString('Number');

        List<String> historyNumbers = new List<String>();
        for (Object bPayObj : bPayNumbers) {
            vertic_DTO dto = new vertic_DTO((Map<String, Object>) bPayObj);
            historyNumbers.add(dto.getString('Number'));
        }

        contactVar.BPAY_CRN_History__c = String.join(historyNumbers, ',');

        bPayNumbers.add(removedBpayNumber);
    }

//    private static void setEmails(Contact contactVar, List<Object> emails) {
//        List<SObjectField> fields = new List<SObjectField> {
//                Contact.Email, Contact.npe01__HomeEmail__c, Contact.npe01__WorkEmail__c, Contact.npe01__AlternateEmail__c
//        };
//        if(emails == null) {
//            for(SObjectField field : fields) {
//                contactVar.put(field, null);
//            }
//            return;
//        }
//
//        Integer index = 0;
//        for(Object emailObj : emails) {
//            vertic_DTO dto = new vertic_DTO((Map<String, Object>)emailObj);
//            String email = dto.getString('EmailAddress');
//            contactVar.put(fields[index], email);
//            index++;
//        }
//    }
}