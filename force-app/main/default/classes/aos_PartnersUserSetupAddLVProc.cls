public class aos_PartnersUserSetupAddLVProc extends aos_AbstractProcessor implements aos_Structs.IRollbackable {

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String recordId = this.request.getRequiredString('recordId');
        Contact contactVar = (Contact) aos_Utils.arrays.firstOrException([
                SELECT Id, Name
                FROM Contact
                WHERE Id = :recordId
        ]);

        animalos__Location__c location = new animalos__Location__c();
        this.request.getMapper().mapToSObject('location', location);
        location.animalos__Contact__c = recordId;
        location.RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Location__c.SObjectType, 'Foster');
        location.Name = contactVar.Name + ' Foster';

        location.Id = ((animalos__Location__c) aos_Utils.arrays.firstOrNull([
                SELECT Id
                FROM animalos__Location__c
                WHERE animalos__Parent_Block__c = :location.animalos__Parent_Block__c AND animalos__Contact__c = :contactVar.Id
        ]))?.Id;
        upsert location;

        aos_Location_Volunteer__c locationVolunteer = (aos_Location_Volunteer__c) aos_Utils.arrays.firstOrNull([
                SELECT Id
                FROM aos_Location_Volunteer__c
                WHERE aos_Location__c = :location.Id AND aos_Volunteer__c = :contactVar.Id
        ]);

        if (locationVolunteer == null) {
            locationVolunteer = new aos_Location_Volunteer__c(
                    aos_Location__c = location.Id,
                    aos_Volunteer__c = contactVar.Id,
                    aos_Status__c = 'Active'
            );
            insert locationVolunteer;
        }
    }

}