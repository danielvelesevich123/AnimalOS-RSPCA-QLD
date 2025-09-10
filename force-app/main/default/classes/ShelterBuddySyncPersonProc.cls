public with sharing class ShelterBuddySyncPersonProc extends vertic_AbstractProcessor {

    public static Boolean IS_SYNC_ENABLED = true;

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        String contactId = this.request.getString('recordId');
        Contact contactVar = (Contact) vertic_Utils.arrays.firstOrException([
                SELECT Id, FirstName, LastName, Nickname__c, MiddleName, Suffix, Salutation,
                        Gender__c, HomePhone, MobilePhone, npe01__WorkPhone__c, Email, npe01__WorkEmail__c, npe01__HomeEmail__c, npe01__AlternateEmail__c,
                        MailingAddress, MailingStreet, MailingPostalCode, MailingState, MailingCity, MailingCountry,
                        OtherAddress, OtherStreet, OtherPostalCode, OtherState, OtherCity, OtherCountry,
                        Title, LastModifiedDate, Birthdate, ShelterBuddy_ID_PID__c, Last_ShelterBuddy_Sync_String__c
                FROM Contact
                WHERE Id = :contactId
        ], 'Contact with id ' + contactId + ' was not fount.');

        System.debug(contactVar);

        // if (String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c)) {
        //     this.response.put('message', 'The Person with ID: ' + contactVar.ShelterBuddy_ID_PID__c + ' is already created for the Contact.');
        //     return this.response;
        // }

        String query = JSON.serializePretty(contactToPerson(contactVar));

        System.debug(query);

        ShelterBuddyAPIUtils shelterBuddyAPIUtils = new ShelterBuddyAPIUtils();
        String callMethod = String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c) ? 'putPerson' : 'postPerson';
        HttpResponse response = new HttpResponse();

        try{
            response = shelterBuddyAPIUtils.commonRequest(callMethod, query);
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        finally{
            shelterBuddyAPIUtils.saveAccessToken();
        }
        
        if (response.getStatusCode() != 200) {
            throw new vertic_Structs.ProcessException(response.getStatusCode() + '\n\n\n' + response.getStatus() + '\n\n\n' + query + '\n\n\n' + response.getBody());
        }

        vertic_DTO responseDTO = new vertic_DTO(response.getBody());
        String personId = responseDTO.getString('Id');

        contactVar.ShelterBuddy_ID_PID__c = personId;
        contactVar.Last_ShelterBuddy_Sync_String__c = responseDTO.getString('LastUpdateDateTimeUtc');
        contactVar.Last_ShelterBuddy_Sync__c = (Datetime) JSON.deserialize(
                '"' + contactVar.Last_ShelterBuddy_Sync_String__c + '"', Datetime.class
        );
        ShelterBuddySyncPersonProc.IS_SYNC_ENABLED = false;
        update contactVar;

        this.response.put('request', query);
        this.response.put('person', responseDTO.getMap());

        return this.response;
    }

    private Map<String, Object> contactToPerson(Contact contactVar) {

        List<Object> emails = new List<Object>();

        if (String.isNotBlank(contactVar.Email)) {
            emails.add(new Map<String, Object>{
                    'EmailAddress' => contactVar.Email,
                    'IsPrimary' => true
            });
        }

        if (String.isNotBlank(contactVar.npe01__HomeEmail__c)) {
            emails.add(new Map<String, Object>{
                    'EmailAddress' => contactVar.npe01__HomeEmail__c,
                    'IsPrimary' => false
            });
        }

        if (String.isNotBlank(contactVar.npe01__WorkEmail__c)) {
            emails.add(new Map<String, Object>{
                    'EmailAddress' => contactVar.npe01__WorkEmail__c,
                    'IsPrimary' => false
            });
        }

        if (String.isNotBlank(contactVar.npe01__AlternateEmail__c)) {
            emails.add(new Map<String, Object>{
                    'EmailAddress' => contactVar.npe01__AlternateEmail__c,
                    'IsPrimary' => false
            });
        }

        Map<String, Object> personMap = new Map<String, Object>{
                'FirstName' => contactVar.FirstName,
                'LastName' => contactVar.LastName,
                'MiddleName' => contactVar.MiddleName,
                'IsActive' => true,
                'UpdatedSinceUtc' => contactVar.LastModifiedDate == null ? null : contactVar.LastModifiedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
                'ExternalId' => contactVar.Id,
                'HasEmail' => String.isNotBlank(contactVar.Email),
                'Nickname' => contactVar.Nickname__c,
                'Title' => contactVar.Salutation,
                'DateOfBirthUtc' => contactVar.Birthdate == null ? null : ((Datetime) contactVar.Birthdate).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
                'RecordTypeId' => 1
        };

        if (String.isNotBlank(contactVar.HomePhone)) {
            personMap.putAll(new Map<String, Object>{
                    'HomePhone' => new Map<String, Object>{
                            'PhoneNumber' => contactVar.HomePhone,
                            'Type' => new Map<String, Object>{
                                    'Name' => 'Home'
                            },
                            'Extension' => null,
                            'IsPrimary' => false
                    }
            });
        } else {
            personMap.put('HomePhone', null);
        }

        if (String.isNotBlank(contactVar.MobilePhone)) {
            personMap.putAll(new Map<String, Object>{
                    'MobilePhone' => new Map<String, Object>{
                            'PhoneNumber' => contactVar.MobilePhone,
                            'Type' => new Map<String, Object>{
                                    'Name' => 'Mobile'
                            },
                            'Extension' => null,
                            'IsPrimary' => false
                    }
            });
        } else {
            personMap.put('MobilePhone', null);
        }

        if (String.isNotBlank(contactVar.npe01__WorkPhone__c)) {
            personMap.putAll(new Map<String, Object>{
                    'WorkPhone' => new Map<String, Object>{
                            'PhoneNumber' => contactVar.npe01__WorkPhone__c,
                            'Type' => new Map<String, Object>{
                                    'Name' => 'Work'
                            },
                            'Extension' => null,
                            'IsPrimary' => false
                    }
            });
        } else {
            personMap.put('WorkPhone', null);
        }

        if (new Set<String>{
                'Male', 'Female'
        }.contains(contactVar.Gender__c)) {
            personMap.put('Gender', contactVar.Gender__c);
        } else{
            personMap.put('Gender', null);
        }

        if (String.isNotBlank(contactVar.ShelterBuddy_ID_PID__c)) {
            personMap.put('Id', Long.valueOf(contactVar.ShelterBuddy_ID_PID__c));

            if(String.isBlank(contactVar.Last_ShelterBuddy_Sync_String__c)){
                HttpResponse personResp = new ShelterBuddyAPIUtils().commonRequest('getPerson', new List<String>{contactVar.ShelterBuddy_ID_PID__c}, null, false);
                if (personResp.getStatusCode() == 200) {
                    vertic_DTO personDTO = new vertic_DTO(personResp.getBody());
                    personMap.put('LastUpdateDateTimeUtc', personDTO.getString('LastUpdateDateTimeUtc'));
                }
            } else {
                personMap.put('LastUpdateDateTimeUtc', contactVar.Last_ShelterBuddy_Sync_String__c);
            }

        }

        personMap.put('Emails', emails);

//        if (!emails.isEmpty()) {
//
//        }

        personMap.put('DoNotEmail', emails.isEmpty());

        personMap.put(
                'MailingAddress',
                this.setShelterBuddyAddress(contactVar.MailingStreet, contactVar.MailingCity, contactVar.MailingState, contactVar.MailingPostalCode)
        );

        personMap.put(
                'PhysicalAddress',
                this.setShelterBuddyAddress(contactVar.OtherStreet, contactVar.OtherCity, contactVar.OtherState, contactVar.OtherPostalCode)
        );

        return personMap;
    }

    private Map<String, Object> setShelterBuddyAddress(String street, String city, String state, String postcode) {
        Map<String, Object> personAddress = new Map<String, Object>();

        Suburb__c suburbVar;
        if (String.isNotBlank(postcode) || (String.isNotBlank(state) && String.isNotBlank(city))) {
            suburbVar = (Suburb__c) vertic_Utils.arrays.firstOrNull([
                    SELECT Id, StateId__c, SuburbId__c
                    FROM Suburb__c
                    WHERE (Postcode__c = :postcode AND SuburbName__c = :city) OR (StateName__c = :state AND SuburbName__c = :city)
            ]);
        }

        personAddress.put('StateId', vertic_Utils.strings.defaultIfBlank(suburbVar?.StateId__c, '1'));//QLD by default
        personAddress.put('SuburbId', vertic_Utils.strings.defaultIfBlank(suburbVar?.SuburbId__c, '5002'));//UNKNOWN by default
        personAddress.put('Postcode', vertic_Utils.strings.defaultIfBlank(postcode, '0000'));//0000 by default;
        personAddress.put('CountryId', 3);//Australia by default

        if (String.isNotBlank(street)) {
            personAddress.putAll(new Map<String, Object>{
//                    'Line1' => street,
                    'ExtraAddressDetails' => street
            });
        }

        return personAddress;
    }
}