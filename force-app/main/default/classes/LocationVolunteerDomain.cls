public without sharing class LocationVolunteerDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {

    public LocationVolunteerDomain(List<aos_Location_Volunteer__c> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new LocationVolunteerDomain(sObjectList);
        }
    }

    public override void onAfterInsert() {
        this.shareRecords(this.Records, new Map<Id, aos_Location_Volunteer__c>());
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        this.shareRecords(this.Records, (Map<Id, aos_Location_Volunteer__c>) existingRecords);
        this.deleteShareRecords(this.Records, (Map<Id, aos_Location_Volunteer__c>) existingRecords);
    }

    public override void onBeforeDelete() {
        this.deleteShareRecords(this.Records, new Map<Id, aos_Location_Volunteer__c>());
    }

    private void shareRecords(List<aos_Location_Volunteer__c> locationVolunteers, Map<Id, aos_Location_Volunteer__c> existingLocationVolunteersByIds) {
        List<animalos__Animal__Share> animalShareRecords = new List<animalos__Animal__Share>();
        List<animalos__Location__Share> locationShareRecords = new List<animalos__Location__Share>();
        List<animalos__Alert__Share> alertShareRecords = new List<animalos__Alert__Share>();
        Set<Id> locationIds = vertic_Utils.sObjects.getIdFieldValues(locationVolunteers,aos_Location_Volunteer__c.aos_Location__c);
        Set<Id> contactIds = vertic_Utils.sObjects.getIdFieldValues(locationVolunteers, aos_Location_Volunteer__c.aos_Volunteer__c);

        Map<String, SObject> usersByContactIds = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, ContactId
                FROM User
                WHERE ContactId IN :contactIds
                AND Profile.Name IN ('Partners Portal Volunteer User Plus', 'Foster Carer Portal User Plus', 'Volunteer Portal User Plus')
        ], Schema.User.ContactId);

        List<animalos__Animal__c> animals = [
                SELECT Id, animalos__Current_Unit__c, animalos__Current_Block__c, animalos__Current_Site__c
                FROM animalos__Animal__c
                WHERE animalos__Current_Unit__c IN :locationIds OR animalos__Current_Block__c IN :locationIds
                OR animalos__Current_Site__c IN :locationIds
        ];

        Set<Id> animalIds = vertic_Utils.sObjects.getIdFieldValues(animals, animalos__Animal__c.Id);
        Map<String, List<SObject>> alertsByAnimalIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id,animalos__Target_Record_Id__c
                FROM animalos__Alert__c
                WHERE animalos__Target_Record_Id__c IN :animalIds
        ], animalos__Alert__c.animalos__Target_Record_Id__c);

        Map<String, List<animalos__Animal__c>> animalsByBlockLocationIds = new Map<String, List<animalos__Animal__c>>();
        Map<String, List<animalos__Animal__c>> animalsByUnitLocationIds = new Map<String, List<animalos__Animal__c>>();
        Map<String, List<animalos__Animal__c>> animalsBySiteLocationIds = new Map<String, List<animalos__Animal__c>>();

        for (animalos__Animal__c animal : animals) {
            if (animal.animalos__Current_Unit__c != null) {
                if (animalsByUnitLocationIds.containsKey(animal.animalos__Current_Unit__c)) {
                    animalsByUnitLocationIds.get(animal.animalos__Current_Unit__c).add(animal);
                } else {
                    animalsByUnitLocationIds.put(animal.animalos__Current_Unit__c, new List<animalos__Animal__c>{
                            animal
                    });
                }
            }

            if (animal.animalos__Current_Block__c != null) {
                if (animalsByBlockLocationIds.containsKey(animal.animalos__Current_Block__c)) {
                    animalsByBlockLocationIds.get(animal.animalos__Current_Block__c).add(animal);
                } else {
                    animalsByBlockLocationIds.put(animal.animalos__Current_Block__c, new List<animalos__Animal__c>{
                            animal
                    });
                }
            }

            if (animal.animalos__Current_Site__c != null) {
                if (animalsBySiteLocationIds.containsKey(animal.animalos__Current_Site__c)) {
                    animalsBySiteLocationIds.get(animal.animalos__Current_Site__c).add(animal);
                } else {
                    animalsBySiteLocationIds.put(animal.animalos__Current_Site__c, new List<animalos__Animal__c>{
                            animal
                    });
                }
            }
        }

        for (aos_Location_Volunteer__c locationVolunteerVar : locationVolunteers) {
            Boolean isUpdate = Trigger.isUpdate && existingLocationVolunteersByIds != null && existingLocationVolunteersByIds.get(locationVolunteerVar.Id) != null
                    && locationVolunteerVar.aos_Location__c != null && vertic_Utils.sObjects.isSomeFieldChanged(locationVolunteerVar, existingLocationVolunteersByIds.get(locationVolunteerVar.Id),
                    new List<SObjectField>{
                            aos_Location_Volunteer__c.aos_Location__c
                    });

            Boolean isInsert = Trigger.isInsert && locationVolunteerVar.aos_Location__c != null;

            if (isUpdate || isInsert) {
                List<animalos__Animal__c> relatedAnimalsBlock = (List<animalos__Animal__c>) animalsByBlockLocationIds.get(locationVolunteerVar.aos_Location__c);
                List<animalos__Animal__c> relatedAnimalsUnit = (List<animalos__Animal__c>) animalsByUnitLocationIds.get(locationVolunteerVar.aos_Location__c);
                List<animalos__Animal__c> relatedAnimalsSite = (List<animalos__Animal__c>) animalsBySiteLocationIds.get(locationVolunteerVar.aos_Location__c);
                User volunteerVar = (User) usersByContactIds.get(locationVolunteerVar.aos_Volunteer__c);

                if (volunteerVar != null) {
                    locationShareRecords.add(new animalos__Location__Share(
                            ParentId = locationVolunteerVar.aos_Location__c,
                            UserOrGroupId = volunteerVar.Id,
                            RowCause = 'Manual',
                            AccessLevel = 'Edit'
                    ));
                }

                if (relatedAnimalsBlock != null && !relatedAnimalsBlock.isEmpty() && volunteerVar != null) {
                    for (animalos__Animal__c animalVar : relatedAnimalsBlock) {
                        animalShareRecords.add(new animalos__Animal__Share(
                                ParentId = animalVar.Id,
                                UserOrGroupId = volunteerVar.Id,
                                RowCause = 'Manual',
                                AccessLevel = 'Edit'
                        ));

                        List<animalos__Alert__c> relatedAlerts = (List<animalos__Alert__c>) alertsByAnimalIds.get(animalVar.Id);
                        if (relatedAlerts != null && !relatedAlerts.isEmpty()) {
                            for (animalos__Alert__c alertVar : relatedAlerts) {
                                alertShareRecords.add(new animalos__Alert__Share(
                                        ParentId = alertVar.Id,
                                        UserOrGroupId = volunteerVar.Id,
                                        RowCause = 'Manual',
                                        AccessLevel = 'Edit'
                                ));
                            }
                        }
                    }
                }

                if (relatedAnimalsUnit != null && !relatedAnimalsUnit.isEmpty() && volunteerVar != null) {
                    for (animalos__Animal__c animalVar : relatedAnimalsUnit) {
                        animalShareRecords.add(new animalos__Animal__Share(
                                ParentId = animalVar.Id,
                                UserOrGroupId = volunteerVar.Id,
                                RowCause = 'Manual',
                                AccessLevel = 'Edit'
                        ));

                        List<animalos__Alert__c> relatedAlerts = (List<animalos__Alert__c>) alertsByAnimalIds.get(animalVar.Id);
                        if (relatedAlerts != null && !relatedAlerts.isEmpty()) {
                            for (animalos__Alert__c alertVar : relatedAlerts) {
                                alertShareRecords.add(new animalos__Alert__Share(
                                        ParentId = alertVar.Id,
                                        UserOrGroupId = volunteerVar.Id,
                                        RowCause = 'Manual',
                                        AccessLevel = 'Edit'
                                ));
                            }
                        }
                    }
                }

                if (relatedAnimalsSite != null && !relatedAnimalsSite.isEmpty() && volunteerVar != null) {
                    for (animalos__Animal__c animalVar : relatedAnimalsSite) {
                        animalShareRecords.add(new animalos__Animal__Share(
                                ParentId = animalVar.Id,
                                UserOrGroupId = volunteerVar.Id,
                                RowCause = 'Manual',
                                AccessLevel = 'Edit'
                        ));

                        List<animalos__Alert__c> relatedAlerts = (List<animalos__Alert__c>) alertsByAnimalIds.get(animalVar.Id);
                        if (relatedAlerts != null && !relatedAlerts.isEmpty()) {
                            for (animalos__Alert__c alertVar : relatedAlerts) {
                                alertShareRecords.add(new animalos__Alert__Share(
                                        ParentId = alertVar.Id,
                                        UserOrGroupId = volunteerVar.Id,
                                        RowCause = 'Manual',
                                        AccessLevel = 'Edit'
                                ));
                            }
                        }
                    }
                }
            }
        }

        System.debug(animalShareRecords);
        if (!animalShareRecords.isEmpty()) {
            upsert animalShareRecords;
        }

        System.debug(locationShareRecords);
        if (!locationShareRecords.isEmpty()) {
            upsert locationShareRecords;
        }

        System.debug(alertShareRecords);
        if (!alertShareRecords.isEmpty()) {
            upsert alertShareRecords;
        }
    }

    private void deleteShareRecords(List<aos_Location_Volunteer__c> locationVolunteers, Map<Id, aos_Location_Volunteer__c> existingLocationVolunteersByIds) {
        List<animalos__Animal__Share> animalShareRecords = new List<animalos__Animal__Share>();
        List<animalos__Location__Share> locationShareRecords = new List<animalos__Location__Share>();
        List<animalos__Alert__Share> alertShareRecords = new List<animalos__Alert__Share>();
        Set<Id> contactIds = vertic_Utils.sObjects.getIdFieldValues(locationVolunteers, aos_Location_Volunteer__c.aos_Volunteer__c);

        Boolean isUpdate = Trigger.isUpdate && existingLocationVolunteersByIds != null && !existingLocationVolunteersByIds.isEmpty();
        Set<Id> locationIds = isUpdate ? vertic_Utils.sObjects.getIdFieldValues(existingLocationVolunteersByIds.values(), aos_Location_Volunteer__c.aos_Location__c) :
                vertic_Utils.sObjects.getIdFieldValues(locationVolunteers, aos_Location_Volunteer__c.aos_Location__c);

        Map<String, SObject> usersByContactIds = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, ContactId
                FROM User
                WHERE ContactId IN :contactIds
                AND Profile.Name IN ('Partners Portal Volunteer User Plus', 'Foster Carer Portal User Plus, Volunteer Portal User Plus')
        ], Schema.User.ContactId);

        Set<Id> userIds = vertic_Utils.sObjects.getIdFieldValues(usersByContactIds.values(), User.Id);

        Map<String, List<SObject>> allSharedAnimalsByUserIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap(
                isUpdate ? [
                        SELECT Id, UserOrGroupId, ParentId
                        FROM animalos__Animal__Share
                        WHERE UserOrGroupId IN :userIds AND RowCause = 'Manual'
                        AND (Parent.animalos__Current_Site__c IN :locationIds
                        OR Parent.animalos__Current_Unit__c IN :locationIds
                        OR Parent.animalos__Current_Block__c IN :locationIds)
                ] : [
                        SELECT Id, UserOrGroupId, ParentId, Parent.animalos__Current_Site__c, Parent.animalos__Current_Unit__c, Parent.animalos__Current_Block__c
                        FROM animalos__Animal__Share
                        WHERE UserOrGroupId IN :userIds AND RowCause = 'Manual'
                        AND Parent.animalos__Stage__c != 'Out'
                ], animalos__Animal__Share.UserOrGroupId);

        Set<Id> animalIds = new Set<Id>();

        for(List<animalos__Animal__Share> animalShareVar : allSharedAnimalsByUserIds.values()) {
            for(animalos__Animal__Share animalShare : animalShareVar) {
                animalIds.add(animalShare.ParentId);
            }
        }

        Map<String, List<SObject>> allSharedLocationsByUserIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, UserOrGroupId
                FROM animalos__Location__Share
                WHERE UserOrGroupId IN :userIds
                AND ParentId IN :locationIds
        ], animalos__Location__Share.UserOrGroupId);

        Map<String, List<SObject>> allSharedAlertsByUserIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, UserOrGroupId, Parent.animalos__Target_Record_Id__c
                FROM animalos__Alert__Share
                WHERE UserOrGroupId IN :userIds
                AND Parent.animalos__Target_Record_Id__c IN :animalIds
        ], animalos__Alert__Share.UserOrGroupId);

        for (aos_Location_Volunteer__c locationVolunteerVar : locationVolunteers) {
            User volunteerVar = (User) usersByContactIds.get(locationVolunteerVar.aos_Volunteer__c);
            List<animalos__Animal__Share> relatedSharedAnimals = allSharedAnimalsByUserIds.get(volunteerVar?.Id);
            List<animalos__Location__Share> relatedSharedLocations = allSharedLocationsByUserIds.get(volunteerVar?.Id);

            if (relatedSharedAnimals != null && !relatedSharedAnimals.isEmpty()) {
                for(animalos__Animal__Share animalShare : relatedSharedAnimals) {
                    if(animalShare.Parent.animalos__Current_Site__c == locationVolunteerVar.aos_Location__c
                            || animalShare.Parent.animalos__Current_Unit__c == locationVolunteerVar.aos_Location__c
                            || animalShare.Parent.animalos__Current_Block__c == locationVolunteerVar.aos_Location__c) {
                        animalShareRecords.add(animalShare);

                        List<animalos__Alert__Share> relatedAlerts = (List<animalos__Alert__Share>) allSharedAlertsByUserIds.get(volunteerVar?.Id);
                        if (relatedAlerts != null && !relatedAlerts.isEmpty()) {
                            for (animalos__Alert__Share alertShare : relatedAlerts) {
                                if (alertShare.Parent.animalos__Target_Record_Id__c.equalsIgnoreCase(animalShare.ParentId)) {
                                    alertShareRecords.add(alertShare);
                                }
                            }
                        }
                    }
                }
            }

            if (relatedSharedLocations != null && !relatedSharedLocations.isEmpty()) {
                locationShareRecords.addAll(relatedSharedLocations);
            }
        }

        if (!animalShareRecords.isEmpty()) {
            delete animalShareRecords;
        }

        if (!locationShareRecords.isEmpty()) {
            delete locationShareRecords;
        }

        if (!alertShareRecords.isEmpty()) {
            delete alertShareRecords;
        }
    }
}