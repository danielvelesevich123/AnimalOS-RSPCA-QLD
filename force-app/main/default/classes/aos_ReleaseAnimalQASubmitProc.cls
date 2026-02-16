public without sharing class aos_ReleaseAnimalQASubmitProc extends vertic_AbstractProcessor {
    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String animalId = this.request.getString('recordId');
        Decimal latitude = this.request.getDecimal('address.latitude');
        Decimal longitude = this.request.getDecimal('address.longitude');
        String city = this.request.getString('address.city');
        String state = this.request.getString('address.state');
        String postalCode = this.request.getString('address.postalCode');
        String street = this.request.getString('address.street');
        String userId = this.request.getString('userId');
        String jobId = this.request.getString('jobId');
        String description = this.request.getString('description');

        animalos__Animal__c animalVar = (animalos__Animal__c) vertic_Utils.arrays.firstOrNull(
        [
                SELECT
                        Id,
                        Name,
                        animalos__Current_Site__c,
                        animalos__Current_Block__c,
                        animalos__Current_Unit__c
                FROM animalos__Animal__c
                WHERE Id = :animalId
        ]
        );

        User userVar = (User) vertic_Utils.arrays.firstOrNull(
        [
                SELECT
                        Id,
                        FirstName,
                        LastName
                FROM User
                WHERE Id = :userId
        ]
        );

        animalos__Referral__c referralVar = new animalos__Referral__c();

        referralVar.RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Referral__c.SObjectType, 'Wildlife_Release');
        referralVar.animalos__Referral_Description__c = description;
        referralVar.animalos__Stage__c = 'New';
        referralVar.animalos__Scheduled_Date_Time__c = Datetime.now();

        if (String.isNotBlank(jobId)) {
            referralVar.animalos__Job__c = jobId;
        }
        referralVar.aos_Animal__c = animalId;

        referralVar.Name = String.format(
                '{0} {1} Wildlife Release',
                new List<String>{
                        userVar.FirstName,
                        userVar.LastName
                }
        );

        referralVar.aos_Referral_Address__CountryCode__s = 'AU';
        referralVar.aos_Referral_Address__City__s = city;
        referralVar.aos_Referral_Address__Street__s = street;
        referralVar.aos_Referral_Address__PostalCode__s = postalCode;
        referralVar.aos_Referral_Address__Latitude__s = latitude;
        referralVar.aos_Referral_Address__Longitude__s = longitude;

        switch on state {
            when 'Queensland' {
                referralVar.aos_Referral_Address__StateCode__s = 'QLD';
            }
            when 'New South Wales' {
                referralVar.aos_Referral_Address__StateCode__s = 'NSW';
            }
            when 'Victoria' {
                referralVar.aos_Referral_Address__StateCode__s = 'VIC';
            }
            when 'South Australia' {
                referralVar.aos_Referral_Address__StateCode__s = 'SA';
            }
            when 'Western Australia' {
                referralVar.aos_Referral_Address__StateCode__s = 'WA';
            }
        }

        animalVar.aos_Animal_Released_By__c = userId;
        animalVar.animalos__Stage__c = 'Out';
        animalVar.animalos__Status__c = 'Returned to Habitat';

        insert referralVar;

        animalos__Animal_Referral__c animalReferral = new animalos__Animal_Referral__c(
                animalos__Animal__c = animalVar.Id,
                animalos__Referral__c = referralVar.Id,
                animalos__Unit__c = animalVar.animalos__Current_Unit__c,
                animalos__Block__c = animalVar.animalos__Current_Block__c,
                animalos__Site__c = animalVar.animalos__Current_Site__c
        );
        insert animalReferral;

        update animalVar;
    }
}