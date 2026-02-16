public without sharing class aos_PartnersPortalReshareRecordsProc extends aos_AbstractProcessor {

    public static Set<String> PARTNERS_PORTAL_PROFILE_NAMES {
        get {
            if (PARTNERS_PORTAL_PROFILE_NAMES == null) {
                String networkId = ((Network) aos_Utils.arrays.firstOrException([
                        SELECT Id
                        FROM Network
                        WHERE Name LIKE '%Partners'
                ])).Id;

                List<Profile> profiles = [
                        SELECT Name
                        FROM Profile
                        WHERE Id IN (
                                SELECT ParentId
                                FROM NetworkMemberGroup
                                WHERE NetworkId = :networkId
                        )
                        AND Name != 'System Administrator'
                ];
                PARTNERS_PORTAL_PROFILE_NAMES = aos_Utils.sObjects.getStringFieldValues(profiles, Profile.Name);
            }
            return PARTNERS_PORTAL_PROFILE_NAMES;
        }
        private set;
    }

    public static Set<Id> PARTNERS_PORTAL_PROFILE_IDS {
        get {
            if (PARTNERS_PORTAL_PROFILE_IDS == null) {
                PARTNERS_PORTAL_PROFILE_IDS = aos_Utils.sObjects.getIdFieldValues([
                        SELECT Id
                        FROM Profile
                        WHERE Name IN :aos_PartnersPortalReshareRecordsProc.PARTNERS_PORTAL_PROFILE_NAMES
                ], Profile.Id);
            }
            return PARTNERS_PORTAL_PROFILE_IDS;
        }
        private set;
    }


    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }


    private void doSubmit() {
        String userId = this.request.getRequiredString('userId');

        Map<String, SObject> existingLocationSharesByParentId = aos_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, ParentId
                FROM animalos__Location__Share
                WHERE UserOrGroupId = :userId
        ], animalos__Location__Share.ParentId);

        Map<String, SObject> existingAnimalSharesByParentId = aos_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, ParentId
                FROM animalos__Animal__Share
                WHERE UserOrGroupId = :userId
        ], animalos__Animal__Share.ParentId);


        List<aos_Location_Volunteer__c> locationVolunteers = [
                SELECT Id, aos_Location__c, aos_Location__r.RecordType.DeveloperName, aos_Location__r.animalos__Parent_Block__c, aos_Location__r.animalos__Parent_Block__r.animalos__Parent_Block__c
                FROM aos_Location_Volunteer__c
                WHERE aos_User__c = :userId
        ];


        List<animalos__Location__Share> locationShares = new List<animalos__Location__Share>();
        List<animalos__Animal__Share> animalShares = new List<animalos__Animal__Share>();

        List<animalos__Animal__Share> animalSharesToDelete = new List<animalos__Animal__Share>();
        List<animalos__Location__Share> locationSharesToDelete = new List<animalos__Location__Share>();

        Set<Id> locationIdsToShare = new Set<Id>();
        Set<Id> animalIdsToShare = new Set<Id>();
        List<animalos__Location__c> sites = new List<animalos__Location__c>();
        List<animalos__Location__c> blocks = new List<animalos__Location__c>();
        List<animalos__Location__c> units = new List<animalos__Location__c>();
        List<animalos__Location__c> fosters = new List<animalos__Location__c>();
        List<animalos__Location__c> offsites = new List<animalos__Location__c>();

        for (aos_Location_Volunteer__c locationVolunteer : locationVolunteers) {
            if (locationVolunteer.aos_Location__r.RecordType.DeveloperName == 'Site') {
                sites.add(locationVolunteer.aos_Location__r);
            } else if (locationVolunteer.aos_Location__r.RecordType.DeveloperName == 'Block') {
                blocks.add(locationVolunteer.aos_Location__r);
            } else if (locationVolunteer.aos_Location__r.RecordType.DeveloperName == 'Unit') {
                units.add(locationVolunteer.aos_Location__r);
            } else if (locationVolunteer.aos_Location__r.RecordType.DeveloperName == 'Foster') {
                fosters.add(locationVolunteer.aos_Location__r);
            } else if (locationVolunteer.aos_Location__r.RecordType.DeveloperName == 'Offsite') {
                offsites.add(locationVolunteer.aos_Location__r);
            }
        }

        if (!units.isEmpty()) {
            for (animalos__Location__c unit : units) {
                //share unit
                locationIdsToShare.add(unit.Id);
                //share block
                if (String.isNotBlank(unit.animalos__Parent_Block__c)) {
                    locationIdsToShare.add(unit.animalos__Parent_Block__c);
                }
                //share site
                if (String.isNotBlank(unit.animalos__Parent_Block__r?.animalos__Parent_Block__c)) {
                    locationIdsToShare.add(unit.animalos__Parent_Block__r.animalos__Parent_Block__c);
                }
            }
            //share animals
            List<animalos__Animal__c> animals = [
                    SELECT Id
                    FROM animalos__Animal__c
                    WHERE animalos__Current_Unit__c = :units
                    AND animalos__Stage__c != 'Out'
            ];

            if (!animals.isEmpty()) {
                for (animalos__Animal__c animal : animals) {
                    animalIdsToShare.add(animal.Id);
                }
            }
        }

        if (!blocks.isEmpty()) {
            for (animalos__Location__c block : blocks) {
                //share block
                locationIdsToShare.add(block.Id);
                //share site
                if (String.isNotBlank(block.animalos__Parent_Block__c)) {
                    locationIdsToShare.add(block.animalos__Parent_Block__c);
                }
            }
            //share all units
            List<animalos__Location__c> childUnits = [
                    SELECT Id
                    FROM animalos__Location__c
                    WHERE animalos__Parent_Block__c IN :blocks
                    AND RecordType.DeveloperName = 'Unit'
            ];

            if (!childUnits.isEmpty()) {
                for (animalos__Location__c childUnit : childUnits) {
                    locationIdsToShare.add(childUnit.Id);
                }
            }
            //share animals
            List<animalos__Animal__c> animals = [
                    SELECT Id
                    FROM animalos__Animal__c
                    WHERE animalos__Current_Block__c = :blocks
                    AND animalos__Stage__c != 'Out'
            ];

            if (!animals.isEmpty()) {
                for (animalos__Animal__c animal : animals) {
                    animalIdsToShare.add(animal.Id);
                }
            }
        }

        if (!sites.isEmpty()) {
            for (animalos__Location__c site : sites) {
                //share site
                locationIdsToShare.add(site.Id);
            }
            //share all blocks and fosters
            List<animalos__Location__c> childBlocks = [
                    SELECT Id
                    FROM animalos__Location__c
                    WHERE animalos__Parent_Block__c IN :sites
                    AND (RecordType.DeveloperName = 'Block'
                    OR RecordType.DeveloperName = 'Foster')
            ];

            if (!childBlocks.isEmpty()) {
                for (animalos__Location__c childBlock : childBlocks) {
                    locationIdsToShare.add(childBlock.Id);
                }
            }
            //share all units
            List<animalos__Location__c> childUnits = [
                    SELECT Id
                    FROM animalos__Location__c
                    WHERE animalos__Parent_Block__c IN :childBlocks
                    AND RecordType.DeveloperName = 'Unit'
            ];

            if (!childUnits.isEmpty()) {
                for (animalos__Location__c childUnit : childUnits) {
                    locationIdsToShare.add(childUnit.Id);
                }
            }
            //share animals
            List<animalos__Animal__c> animals = [
                    SELECT Id
                    FROM animalos__Animal__c
                    WHERE animalos__Current_Site__c = :sites
                    AND animalos__Stage__c != 'Out'
            ];

            if (!animals.isEmpty()) {
                for (animalos__Animal__c animal : animals) {
                    animalIdsToShare.add(animal.Id);
                }
            }
        }

        if (!fosters.isEmpty()) {
            for (animalos__Location__c foster : fosters) {
                //share foster
                locationIdsToShare.add(foster.Id);
                //share parent site
                if (String.isNotBlank(foster.animalos__Parent_Block__c)) {
                    locationIdsToShare.add(foster.animalos__Parent_Block__c);
                }
            }
            //share animals
            List<animalos__Animal__c> animals = [
                    SELECT Id
                    FROM animalos__Animal__c
                    WHERE animalos__Current_Unit__c = :fosters
                    AND animalos__Stage__c != 'Out'
            ];

            if (!animals.isEmpty()) {
                for (animalos__Animal__c animal : animals) {
                    animalIdsToShare.add(animal.Id);
                }
            }
        }

        if (!offsites.isEmpty()) {
            for (animalos__Location__c offsite : offsites) {
                //share offsite
                locationIdsToShare.add(offsite.Id);
            }
            //share animals
            List<animalos__Animal__c> animals = [
                    SELECT Id
                    FROM animalos__Animal__c
                    WHERE animalos__Current_Site__c = :offsites
                    AND animalos__Stage__c != 'Out'
            ];

            if (!animals.isEmpty()) {
                for (animalos__Animal__c animal : animals) {
                    animalIdsToShare.add(animal.Id);
                }
            }
        }

        //create list for new Location Shares
        if (!locationIdsToShare.isEmpty()) {
            for (Id locationIdToShare : locationIdsToShare) {
                if (!existingLocationSharesByParentId.keySet().contains(locationIdToShare)) {
                    locationShares.add(new animalos__Location__Share(
                            UserOrGroupId = userId,
                            ParentId = locationIdToShare,
                            RowCause = 'Manual',
                            AccessLevel = 'Edit'
                    ));
                }
            }
        }

        //create list for deletion of existing Location Shares
        if (!existingLocationSharesByParentId.keySet().isEmpty()) {
            for (Id locationIdToShare : existingLocationSharesByParentId.keySet()) {
                if (!locationIdsToShare.contains(locationIdToShare)) {
                    locationSharesToDelete.add(new animalos__Location__Share(
                            Id = existingLocationSharesByParentId.get(locationIdToShare).Id
                    ));
                }
            }
        }

        //create list for new Animal Shares
        if (!animalIdsToShare.isEmpty()) {
            for (Id animalIdToShare : animalIdsToShare) {
                if (!existingAnimalSharesByParentId.keySet().contains(animalIdToShare)) {
                    animalShares.add(new animalos__Animal__Share(
                            UserOrGroupId = userId,
                            ParentId = animalIdToShare,
                            RowCause = 'Manual',
                            AccessLevel = 'Edit'
                    ));
                }
            }
        }

        //create list for deletion of existing Animal Shares
        if (!existingAnimalSharesByParentId.keySet().isEmpty()) {
            for (Id animalIdToShare : existingAnimalSharesByParentId.keySet()) {
                if (!animalIdsToShare.contains(animalIdToShare)) {
                    animalSharesToDelete.add(new animalos__Animal__Share(
                            Id = existingAnimalSharesByParentId.get(animalIdToShare).Id
                    ));
                }
            }
        }

        if (!locationShares.isEmpty()) {
            insert locationShares;
        }

        if (!animalShares.isEmpty()) {
            insert animalShares;
        }

        if (!locationSharesToDelete.isEmpty()) {
            delete locationSharesToDelete;
        }

        if (!animalSharesToDelete.isEmpty()) {
            delete animalSharesToDelete;
        }

    }

    public static void submitVAPsByUserIds(Set<Id> userIds) {
        if (userIds != null && !userIds.isEmpty()) {
            List<aos_Async_Process__c> vaps = new List<aos_Async_Process__c>();
            Map<String, SObject> existingVapsByGroupKey = aos_Utils.sObjects.getSObjectsByAnyFieldMap([
                    SELECT Id, aos_Group_Key__c
                    FROM aos_Async_Process__c
                    WHERE aos_Processor__c = :'' + aos_PartnersPortalReshareRecordsProc.class
                    AND aos_Group_Key__c IN :userIds
                    AND aos_Status__c = 'Pending'
            ], aos_Async_Process__c.aos_Group_Key__c);

            for (Id userId : userIds) {
                if (userId != null && !existingVapsByGroupKey.containsKey(userId)) {
                    vaps.add(new aos_Async_Process__c(
                            aos_Processor__c = '' + aos_PartnersPortalReshareRecordsProc.class,
                            aos_Payload__c = JSON.serialize(new Map<String, Object>{
                                    'userId' => userId
                            }),
                            aos_Description__c = 'Recreate Partner Portal Share Records',
                            aos_Group_Key__c = userId,
                            aos_Autorun__c = true,
                            aos_Status__c = 'Pending'
                    ));
                }
            }

            if (!vaps.isEmpty()) {
                upsert vaps;
            }
        }
    }
}