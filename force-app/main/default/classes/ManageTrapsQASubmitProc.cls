public class ManageTrapsQASubmitProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String recordId = this.request.getRequiredString('recordId');
        animalos__Location_Of_Interest__c locationOfInterest = new animalos__Location_Of_Interest__c();
        this.request.getMapper().mapToSObject('locationOfInterest', locationOfInterest);
        List<animalos__Resource__c> resources = this.request.getMapper().mapToListSObjects('resources', animalos__Resource__c.SObjectType);
        List<animalos__Assigned_Resource__c> assignedResources = new List<animalos__Assigned_Resource__c>();

        animalos__Job__c job = (animalos__Job__c) vertic_Utils.arrays.firstOrException([
                SELECT Id
                FROM animalos__Job__c
                WHERE Id = :recordId
        ]);

        animalos__Job_Activity__c jobActivity = new animalos__Job_Activity__c(
                animalos__Job__c = job.Id,
                animalos__Status__c = 'In Progress',
                animalos__Address__CountryCode__s = locationOfInterest.animalos__Address__CountryCode__s,
                animalos__Address__City__s = locationOfInterest.animalos__Address__City__s,
                animalos__Address__Street__s = locationOfInterest.animalos__Address__Street__s,
                animalos__Address__PostalCode__s = locationOfInterest.animalos__Address__PostalCode__s,
                animalos__Address__StateCode__s = locationOfInterest.animalos__Address__StateCode__s,
                animalos__Start_Date_Time__c = Datetime.now(),
                animalos__Type_of_Work__c = 'Trap Deployment',
                RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Job_Activity__c.SObjectType, 'Trap')
        );
        insert jobActivity;

        for (animalos__Resource__c resource : resources) {
            animalos__Assigned_Resource__c assignedResource = new animalos__Assigned_Resource__c(
                    animalos__Job_Activity__c = jobActivity.Id,
                    animalos__Resource__c = resource.Id,
                    Trap_Status__c = resource.Status__c
            );
            assignedResources.add(assignedResource);
        }
        update resources;
        insert assignedResources;

        this.response.put('jobActivityId', jobActivity.Id);
    }

}