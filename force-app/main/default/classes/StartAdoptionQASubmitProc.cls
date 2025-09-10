public without sharing class StartAdoptionQASubmitProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String animalId = this.request.getRequiredString('recordId');
        Contact contactVar = new Contact();
        this.request.getMapper().mapToSObject('contact', contactVar);

        vertic_Utils.sObjects.deduplicate(contactVar);

        if (contactVar.Id != null) {
            Boolean isPersonOfInterest = ((Contact) vertic_Utils.arrays.firstOrException([SELECT POI_Flag__c FROM Contact WHERE Id = :contactVar.Id])).POI_Flag__c;
            Boolean doNotAllowAdoptions = ((Contact) vertic_Utils.arrays.firstOrException([SELECT Do_Not_Allow_Adoptions__c FROM Contact WHERE Id = :contactVar.Id])).Do_Not_Allow_Adoptions__c;
            if (isPersonOfInterest) {
                throw new vertic_Structs.InvalidDataException('Contact is a Person Of Interest, we cannot process the Adoption. Please contact RSPCA for more information.');
            }

            if (doNotAllowAdoptions) {
                throw new vertic_Structs.InvalidDataException('We are unable to process an adoption for this specific individual. Please contact your coordinator for more details.');
            }
        }

        if (contactVar.Id == null) {
            insert contactVar;
        } else {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.duplicateRuleHeader.allowSave = true;
            Database.update(contactVar, dml);
        }

        animalos__Animal__c animalVar = (animalos__Animal__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, animalos__Current_Block__c, animalos__Current_Site__c, animalos__Current_Unit__c
                FROM animalos__Animal__c
                WHERE Id = :animalId
        ]);

        animalos__Referral__c referralVar = new animalos__Referral__c(
                RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Referral__c.SObjectType, 'Adoption'),
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