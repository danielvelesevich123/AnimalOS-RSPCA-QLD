@IsTest
private class PartnersPortalTest {
    @IsTest static void testBehavior() {
        animalos.TDTM.setupTestHandlers(new List<animalos__Setting__c>{
                new animalos__Setting__c(
                        RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Trigger_Handler'),
                        Name = 'TDTM_LocationVolunteerPopulateUserId',
                        animalos__Processor__c = 'TDTM_LocationVolunteerPopulateUserId',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 1,
                        animalos__SObject_Type__c = 'Location_Volunteer__c'
                ),
                new animalos__Setting__c(
                        RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Trigger_Handler'),
                        Name = 'TDTM_LocationVolunteerReshareRecords',
                        animalos__Processor__c = 'TDTM_LocationVolunteerReshareRecords',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 2,
                        animalos__SObject_Type__c = 'Location_Volunteer__c'
                ),
                new animalos__Setting__c(
                        RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Trigger_Handler'),
                        Name = 'TDTM_LocationCreateVolunteer',
                        animalos__Processor__c = 'TDTM_LocationCreateVolunteer',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 1,
                        animalos__SObject_Type__c = 'animalos__Location__c'
                ),
                new animalos__Setting__c(
                        RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Trigger_Handler'),
                        Name = 'TDTM_AnimalPartnersPortalReshareRecords',
                        animalos__Processor__c = 'TDTM_AnimalPartnersPortalReshareRecords',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 1,
                        animalos__SObject_Type__c = 'animalos__Animal__c'
                ),
                new animalos__Setting__c(
                        RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Trigger_Handler'),
                        Name = 'TDTM_MovementAnimalLocations',
                        animalos__Processor__c = 'TDTM_MovementAnimalLocations',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 1,
                        animalos__SObject_Type__c = 'animalos__Movement__c'
                ),
                new animalos__Setting__c(
                        RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Trigger_Handler'),
                        Name = 'TDTM_UserUpdateRelatedLocationVolunteers',
                        animalos__Processor__c = 'TDTM_UserUpdateRelatedLocationVolunteers',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 1,
                        animalos__SObject_Type__c = 'User'
                ),
                new animalos__Setting__c(
                        RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Trigger_Handler'),
                        Name = 'TDTM_UserDisableRelatedVolunteer',
                        animalos__Processor__c = 'TDTM_UserDisableRelatedVolunteer',
                        animalos__Is_Active__c = true,
                        animalos__Order__c = 2,
                        animalos__SObject_Type__c = 'User'
                )
        });

        Contact contactVar = new Contact(
                LastName = 'Testing'
        );
        insert contactVar;

        Profile profileVar = [
                SELECT Id
                FROM Profile
                WHERE Name IN :PartnersPortalReshareRecordsProc.PARTNERS_PORTAL_PROFILE_NAMES AND Name != 'Customer Community Plus Login User'
                LIMIT 1
        ];

        User userVar = new User(
                ContactId = contactVar.Id,
                Alias = 'standard',
                Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = profileVar.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = 'testuserforsecondresource@test.com'
        );
        insert userVar;

        Contact contactVar2 = new Contact(
                LastName = 'Testing 2'
        );
        insert contactVar2;

        User userVar2 = new User(
                ContactId = contactVar2.Id,
                Alias = 'alias2',
                Email = 'standarduser2@testorg.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing 2',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = profileVar.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = 'testuserforsecondresource2@test.com'
        );
        insert userVar2;

        String siteRecordType = vertic_Utils.sObjects.recordTypeIdByAPIName(
                animalos__Location__c.SObjectType,
                'Site'
        );

        String fosterRecordType = vertic_Utils.sObjects.recordTypeIdByAPIName(
                animalos__Location__c.SObjectType,
                'Foster'
        );

        animalos__Location__c siteLocation = new animalos__Location__c(
                RecordTypeId = siteRecordType,
                Name = 'Test Site',
                Online_Adoptions__c = true
        );
        insert siteLocation;

        animalos__Location__c siteLocation2 = new animalos__Location__c(
                RecordTypeId = siteRecordType,
                Name = 'Test Site 2',
                Online_Adoptions__c = true
        );
        insert siteLocation2;

        //test TDTM_LocationCreateVolunteer
        animalos__Location__c fosterLocation = new animalos__Location__c(
                RecordTypeId = fosterRecordType,
                Name = 'Test Foster',
                animalos__Parent_Block__c = siteLocation2.Id,
                animalos__Contact__c = contactVar.Id
        );
        insert fosterLocation;

        fosterLocation.animalos__Contact__c = contactVar2.Id;
        update fosterLocation;

        System.assert([SELECT Id FROM Location_Volunteer__c WHERE Volunteer__c = :contactVar2.Id AND Location__c = :fosterLocation.Id].isEmpty() != true);
        System.assert([SELECT Id FROM Location_Volunteer__c WHERE Volunteer__c = :contactVar.Id AND Location__c = :fosterLocation.Id].isEmpty() == true);

        List<Location_Volunteer__c> allLocationVolunteers = [
                SELECT Id, User__r.Name, Location__r.RecordType.DeveloperName, Location__r.Name, Volunteer__r.Name, User__c
                FROM Location_Volunteer__c
        ];

        animalos__Breed__c animalBreed = new animalos__Breed__c(
                animalos__Class__c = 'Domestic',
                animalos__Type__c = 'Dog',
                Name = 'Test Breed'
        );
        insert animalBreed;

        animalos__Animal__c animal = new animalos__Animal__c(
                animalos__Animal_Name__c = 'Test',
                animalos__Incoming_Date__c = Datetime.now(),
                animalos__Class__c = 'Domestic',
                animalos__Type__c = 'Dog',
                Is_New__c = false,
                animalos__Shelter_ID__c = '123123123ee',
                animalos__Current_Site__c = siteLocation.Id,
                animalos__Age_Group__c = 'Young Adult 6 mths - 1 yr',
                animalos__Primary_Breed__c = animalBreed.Id
        );
        insert animal;

        animalos__Animal__c animal2 = new animalos__Animal__c(
                animalos__Animal_Name__c = 'Test',
                animalos__Incoming_Date__c = Datetime.now(),
                animalos__Class__c = 'Domestic',
                animalos__Type__c = 'Dog',
                Is_New__c = false,
                animalos__Current_Site__c = siteLocation2.Id,
                animalos__Age_Group__c = 'Young Adult 6 mths - 1 yr',
                animalos__Primary_Breed__c = animalBreed.Id,
                animalos__Shelter_ID__c = '123123'
        );
        insert animal2;

        //Test TDTM_LocationVolunteerReshareRecords
        Location_Volunteer__c locationVolunteerVar = new Location_Volunteer__c(
                Location__c = siteLocation.Id,
                Volunteer__c = contactVar.Id
        );
        insert locationVolunteerVar;

        Location_Volunteer__c locationVolunteerVar2 = new Location_Volunteer__c(
                Location__c = siteLocation2.Id,
                Volunteer__c = contactVar2.Id
        );
        insert locationVolunteerVar2;

        System.assert([SELECT COUNT() FROM Vertic_Async_Process__c] == 2);

        //Test TDTM_LocationVolunteerPopulateUserId
        locationVolunteerVar = [
                SELECT Id, Location__c, Volunteer__c, User__c
                FROM Location_Volunteer__c
                WHERE Id = :locationVolunteerVar.Id
        ];

        System.assertEquals(userVar.Id, locationVolunteerVar.User__c);

        //Test TDTM_AnimalPartnersPortalReshareRecords
        animalos__Location__c blockLocation = new animalos__Location__c(
                RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Location__c.SObjectType, 'Block'),
                Name = 'Test Block',
                animalos__Parent_Block__c = siteLocation2.Id
        );
        insert blockLocation;

        animalos__Location__c unitLocation = new animalos__Location__c(
                RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Location__c.SObjectType, 'Unit'),
                Name = 'Test Unit',
                animalos__Parent_Block__c = blockLocation.Id,
                animalos__Capacity__c = 10
        );
        insert unitLocation;

        animalos__Movement__c movementVar = new animalos__Movement__c(
                animalos__Animal__c = animal.Id,
                animalos__Location__c = unitLocation.Id,
                animalos__Current__c = true,
                animalos__Start_Date_Time__c = Datetime.now()
        );
        insert movementVar;

        System.assert([SELECT COUNT() FROM Vertic_Async_Process__c] == 2);

        //Test PartnersPortalReshareRecordsProc
        Location_Volunteer__c locationVolunteerBlockVar = new Location_Volunteer__c(
                Location__c = blockLocation.Id,
                Volunteer__c = contactVar2.Id
        );
        insert locationVolunteerBlockVar;

        Location_Volunteer__c locationVolunteerUnitVar = new Location_Volunteer__c(
                Location__c = unitLocation.Id,
                Volunteer__c = contactVar2.Id
        );
        insert locationVolunteerUnitVar;

        animalos__Location__c offsiteLocation = new animalos__Location__c(
                RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Location__c.SObjectType, 'Offsite'),
                Name = 'Test Offsite'
        );
        insert offsiteLocation;

        Location_Volunteer__c locationVolunteerOffsiteVar = new Location_Volunteer__c(
                Location__c = offsiteLocation.Id,
                Volunteer__c = contactVar2.Id
        );
        insert locationVolunteerOffsiteVar;

        Test.startTest();
        Set<Id> vapIds = vertic_Utils.sObjects.getIdFieldValues([
                SELECT Id
                FROM Vertic_Async_Process__c
                WHERE Group_Key__c = :userVar2.Id
                LIMIT 1
        ], Vertic_Async_Process__c.Id);
        vertic_AsyncProcessBatch.run(new List<Id>(vapIds));
        Test.stopTest();
        //both animalVar and animalVar2 should be shared with userVar2
        System.assertEquals(2, [SELECT COUNT() FROM animalos__Animal__Share WHERE UserOrGroupId = :userVar2.Id]);
        //all locations except siteLocation should be shared with userVar2
        System.assertEquals(5, [SELECT COUNT() FROM animalos__Location__Share WHERE UserOrGroupId = :userVar2.Id]);


        System.runAs(new User(Id = UserInfo.getUserId())) {
            userVar2.IsActive = false;
            update userVar2;

            System.assertEquals(0, [
                    SELECT COUNT()
                    FROM Location_Volunteer__c
                    WHERE Status__c = 'Active' AND Volunteer__c = :userVar2.ContactId
            ]);
        }

    }
}