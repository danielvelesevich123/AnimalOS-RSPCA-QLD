public class PartnersUserSetupMetaProc extends vertic_MetadataProcessor {

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

        Contact contactVar = (Contact) vertic_Utils.arrays.firstOrException([
                SELECT Id, FirstName, LastName, Email, Name, animalos__POI_Flag__c
                FROM Contact
                WHERE Id = :recordId
        ]);

        User userVar = (User) vertic_Utils.arrays.firstOrNull([
                SELECT Id, Name, FirstName, LastName, Username, ProfileId, Profile.Name, IsActive
                FROM User
                WHERE ContactId = :contactVar.Id AND ProfileId IN :PartnersPortalReshareRecordsProc.PARTNERS_PORTAL_PROFILE_IDS
        ]);

        String networkId = ((Network) vertic_Utils.arrays.firstOrNull([
                SELECT Id
                FROM Network
                WHERE Name LIKE '%Partners'
        ]))?.Id;

        List<Profile> profiles = [
                SELECT Id, Name
                FROM Profile
                WHERE Id IN (
                        SELECT ParentId
                        FROM NetworkMemberGroup
                        WHERE NetworkId = :networkId
                )
                AND Name != 'System Administrator'
        ];

        List<vertic_Structs.SelectOption> profileOptions = new List<vertic_Structs.SelectOption>();

        for (Profile profile : profiles) {
            profileOptions.add(new vertic_Structs.SelectOption(profile.Id, profile.Name));
        }

        List<Location_Volunteer__c> locationVolunteers = [
                SELECT Id, Location__c, Location__r.Name, Location__r.RecordType.DeveloperName, Location__r.animalos__Full_Location_Name__c,
                        Location__r.animalos__Parent_Block__c, Location__r.animalos__Parent_Block__r.Name, Status__c
                FROM Location_Volunteer__c
                WHERE Volunteer__c = :contactVar.Id
        ];

        this.response.put('doesCommunityExist', String.isNotBlank(networkId));
        this.response.getMapper().mapFromSObject('contact', contactVar);
        this.response.getMapper().mapFromSObject('user', userVar ?? new User(
                FirstName = contactVar.FirstName,
                LastName = contactVar.LastName,
                ContactId = contactVar.Id,
                Email = contactVar.Email,
                Username = (String.isNotBlank(contactVar.Email) ? contactVar.Email + '.partner' : '')
        ));
        this.response.getMapper().mapFromListSObjects('locationVolunteers', locationVolunteers);
        this.response.addSelectOptions('profileOptions', profileOptions);
    }
}