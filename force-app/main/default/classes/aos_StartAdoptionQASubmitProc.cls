public without sharing class aos_StartAdoptionQASubmitProc extends aos_AbstractProcessor implements aos_Structs.IRollbackable {

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String animalId = this.request.getRequiredString('recordId');
        Contact contactVar = new Contact();
        Contact alternateContactVar = new Contact();
        this.request.getMapper().mapToSObject('contact', contactVar);
        this.request.getMapper().mapToSObject('alternateContact', alternateContactVar);

        Boolean isAlternateContactFilled = String.isNotBlank(alternateContactVar.FirstName) && String.isNotBlank(alternateContactVar.LastName);

        aos_Utils.sObjects.deduplicate(contactVar);

        if (isAlternateContactFilled == true) {
            aos_Utils.sObjects.deduplicate(alternateContactVar);
        }

        if (contactVar.Id != null) {
            Boolean isPersonOfInterest = ((Contact) aos_Utils.arrays.firstOrException([SELECT animalos__POI_Flag__c FROM Contact WHERE Id = :contactVar.Id])).animalos__POI_Flag__c;
            Boolean doNotAllowAdoptions = ((Contact) aos_Utils.arrays.firstOrException([SELECT aos_Do_Not_Allow_Adoptions__c FROM Contact WHERE Id = :contactVar.Id])).aos_Do_Not_Allow_Adoptions__c;
            if (isPersonOfInterest) {
                throw new aos_Structs.InvalidDataException('Contact is a Person Of Interest, we cannot process the Adoption. Please contact RSPCA for more information.');
            }

            if (doNotAllowAdoptions) {
                throw new aos_Structs.InvalidDataException('We are unable to process an adoption for this specific individual. Please contact your coordinator for more details.');
            }
        }

        if (alternateContactVar.Id != null && isAlternateContactFilled == true) {
            Boolean isPersonOfInterest = ((Contact) aos_Utils.arrays.firstOrException([SELECT animalos__POI_Flag__c FROM Contact WHERE Id = :alternateContactVar.Id])).animalos__POI_Flag__c;
            Boolean doNotAllowAdoptions = ((Contact) aos_Utils.arrays.firstOrException([SELECT aos_Do_Not_Allow_Adoptions__c FROM Contact WHERE Id = :alternateContactVar.Id])).aos_Do_Not_Allow_Adoptions__c;
            if (isPersonOfInterest) {
                throw new aos_Structs.InvalidDataException('Alternate Contact is a Person Of Interest, we cannot process the Adoption. Please contact RSPCA for more information.');
            }

            if (doNotAllowAdoptions) {
                throw new aos_Structs.InvalidDataException('We are unable to process an adoption for this specific individual. Please contact your coordinator for more details.');
            }
        }

        if (contactVar.Id == null) {
            insert contactVar;
        } else {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.duplicateRuleHeader.allowSave = true;
            Database.update(contactVar, dml);
        }

        if (isAlternateContactFilled == true) {
            if (alternateContactVar.Id == null) {
                insert alternateContactVar;
            } else {
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.duplicateRuleHeader.allowSave = true;
                Database.update(alternateContactVar, dml);
            }
        }

        animalos__Animal__c animalVar = (animalos__Animal__c) aos_Utils.arrays.firstOrException([
                SELECT Id, animalos__Current_Block__c, animalos__Current_Site__c, animalos__Current_Unit__c
                FROM animalos__Animal__c
                WHERE Id = :animalId
        ]);

        animalos__Referral__c referralVar = new animalos__Referral__c(
                RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Referral__c.SObjectType, 'Adoption'),
                animalos__Scheduled_Date_Time__c = Datetime.now(),
                animalos__Date_Collected__c = Date.today(),
                animalos__Stage__c = 'New',
                animalos__Contact__c = contactVar.Id,
                Name = String.format(
                        '{0} {1} Adoption',
                        new List<String>{
                                contactVar.FirstName,
                                contactVar.LastName
                        }
                ));

        if (isAlternateContactFilled == true) {
            referralVar.aos_Alternate_Contact__c = alternateContactVar.Id;
        }

        insert referralVar;

        animalos__Animal_Referral__c animalReferralVar = new animalos__Animal_Referral__c(
                animalos__Animal__c = animalVar.Id,
                animalos__Referral__c = referralVar.Id,
                animalos__Block__c = animalVar.animalos__Current_Block__c,
                animalos__Unit__c = animalVar.animalos__Current_Unit__c,
                animalos__Site__c = animalVar.animalos__Current_Site__c
        );

        insert animalReferralVar;

        this.response.put('referralId', referralVar.Id);
    }
}