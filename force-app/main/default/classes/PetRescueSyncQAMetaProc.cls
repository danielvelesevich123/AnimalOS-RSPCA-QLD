public class PetRescueSyncQAMetaProc extends vertic_MetadataProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                // SObject Fields, e.g. Contact.Salutation
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        String recordId = this.request.getRequiredString('recordId');

        animalos__Animal__c animal = (animalos__Animal__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, animalos__Status__c, aos_PetRescue_Id__c, aos_PetRescue_Location__c, animalos__Current_Site__c
                FROM animalos__Animal__c
                WHERE Id = :recordId
        ]);

        String status;

        vertic_Utils.objects.throwIfBlank(animal.animalos__Status__c, 'Status is required');

        if (animal.animalos__Status__c.containsIgnoreCase('Available for Adoption')) {
            status = 'active';
        }

        if (animal.animalos__Status__c.containsIgnoreCase('No Web Presence') || (!animal.animalos__Status__c.containsIgnoreCase('Available for Adoption') && !animal.animalos__Status__c.containsIgnoreCase('Adopted'))) {
            status = 'removed';
        }

        if (animal.animalos__Status__c.containsIgnoreCase('Adopted')) {
            status = 'rehomed';
        }

        Map<String, aos_PetRescue_Setting__mdt> petRescueSettings = aos_PetRescue_Setting__mdt.getAll();
        Set<String> locationIds = new Set<String>();
        for (String key : petRescueSettings.keySet()) {
            aos_PetRescue_Setting__mdt setting = petRescueSettings.get(key);
            locationIds.add('\'' + setting.aos_Location_Id__c + '\'');
        }

        this.response.put('locationIds', String.join(new List<String>(locationIds), ', '));
        this.response.addSelectOptions('statusOptions', new List<vertic_Structs.SelectOption>{
                new vertic_Structs.SelectOption('active', 'active'),
                new vertic_Structs.SelectOption('removed', 'removed'),
                new vertic_Structs.SelectOption('rehomed', 'rehomed'),
                new vertic_Structs.SelectOption('draft', 'draft')
        });
        this.response.put('status', status);
        this.response.put('locationId', animal.aos_PetRescue_Location__c ?? animal.animalos__Current_Site__c);
        this.response.getMapper().mapFromSObject('animal', animal);
    }
}