@IsTest
private class TDTM_aos_JobContactSetJobPOITest {
    
    @TestSetup
    static void setupTestData() {
        // Create test contacts
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            testContacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact' + i,
                Email = 'testcontact' + i + '@example.com'
            ));
        }
        insert testContacts;
        
        // Create test jobs
        List<animalos__Job__c> testJobs = new List<animalos__Job__c>();
        for (Integer i = 0; i < 3; i++) {
            testJobs.add(new animalos__Job__c(
                Name = 'Test Job ' + i,
                    aos_Person_Of_Interest__c = null
            ));
        }
        insert testJobs;
    }
    
    @IsTest
    static void testOnAfterInsertWithPersonOfInterest() {
        // Setup TDTM test handlers - this is crucial for TDTM handlers to work in tests
        animalos.TDTM.setupTestHandlers(
            new List<animalos__Setting__c>{
                new animalos__Setting__c(
                    RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Trigger_Handler'),
                    Name = 'TDTM_aos_JobContactSetJobPOI',
                    animalos__Processor__c = 'TDTM_aos_JobContactSetJobPOI',
                    animalos__Is_Active__c = true,
                    animalos__Order__c = 1,
                    animalos__SObject_Type__c = 'animalos__Job_Contact__c'
                )
            }
        );
        
        
        // Get test data
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        List<animalos__Job__c> jobs = [SELECT Id FROM animalos__Job__c LIMIT 2];
        
        // Create Job_Contact records with Person of Interest type
        List<animalos__Job_Contact__c> jobContacts = new List<animalos__Job_Contact__c>();
        jobContacts.add(new animalos__Job_Contact__c(
            animalos__Job__c = jobs[0].Id,
            animalos__Contact__c = contacts[0].Id,
            animalos__Contact_Type__c = 'Person Of Interest'
        ));
        jobContacts.add(new animalos__Job_Contact__c(
            animalos__Job__c = jobs[1].Id,
            animalos__Contact__c = contacts[1].Id,
            animalos__Contact_Type__c = 'person of interest' // Test case insensitive
        ));
        
        Test.startTest();
        insert jobContacts;
        Test.stopTest();
        
        // Assert that Person_of_Interest__c field was updated on jobs
        List<animalos__Job__c> updatedJobs = [
            SELECT Id, aos_Person_Of_Interest__c 
            FROM animalos__Job__c 
            WHERE Id IN :jobs
            ORDER BY Id
        ];
        
        System.assertEquals(contacts[0].Id, updatedJobs[0].aos_Person_Of_Interest__c, 
            'First job should have Person_of_Interest__c set to first contact');
        System.assertEquals(contacts[1].Id, updatedJobs[1].aos_Person_Of_Interest__c, 
            'Second job should have Person_of_Interest__c set to second contact');
    }
    
    @IsTest
    static void testOnAfterUpdateWithPersonOfInterest() {
        // Setup TDTM test handlers - this is crucial for TDTM handlers to work in tests
        animalos.TDTM.setupTestHandlers(
            new List<animalos__Setting__c>{
                new animalos__Setting__c(
                    RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Trigger_Handler'),
                    Name = 'TDTM_aos_JobContactSetJobPOI',
                    animalos__Processor__c = 'TDTM_aos_JobContactSetJobPOI',
                    animalos__Is_Active__c = true,
                    animalos__Order__c = 1,
                    animalos__SObject_Type__c = 'animalos__Job_Contact__c'
                )
            }
        );
        
        // Get test data
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        List<animalos__Job__c> jobs = [SELECT Id FROM animalos__Job__c LIMIT 2];
        
        // Create Job_Contact records with different contact type first
        List<animalos__Job_Contact__c> jobContacts = new List<animalos__Job_Contact__c>();
        jobContacts.add(new animalos__Job_Contact__c(
            animalos__Job__c = jobs[0].Id,
            animalos__Contact__c = contacts[0].Id,
            animalos__Contact_Type__c = 'Other Type'
        ));
        insert jobContacts;
        
        // Verify Person_of_Interest__c is not set initially
        List<animalos__Job__c> initialJobs = [
            SELECT Id, aos_Person_Of_Interest__c 
            FROM animalos__Job__c 
            WHERE Id = :jobs[0].Id
        ];
        System.assertEquals(null, initialJobs[0].aos_Person_Of_Interest__c, 
            'Person_of_Interest__c should be null initially');
        
        Test.startTest();
        // Update to Person of Interest type
        jobContacts[0].animalos__Contact_Type__c = 'Person Of Interest';
        update jobContacts;
        Test.stopTest();
        
        // Assert that Person_of_Interest__c field was updated
        List<animalos__Job__c> updatedJobs = [
            SELECT Id, aos_Person_Of_Interest__c 
            FROM animalos__Job__c 
            WHERE Id = :jobs[0].Id
        ];
        
        System.assertEquals(contacts[0].Id, updatedJobs[0].aos_Person_Of_Interest__c, 
            'Job should have Person_of_Interest__c set after update to Person of Interest type');
    }
    
    @IsTest
    static void testOnAfterInsertWithNonPersonOfInterest() {
        // Setup TDTM test handlers - this is crucial for TDTM handlers to work in tests
        animalos.TDTM.setupTestHandlers(
            new List<animalos__Setting__c>{
                new animalos__Setting__c(
                    RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Trigger_Handler'),
                    Name = 'TDTM_aos_JobContactSetJobPOI',
                    animalos__Processor__c = 'TDTM_aos_JobContactSetJobPOI',
                    animalos__Is_Active__c = true,
                    animalos__Order__c = 1,
                    animalos__SObject_Type__c = 'animalos__Job_Contact__c'
                )
            }
        );
        
        // Get test data
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        List<animalos__Job__c> jobs = [SELECT Id FROM animalos__Job__c LIMIT 2];
        
        // Create Job_Contact records with non-Person of Interest types
        List<animalos__Job_Contact__c> jobContacts = new List<animalos__Job_Contact__c>();
        jobContacts.add(new animalos__Job_Contact__c(
            animalos__Job__c = jobs[0].Id,
            animalos__Contact__c = contacts[0].Id,
            animalos__Contact_Type__c = 'Inspector'
        ));
        jobContacts.add(new animalos__Job_Contact__c(
            animalos__Job__c = jobs[1].Id,
            animalos__Contact__c = contacts[1].Id,
            animalos__Contact_Type__c = 'Witness'
        ));
        
        Test.startTest();
        insert jobContacts;
        Test.stopTest();
        
        // Assert that Person_of_Interest__c field was NOT updated
        List<animalos__Job__c> updatedJobs = [
            SELECT Id, aos_Person_Of_Interest__c 
            FROM animalos__Job__c 
            WHERE Id IN :jobs
        ];
        
        for (animalos__Job__c job : updatedJobs) {
            System.assertEquals(null, job.aos_Person_Of_Interest__c, 
                'Person_of_Interest__c should remain null for non-Person of Interest contact types');
        }
    }
    
    @IsTest
    static void testOnAfterUpdateWithNonPersonOfInterest() {
        // Setup TDTM test handlers - this is crucial for TDTM handlers to work in tests
        animalos.TDTM.setupTestHandlers(
            new List<animalos__Setting__c>{
                new animalos__Setting__c(
                    RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Trigger_Handler'),
                    Name = 'TDTM_aos_JobContactSetJobPOI',
                    animalos__Processor__c = 'TDTM_aos_JobContactSetJobPOI',
                    animalos__Is_Active__c = true,
                    animalos__Order__c = 1,
                    animalos__SObject_Type__c = 'animalos__Job_Contact__c'
                )
            }
        );
        
        // Get test data
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        List<animalos__Job__c> jobs = [SELECT Id FROM animalos__Job__c LIMIT 1];
        
        // Create Job_Contact record with Person of Interest type first
        List<animalos__Job_Contact__c> jobContacts = new List<animalos__Job_Contact__c>();
        jobContacts.add(new animalos__Job_Contact__c(
            animalos__Job__c = jobs[0].Id,
            animalos__Contact__c = contacts[0].Id,
            animalos__Contact_Type__c = 'Person Of Interest'
        ));
        insert jobContacts;
        
        // Verify Person_of_Interest__c is set initially
        List<animalos__Job__c> initialJobs = [
            SELECT Id, aos_Person_Of_Interest__c 
            FROM animalos__Job__c 
            WHERE Id = :jobs[0].Id
        ];
        System.assertEquals(contacts[0].Id, initialJobs[0].aos_Person_Of_Interest__c, 
            'Person_of_Interest__c should be set initially');
        
        Test.startTest();
        // Update to non-Person of Interest type
        jobContacts[0].animalos__Contact_Type__c = 'Inspector';
        update jobContacts;
        Test.stopTest();
        
        // Assert that Person_of_Interest__c field remains unchanged
        List<animalos__Job__c> updatedJobs = [
            SELECT Id, aos_Person_Of_Interest__c 
            FROM animalos__Job__c 
            WHERE Id = :jobs[0].Id
        ];
        
        System.assertEquals(contacts[0].Id, updatedJobs[0].aos_Person_Of_Interest__c, 
            'Person_of_Interest__c should remain unchanged when updating to non-POI type');
    }
    
    @IsTest
    static void testMixedContactTypes() {
        // Setup TDTM test handlers - this is crucial for TDTM handlers to work in tests
        animalos.TDTM.setupTestHandlers(
            new List<animalos__Setting__c>{
                new animalos__Setting__c(
                    RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Setting__c.SObjectType, 'Trigger_Handler'),
                    Name = 'TDTM_aos_JobContactSetJobPOI',
                    animalos__Processor__c = 'TDTM_aos_JobContactSetJobPOI',
                    animalos__Is_Active__c = true,
                    animalos__Order__c = 1,
                    animalos__SObject_Type__c = 'animalos__Job_Contact__c'
                )
            }
        );
        
        // Get test data
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 3];
        List<animalos__Job__c> jobs = [SELECT Id FROM animalos__Job__c LIMIT 3];
        
        // Create Job_Contact records with mixed contact types
        List<animalos__Job_Contact__c> jobContacts = new List<animalos__Job_Contact__c>();
        jobContacts.add(new animalos__Job_Contact__c(
            animalos__Job__c = jobs[0].Id,
            animalos__Contact__c = contacts[0].Id,
            animalos__Contact_Type__c = 'Person Of Interest'
        ));
        jobContacts.add(new animalos__Job_Contact__c(
            animalos__Job__c = jobs[1].Id,
            animalos__Contact__c = contacts[1].Id,
            animalos__Contact_Type__c = 'Inspector'
        ));
        jobContacts.add(new animalos__Job_Contact__c(
            animalos__Job__c = jobs[2].Id,
            animalos__Contact__c = contacts[2].Id,
            animalos__Contact_Type__c = 'PERSON OF INTEREST' // Test uppercase
        ));
        
        Test.startTest();
        insert jobContacts;
        Test.stopTest();
        
        // Assert results
        List<animalos__Job__c> updatedJobs = [
            SELECT Id, aos_Person_Of_Interest__c 
            FROM animalos__Job__c 
            WHERE Id IN :jobs
            ORDER BY Id
        ];
        
        System.assertEquals(contacts[0].Id, updatedJobs[0].aos_Person_Of_Interest__c, 
            'First job should have Person_of_Interest__c set');
        System.assertEquals(null, updatedJobs[1].aos_Person_Of_Interest__c, 
            'Second job should NOT have Person_of_Interest__c set');
        System.assertEquals(contacts[2].Id, updatedJobs[2].aos_Person_Of_Interest__c, 
            'Third job should have Person_of_Interest__c set (case insensitive)');
    }
    
    @IsTest
    static void testDirectHandlerExecution() {
        // Get test data
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        List<animalos__Job__c> jobs = [SELECT Id FROM animalos__Job__c LIMIT 1];
        
        // Create Job_Contact record with Person of Interest type (don't insert)
        animalos__Job_Contact__c jobContact = new animalos__Job_Contact__c(
            animalos__Job__c = jobs[0].Id,
            animalos__Contact__c = contacts[0].Id,
            animalos__Contact_Type__c = 'Person Of Interest'
        );
        
        Test.startTest();
        // Test direct handler execution first
        TDTM_aos_JobContactSetJobPOI handler = new TDTM_aos_JobContactSetJobPOI();
        handler.onAfterInsert(new List<animalos__Job_Contact__c>{jobContact});
        Test.stopTest();
        
        // Assert that Person_of_Interest__c field was updated
        List<animalos__Job__c> updatedJobs = [
            SELECT Id, aos_Person_Of_Interest__c 
            FROM animalos__Job__c 
            WHERE Id = :jobs[0].Id
        ];
        
        System.assertEquals(contacts[0].Id, updatedJobs[0].aos_Person_Of_Interest__c, 
            'Person_of_Interest__c should be set when handler is called directly');
    }
}