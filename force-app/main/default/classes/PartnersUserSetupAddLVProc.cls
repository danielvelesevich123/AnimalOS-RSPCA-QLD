public class PartnersUserSetupAddLVProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String recordId = this.request.getRequiredString('recordId');
        Contact contactVar = (Contact) vertic_Utils.arrays.firstOrException([
                SELECT Id, Name
                FROM Contact
                WHERE Id = :recordId
        ]);

        animalos__Location__c location = new animalos__Location__c();
        this.request.getMapper().mapToSObject('location', location);
        location.animalos__Contact__c = recordId;
        location.RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Location__c.SObjectType, 'Foster');
        location.Name = contactVar.Name + ' Foster';

        location.Id = ((animalos__Location__c) vertic_Utils.arrays.firstOrNull([
                SELECT Id
                FROM animalos__Location__c
                WHERE animalos__Parent_Block__c = :location.animalos__Parent_Block__c AND animalos__Contact__c = :contactVar.Id
        ]))?.Id;
        upsert location;

        Location_Volunteer__c locationVolunteer = (Location_Volunteer__c) vertic_Utils.arrays.firstOrNull([
                SELECT Id
                FROM Location_Volunteer__c
                WHERE Location__c = :location.Id AND Volunteer__c = :contactVar.Id
        ]);

        if (locationVolunteer == null) {
            locationVolunteer = new Location_Volunteer__c(
                    Location__c = location.Id,
                    Volunteer__c = contactVar.Id,
                    Status__c = 'Active'
            );
            insert locationVolunteer;
        }
    }

}