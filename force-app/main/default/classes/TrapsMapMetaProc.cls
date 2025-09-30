public class TrapsMapMetaProc extends vertic_MetadataProcessor implements Database.AllowsCallouts {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        super.process(this.request);

        this.doInit();

        return this.response;
    }

    private void doInit() {
        List<animalos__Job_Activity__c> traps = [
                SELECT Id, Name, animalos__Job__r.Name, Days_in_Field__c, animalos__Address__Street__s, animalos__Address__City__s,
                        animalos__Address__StateCode__s, animalos__Address__PostalCode__s, animalos__Address__CountryCode__s
                FROM animalos__Job_Activity__c
                WHERE Id IN (SELECT animalos__Job_Activity__c FROM animalos__Assigned_Resource__c WHERE animalos__Resource__r.animalos__Type__c = 'Trap' AND Trap_Status__c = 'Set')
        ];

        this.response.getMapper().mapFromListSObjects('jobActivities', traps);
    }
}