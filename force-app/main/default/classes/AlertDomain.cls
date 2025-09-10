public without sharing class AlertDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {

    public AlertDomain(List<animalos__Alert__c> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AlertDomain(sObjectList);
        }
    }

    public override void onAfterInsert() {
        this.shareRecords(this.Records, new Map<Id, animalos__Alert__c>());
    }

    private void shareRecords(List<animalos__Alert__c> alerts, Map<Id, animalos__Alert__c> existingAlertsByIds) {
        Set<Id> animalIds = new Set<Id>();

        for (animalos__Alert__c alertVar : alerts) {
            if ('animalos__Animal__c'.equalsIgnoreCase(alertVar.animalos__Target_Object__c) && String.isNotBlank('animalos__Target_Record_Id__c')) {
                animalIds.add(alertVar.animalos__Target_Record_Id__c);
            }
        }

        Map<Id, animalos__Animal__c> animalsByIds = new Map<Id, animalos__Animal__c>([
                SELECT Id, animalos__Current_Site__c, animalos__Current_Unit__c
                FROM animalos__Animal__c
                WHERE Id IN :animalIds
        ]);

        if(!animalsByIds.isEmpty()) {
            Set<Id> locationIds = new Set<Id>();
            locationIds.addAll(vertic_Utils.sObjects.getIdFieldValues(animalsByIds.values(), animalos__Animal__c.animalos__Current_Site__c));
            locationIds.addAll(vertic_Utils.sObjects.getIdFieldValues(animalsByIds.values(), animalos__Animal__c.animalos__Current_Unit__c));

            List<Location_Volunteer__c> existingLocationVolunteers = [
                    SELECT Id, Volunteer__c, Location__c
                    FROM Location_Volunteer__c
                    WHERE Location__c IN :locationIds
            ];

            if (!existingLocationVolunteers.isEmpty()) {
                Map<String, List<SObject>> existingLocationVolunteersByLocations = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap(existingLocationVolunteers, Location_Volunteer__c.Location__c);
                Set<Id> contactIds = vertic_Utils.sObjects.getIdFieldValues(existingLocationVolunteers, Location_Volunteer__c.Volunteer__c);

                Map<String, SObject> usersByContactIds = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                        SELECT Id, ContactId
                        FROM User
                        WHERE ContactId IN :contactIds
                        AND Profile.Name IN ('Partners Portal Volunteer User Plus', 'Foster Carer Portal User Plus')
                ], Schema.User.ContactId);

                List<animalos__Alert__Share> shareRecordsToBeCreated = new List<animalos__Alert__Share>();
                for(animalos__Alert__c alertVar : alerts) {
                    Boolean isInsert = Trigger.isInsert;
                    animalos__Animal__c relatedAnimal = animalsByIds.get(alertVar.animalos__Target_Record_Id__c);
                    if(isInsert && relatedAnimal != null) {
                        List<Location_Volunteer__c> relatedLocationVolunteers = new List<Location_Volunteer__c>();

                        if(existingLocationVolunteersByLocations.containsKey(relatedAnimal.animalos__Current_Site__c)) {
                            relatedLocationVolunteers.addAll((List<Location_Volunteer__c>)existingLocationVolunteersByLocations.get(relatedAnimal.animalos__Current_Site__c));
                        }
                        if(existingLocationVolunteersByLocations.containsKey(relatedAnimal.animalos__Current_Unit__c)) {
                            relatedLocationVolunteers.addAll((List<Location_Volunteer__c>)existingLocationVolunteersByLocations.get(relatedAnimal.animalos__Current_Unit__c));
                        }

                        if(!relatedLocationVolunteers.isEmpty()) {
                            for(Location_Volunteer__c relatedLocationVolunteer : relatedLocationVolunteers) {
                                shareRecordsToBeCreated.add(new animalos__Alert__Share(
                                        ParentId = alertVar.Id,
                                        UserOrGroupId = (usersByContactIds.get(relatedLocationVolunteer.Volunteer__c))?.Id,
                                        RowCause = 'Manual',
                                        AccessLevel = 'Edit'
                                ));
                            }
                        }
                    }
                }

                if(!shareRecordsToBeCreated.isEmpty()) {
                    insert shareRecordsToBeCreated;
                }
            }
        }
    }
}