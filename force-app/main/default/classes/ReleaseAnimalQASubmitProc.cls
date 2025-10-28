public without sharing class ReleaseAnimalQASubmitProc extends vertic_AbstractProcessor{
    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit(){
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

        animalos__Animal__c animalVar = (animalos__Animal__c)vertic_Utils.arrays.firstOrNull(
                [
                        SELECT
                                Id,
                                Name
                        FROM animalos__Animal__c
                        WHERE Id = : animalId
                ]
        );

        User userVar = (User)vertic_Utils.arrays.firstOrNull(
        [
                SELECT
                        Id,
                        FirstName,
                        LastName
                FROM User
                WHERE Id = : userId
        ]
        );

        animalos__Referral__c referralVar = new animalos__Referral__c();

        referralVar.RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Referral__c.SObjectType, 'Wildlife_Release');
        referralVar.animalos__Referral_Description__c = description;
        referralVar.animalos__Stage__c = 'New';
        referralVar.animalos__Scheduled_Date_Time__c = Datetime.now();

        referralVar.animalos__Job__c = jobId;
        referralVar.Animal__c = animalId;

        referralVar.Name = String.format(
                '{0} {1} Wildlife Release',
                new List<String>{
                        userVar.FirstName,
                        userVar.LastName
                }
        );

        referralVar.Referral_Address__CountryCode__s = 'AU';
        referralVar.Referral_Address__City__s = city;
        referralVar.Referral_Address__Street__s = street;
        referralVar.Referral_Address__PostalCode__s = postalCode;
        referralVar.Referral_Address__Latitude__s = latitude;
        referralVar.Referral_Address__Longitude__s = longitude;

        switch on state {
            when 'Queensland'{
                referralVar.Referral_Address__StateCode__s = 'QLD';
            }
            when 'New South Wales'{
                referralVar.Referral_Address__StateCode__s = 'NSW';
            }
            when 'Victoria'{
                referralVar.Referral_Address__StateCode__s = 'VIC';
            }
            when 'South Australia'{
                referralVar.Referral_Address__StateCode__s = 'SA';
            }
            when 'Western Australia'{
                referralVar.Referral_Address__StateCode__s = 'WA';
            }
        }

        animalVar.Animal_Released_By__c = userId;
        animalVar.animalos__Stage__c = 'Out';
        animalVar.animalos__Status__c = 'Returned to Habitat';

        insert referralVar;

        update animalVar;
    }
}