@IsTest
private class ManageTrapsQAMetaProcTest {

    @IsTest
    static void testProcess_Success() {
        // Create test data
        animalos__Location_Of_Interest__c locationOfInterest = new animalos__Location_Of_Interest__c(
            animalos__Address__CountryCode__s = 'AU',
            animalos__Address__City__s = 'Brisbane',
            animalos__Address__Street__s = '123 Test Street',
            animalos__Address__PostalCode__s = '4000',
            animalos__Address__StateCode__s = 'QLD'
        );
        insert locationOfInterest;

        animalos__Job__c job = new animalos__Job__c(
            animalos__Status__c = 'Open',
            animalos__Location_Of_Interest__c = locationOfInterest.Id
        );
        insert job;

        // Create test resources
        animalos__Resource__c resource1 = new animalos__Resource__c(
            Name = 'Test Trap 1',
            animalos__Type__c = 'Trap',
                aos_Status__c = 'Available'
        );
        animalos__Resource__c resource2 = new animalos__Resource__c(
            Name = 'Test Trap 2',
            animalos__Type__c = 'Trap',
                aos_Status__c = 'Available'
        );
        animalos__Resource__c resource3 = new animalos__Resource__c(
            Name = 'Test Non-Trap Resource',
            animalos__Type__c = 'Equipment',
                aos_Status__c = 'Available'
        );
        animalos__Resource__c resource4 = new animalos__Resource__c(
            Name = 'Test Unavailable Trap',
            animalos__Type__c = 'Trap',
                aos_Status__c = 'In Use'
        );
        insert new List<animalos__Resource__c>{resource1, resource2, resource3, resource4};

        Test.startTest();
        
        // Execute the processor
        ManageTrapsQAMetaProc processor = new ManageTrapsQAMetaProc();
        vertic_Response response = processor.process(new Map<String, Object>{
            'recordId' => job.Id
        });

        Test.stopTest();

        // Assertions
        System.assert(response.isValid, 'Response should be valid');
        
        // Verify location of interest ID is returned
        System.assertEquals(locationOfInterest.Id, response.dto.get('locationOfInterestId'), 
            'Location of Interest ID should be returned');

        // Verify resources are returned (should only include available traps)
        List<Object> returnedResources = (List<Object>) response.dto.get('resources');
        System.assertNotEquals(null, returnedResources, 'Resources should be returned');
        System.assertEquals(2, returnedResources.size(), 'Should return 2 available trap resources');

    }

    @IsTest
    static void testProcess_MissingRecordId() {
        Test.startTest();
        
        Boolean exceptionThrown = false;
        try {
            ManageTrapsQAMetaProc processor = new ManageTrapsQAMetaProc();
            vertic_Response response = processor.process(new Map<String, Object>());
        } catch (Exception ex) {
            exceptionThrown = true;
            System.assert(ex.getMessage().contains('recordId'), 'Should throw exception for missing recordId');
        }

        Test.stopTest();

        System.assert(exceptionThrown, 'Exception should be thrown when recordId is missing');
    }

    @IsTest
    static void testProcess_JobWithoutLocationOfInterest() {
        // Create job without location of interest
        animalos__Job__c job = new animalos__Job__c(
            animalos__Status__c = 'Open'
        );
        insert job;

        // Create test resources
        animalos__Resource__c resource1 = new animalos__Resource__c(
            Name = 'Test Trap 1',
            animalos__Type__c = 'Trap',
                aos_Status__c = 'Available'
        );
        insert resource1;

        Test.startTest();
        
        ManageTrapsQAMetaProc processor = new ManageTrapsQAMetaProc();
        vertic_Response response = processor.process(new Map<String, Object>{
            'recordId' => job.Id
        });

        Test.stopTest();

        // Should still succeed but location of interest ID will be null
        System.assert(response.isValid, 'Response should be valid');
        System.assertEquals(null, response.dto.get('locationOfInterestId'), 
            'Location of Interest ID should be null when job has no location of interest');

        // Resources should still be returned
        List<Object> returnedResources = (List<Object>) response.dto.get('resources');
        System.assertNotEquals(null, returnedResources, 'Resources should be returned');
        System.assertEquals(1, returnedResources.size(), 'Should return 1 available trap resource');
    }

    @IsTest
    static void testProcess_NoAvailableTraps() {
        // Create test data
        animalos__Location_Of_Interest__c locationOfInterest = new animalos__Location_Of_Interest__c(
            animalos__Address__CountryCode__s = 'AU',
            animalos__Address__City__s = 'Brisbane'
        );
        insert locationOfInterest;

        animalos__Job__c job = new animalos__Job__c(
            animalos__Status__c = 'Open',
            animalos__Location_Of_Interest__c = locationOfInterest.Id
        );
        insert job;

        // Create only non-trap or unavailable resources
        animalos__Resource__c resource1 = new animalos__Resource__c(
            Name = 'Test Equipment',
            animalos__Type__c = 'Equipment',
                aos_Status__c = 'Available'
        );
        animalos__Resource__c resource2 = new animalos__Resource__c(
            Name = 'Test Unavailable Trap',
            animalos__Type__c = 'Trap',
                aos_Status__c = 'In Use'
        );
        insert new List<animalos__Resource__c>{resource1, resource2};

        Test.startTest();
        
        ManageTrapsQAMetaProc processor = new ManageTrapsQAMetaProc();
        vertic_Response response = processor.process(new Map<String, Object>{
            'recordId' => job.Id
        });

        Test.stopTest();

        // Should succeed with empty resources list
        System.assert(response.isValid, 'Response should be valid');
        System.assertEquals(locationOfInterest.Id, response.dto.get('locationOfInterestId'), 
            'Location of Interest ID should be returned');

        List<Object> returnedResources = (List<Object>) response.dto.get('resources');
        System.assertNotEquals(null, returnedResources, 'Resources should be returned');
        System.assertEquals(0, returnedResources.size(), 'Should return empty resources list when no available traps');
    }

    @IsTest
    static void testProcess_WithNullRequest() {
        // Create test data
        animalos__Location_Of_Interest__c locationOfInterest = new animalos__Location_Of_Interest__c(
            animalos__Address__CountryCode__s = 'AU',
            animalos__Address__City__s = 'Brisbane'
        );
        insert locationOfInterest;

        animalos__Job__c job = new animalos__Job__c(
            animalos__Status__c = 'Open',
            animalos__Location_Of_Interest__c = locationOfInterest.Id
        );
        insert job;

        Test.startTest();
        
        Boolean exceptionThrown = false;
        try {
            ManageTrapsQAMetaProc processor = new ManageTrapsQAMetaProc();
            // Test with null request - should create new MetadataRequest
            vertic_Response response = processor.process((vertic_Request) null);
        } catch (Exception ex) {
            exceptionThrown = true;
            // Should throw exception because recordId is required but null request won't have it
            System.assert(ex.getMessage().contains('recordId'), 'Should throw exception for missing recordId');
        }

        Test.stopTest();

        System.assert(exceptionThrown, 'Exception should be thrown when recordId is missing from null request');
    }

}