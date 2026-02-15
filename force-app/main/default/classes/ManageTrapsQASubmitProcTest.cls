@IsTest
private class ManageTrapsQASubmitProcTest {

    @IsTest
    static void testProcess_Success() {
        // Create test data
        animalos__Job__c job = new animalos__Job__c(
            animalos__Status__c = 'Open'
        );
        insert job;

        animalos__Location_Of_Interest__c locationOfInterest = new animalos__Location_Of_Interest__c(
            animalos__Address__CountryCode__s = 'AU',
            animalos__Address__City__s = 'Brisbane',
            animalos__Address__Street__s = '123 Test Street',
            animalos__Address__PostalCode__s = '4000',
            animalos__Address__StateCode__s = 'QLD'
        );
        insert locationOfInterest;

        // Update job with location of interest
        job.animalos__Location_Of_Interest__c = locationOfInterest.Id;
        update job;

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
        insert new List<animalos__Resource__c>{resource1, resource2};

        // Prepare request data
        Map<String, Object> requestData = new Map<String, Object>{
            'recordId' => job.Id,
            'locationOfInterest' => new Map<String, Object>{
                'animalos__Address__CountryCode__s' => 'AU',
                'animalos__Address__City__s' => 'Brisbane',
                'animalos__Address__Street__s' => '123 Updated Street',
                'animalos__Address__PostalCode__s' => '4001',
                'animalos__Address__StateCode__s' => 'QLD'
            },
            'resources' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'Id' => resource1.Id,
                    'Status__c' => 'In Use'
                },
                new Map<String, Object>{
                    'Id' => resource2.Id,
                    'Status__c' => 'In Use'
                }
            }
        };

        Test.startTest();
        
        // Execute the processor
        ManageTrapsQASubmitProc processor = new ManageTrapsQASubmitProc();
        vertic_Response response = processor.process(requestData);

        Test.stopTest();

        // Assertions
        System.assert(response.isValid, 'Response should be valid');
        System.assertNotEquals(null, response.dto.get('jobActivityId'), 'Job Activity ID should be returned');

        // Verify Job Activity was created
        Id jobActivityId = (Id) response.dto.get('jobActivityId');
        animalos__Job_Activity__c createdJobActivity = [
            SELECT Id, animalos__Job__c, animalos__Status__c, animalos__Address__CountryCode__s,
                   animalos__Address__City__s, animalos__Address__Street__s, animalos__Address__PostalCode__s,
                   animalos__Address__StateCode__s, animalos__Start_Date_Time__c, animalos__Type_of_Work__c,
                   RecordTypeId
            FROM animalos__Job_Activity__c
            WHERE Id = :jobActivityId
        ];

        System.assertEquals(job.Id, createdJobActivity.animalos__Job__c, 'Job Activity should be linked to the correct Job');
        System.assertEquals('In Progress', createdJobActivity.animalos__Status__c, 'Status should be In Progress');
        System.assertEquals('AU', createdJobActivity.animalos__Address__CountryCode__s, 'Country code should match');
        System.assertEquals('Brisbane', createdJobActivity.animalos__Address__City__s, 'City should match');
        System.assertEquals('123 Updated Street', createdJobActivity.animalos__Address__Street__s, 'Street should match');
        System.assertEquals('4001', createdJobActivity.animalos__Address__PostalCode__s, 'Postal code should match');
        System.assertEquals('QLD', createdJobActivity.animalos__Address__StateCode__s, 'State code should match');
        System.assertEquals('Trap Deployment', createdJobActivity.animalos__Type_of_Work__c, 'Type of work should be Trap Deployment');
        System.assertNotEquals(null, createdJobActivity.animalos__Start_Date_Time__c, 'Start date time should be set');
        
        // Verify Record Type ID is set using vertic_Utils
        Id expectedRecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Job_Activity__c.SObjectType, 'Trap');
        System.assertEquals(expectedRecordTypeId, createdJobActivity.RecordTypeId, 'Record Type should be set correctly using vertic_Utils');

        // Verify Assigned Resources were created
        List<animalos__Assigned_Resource__c> assignedResources = [
            SELECT Id, animalos__Job_Activity__c, animalos__Resource__c, aos_Trap_Status__c
            FROM animalos__Assigned_Resource__c
            WHERE animalos__Job_Activity__c = :jobActivityId
        ];

        System.assertEquals(2, assignedResources.size(), 'Two assigned resources should be created');
        
        Set<Id> assignedResourceIds = new Set<Id>();
        for (animalos__Assigned_Resource__c assignedResource : assignedResources) {
            assignedResourceIds.add(assignedResource.animalos__Resource__c);
            System.assertEquals(jobActivityId, assignedResource.animalos__Job_Activity__c, 'Assigned resource should be linked to job activity');
            System.assertEquals('In Use', assignedResource.aos_Trap_Status__c, 'Trap status should be In Use');
        }
        
        System.assert(assignedResourceIds.contains(resource1.Id), 'Resource 1 should be assigned');
        System.assert(assignedResourceIds.contains(resource2.Id), 'Resource 2 should be assigned');

        // Verify resources were updated
        List<animalos__Resource__c> updatedResources = [
            SELECT Id, aos_Status__c
            FROM animalos__Resource__c
            WHERE Id IN :new Set<Id>{resource1.Id, resource2.Id}
        ];

        for (animalos__Resource__c resource : updatedResources) {
            System.assertEquals('In Use', resource.aos_Status__c, 'Resource status should be updated to In Use');
        }
    }

    @IsTest
    static void testProcess_MissingRecordId() {
        Map<String, Object> requestData = new Map<String, Object>{
            'locationOfInterest' => new Map<String, Object>{
                'animalos__Address__CountryCode__s' => 'AU'
            },
            'resources' => new List<Map<String, Object>>()
        };

        Test.startTest();
        
        Boolean exceptionThrown = false;
        try {
            ManageTrapsQASubmitProc processor = new ManageTrapsQASubmitProc();
            vertic_Response response = processor.process(requestData);
        } catch (Exception ex) {
            exceptionThrown = true;
            System.assert(ex.getMessage().contains('recordId'), 'Should throw exception for missing recordId');
        }

        Test.stopTest();

        System.assert(exceptionThrown, 'Exception should be thrown when recordId is missing');
    }

    @IsTest
    static void testProcess_EmptyResources() {
        // Create test data
        animalos__Job__c job = new animalos__Job__c(
            animalos__Status__c = 'Open'
        );
        insert job;

        Map<String, Object> requestData = new Map<String, Object>{
            'recordId' => job.Id,
            'locationOfInterest' => new Map<String, Object>{
                'animalos__Address__CountryCode__s' => 'AU',
                'animalos__Address__City__s' => 'Brisbane'
            },
            'resources' => new List<Map<String, Object>>()
        };

        Test.startTest();
        
        ManageTrapsQASubmitProc processor = new ManageTrapsQASubmitProc();
        vertic_Response response = processor.process(requestData);

        Test.stopTest();

        // Should still succeed with empty resources
        System.assert(response.isValid, 'Response should be valid even with empty resources');
        System.assertNotEquals(null, response.dto.get('jobActivityId'), 'Job Activity ID should be returned');

        // Verify no assigned resources were created
        Id jobActivityId = (Id) response.dto.get('jobActivityId');
        List<animalos__Assigned_Resource__c> assignedResources = [
            SELECT Id
            FROM animalos__Assigned_Resource__c
            WHERE animalos__Job_Activity__c = :jobActivityId
        ];

        System.assertEquals(0, assignedResources.size(), 'No assigned resources should be created');
    }
}