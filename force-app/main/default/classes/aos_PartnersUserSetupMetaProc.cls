public class aos_PartnersUserSetupMetaProc extends aos_MetadataProcessor {

    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                // SObject Fields, e.g. Contact.Salutation
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        String recordId = this.request.getRequiredString('recordId');

        Contact contactVar = (Contact) aos_Utils.arrays.firstOrException([
                SELECT Id, FirstName, LastName, Email, Name, animalos__POI_Flag__c
                FROM Contact
                WHERE Id = :recordId
        ]);

        User userVar = (User) aos_Utils.arrays.firstOrNull([
                SELECT Id, Name, FirstName, LastName, Username, ProfileId, Profile.Name, IsActive
                FROM User
                WHERE ContactId = :contactVar.Id AND ProfileId IN :aos_PartnersPortalReshareRecordsProc.PARTNERS_PORTAL_PROFILE_IDS
        ]);

        String networkId = ((Network) aos_Utils.arrays.firstOrNull([
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

        List<aos_Structs.SelectOption> profileOptions = new List<aos_Structs.SelectOption>();

        for (Profile profile : profiles) {
            profileOptions.add(new aos_Structs.SelectOption(profile.Id, profile.Name));
        }

        List<aos_Location_Volunteer__c> locationVolunteers = [
                SELECT Id, aos_Location__c, aos_Location__r.Name, aos_Location__r.RecordType.DeveloperName, aos_Location__r.animalos__Full_Location_Name__c,
                        aos_Location__r.animalos__Parent_Block__c, aos_Location__r.animalos__Parent_Block__r.Name, aos_Status__c
                FROM aos_Location_Volunteer__c
                WHERE aos_Volunteer__c = :contactVar.Id
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