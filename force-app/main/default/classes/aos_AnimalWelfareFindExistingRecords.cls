public without sharing class aos_AnimalWelfareFindExistingRecords extends aos_AbstractProcessor implements aos_Structs.IRollbackable {

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.findRecords();

        return this.response;
    }

    private void findRecords() {
        Contact contactVar = new Contact();
        animalos__Job__c jobVar = new animalos__Job__c();

        this.request.getMapper().mapToSObject('jobContact.animalos__Contact__r', contactVar);
        this.request.getMapper().mapToSObject('job', jobVar);

        if (String.isNotBlank(contactVar.MailingStreet)) {
            this.response.put('locationId', ((animalos__Location_Of_Interest__c) aos_Utils.arrays.firstOrNull([
                    SELECT Id
                    FROM animalos__Location_Of_Interest__c
                    WHERE animalos__Address__Street__s = :contactVar.MailingStreet
                    AND animalos__Address__PostalCode__s = :contactVar.MailingPostalCode
                    AND animalos__Address__City__s = :contactVar.MailingCity
                    AND animalos__Address__StateCode__s = :contactVar.MailingState
                    LIMIT 1
            ]))?.Id);
        }

        if (String.isNotBlank(jobVar.animalos__Address__Street__s)) {
            this.response.put('jobLocationId', ((animalos__Location_Of_Interest__c) aos_Utils.arrays.firstOrNull([
                    SELECT Id
                    FROM animalos__Location_Of_Interest__c
                    WHERE animalos__Address__Street__s = :jobVar.animalos__Address__Street__s
                    AND animalos__Address__PostalCode__s = :jobVar.animalos__Address__PostalCode__s
                    AND animalos__Address__City__s = :jobVar.animalos__Address__City__s
                    AND animalos__Address__StateCode__s = :jobVar.animalos__Address__StateCode__s
                    LIMIT 1
            ]))?.Id);
        }

        if (String.isNotBlank(jobVar.animalos__Location_Of_Interest__c)) {
            this.response.put('jobLocationId', ((animalos__Location_Of_Interest__c) aos_Utils.arrays.firstOrNull([
                    SELECT Id
                    FROM animalos__Location_Of_Interest__c
                    WHERE Id = :jobVar.animalos__Location_Of_Interest__c
                    LIMIT 1
            ]))?.Id);
        }

        if (String.isBlank(contactVar.Id) && String.isNotBlank(contactVar.LastName)) {
            animalos.FormatService.format(new List<Contact>{
                    contactVar
            });


            Contact existingContact = (Contact) aos_Utils.arrays.firstOrNull([
                    SELECT Id,
                            FirstName,
                            LastName,
                            MobilePhone,
                            Phone,
                            Email,
                            Account.Name,
                            AccountId,
                            animalos__POI_Description__c,
                            ID_Number__c,
                            ID_Type__c,
                            Birthdate,
                            MailingAddress,
                            MailingStreet,
                            MailingCity,
                            MailingCountry,
                            MailingPostalCode,
                            MailingState
                    FROM Contact
                    WHERE LastName != NULL AND LastName = :contactVar.LastName
                    AND FirstName != NULL AND FirstName = :contactVar.FirstName
                    AND (
                            (ID_Number__c != NULL AND ID_Number__c = :contactVar.ID_Number__c)
                            OR (Birthdate != NULL AND Birthdate = :contactVar.Birthdate)
                            OR (Email != NULL AND Email = :contactVar.Email)
                            OR (MobilePhone != NULL AND MobilePhone = :contactVar.MobilePhone)
                            OR (Phone != NULL AND Phone = :contactVar.Phone)
                            OR (MailingStreet != NULL AND MailingStreet = :contactVar.MailingStreet)
                    )
                    LIMIT 1
            ]);

            if (existingContact != null) {
                existingContact.MobilePhone = contactVar.MobilePhone ?? existingContact.MobilePhone;
                existingContact.Phone = contactVar.Phone ?? existingContact.Phone;
                existingContact.Email = contactVar.Email ?? existingContact.Email;
                existingContact.AccountId = contactVar.AccountId ?? existingContact.AccountId;
                existingContact.animalos__POI_Description__c = contactVar.animalos__POI_Description__c ?? existingContact.animalos__POI_Description__c;
                existingContact.ID_Type__c = contactVar.ID_Type__c ?? existingContact.ID_Type__c;
                existingContact.ID_Number__c = contactVar.ID_Number__c ?? existingContact.ID_Number__c;
                existingContact.Birthdate = contactVar.Birthdate ?? existingContact.Birthdate;
                existingContact.MailingCountry = contactVar.MailingCountry ?? existingContact.MailingCountry;
                existingContact.MailingState = contactVar.MailingState ?? existingContact.MailingState;
                existingContact.MailingCity = contactVar.MailingCity ?? existingContact.MailingCity;
                existingContact.MailingStreet = contactVar.MailingStreet ?? existingContact.MailingStreet;
                existingContact.MailingPostalCode = contactVar.MailingPostalCode ?? existingContact.MailingPostalCode;
            }

            this.response.getMapper().mapFromSObject('contact', existingContact);
        }

        this.response.getMapper().mapAnyValue('isContactCentreUser', ((Profile) aos_Utils.arrays.firstOrException([
                SELECT Name
                FROM Profile
                WHERE Id = :UserInfo.getProfileId()
        ])).Name.contains('Contact Centre'));
        this.response.getMapper().mapAnyValue('isInspector', ((Profile) aos_Utils.arrays.firstOrException([
                SELECT Name
                FROM Profile
                WHERE Id = :UserInfo.getProfileId()
        ])).Name.contains('Inspector'));
    }
}