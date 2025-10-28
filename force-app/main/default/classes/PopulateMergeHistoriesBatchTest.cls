@IsTest
public class PopulateMergeHistoriesBatchTest {

    @TestSetup
    static void setupTestData() {
        // Create test contacts with various field combinations
        List<Contact> testContacts = new List<Contact>();

        // Contact 1: All fields populated
        testContacts.add(new Contact(
                FirstName = 'Test1',
                LastName = 'Contact1',
                ShelterBuddy_ID_PID__c = 'PID001',
                BPAY_CRN__c = '123456',
                Second_BPAY_CRN__c = '212345',
                BPAY_CRN_History__c = '111111,222222,123456', // Includes current BPAY_CRN__c
                BPAY_CRN_History_2__c = '333333,444444',
                Merged_PIDs__c = 'OLD001,OLD002,PID001', // Includes current PID
                Merged_PIDs_2__c = 'OLD003,OLD004',
                Merge_Histories_Created__c = false
        ));

        // Contact 2: Minimal fields populated
        testContacts.add(new Contact(
                FirstName = 'Test2',
                LastName = 'Contact2',
                ShelterBuddy_ID_PID__c = 'PID002',
                BPAY_CRN__c = '654321',
                Merge_Histories_Created__c = false
        ));

        // Contact 3: No BPAY fields, only PID fields
        testContacts.add(new Contact(
                FirstName = 'Test3',
                LastName = 'Contact3',
                ShelterBuddy_ID_PID__c = 'PID003',
                Merged_PIDs__c = 'OLD005,OLD006',
                Merge_Histories_Created__c = false
        ));

        // Contact 4: Already processed (Merge_Histories_Created__c = true)
        testContacts.add(new Contact(
                FirstName = 'Test4',
                LastName = 'Contact4',
                ShelterBuddy_ID_PID__c = 'PID004',
                BPAY_CRN__c = '999999',
                Merge_Histories_Created__c = true
        ));

        // Contact 5: No ShelterBuddy ID (should not be processed)
        testContacts.add(new Contact(
                FirstName = 'Test5',
                LastName = 'Contact5',
                BPAY_CRN__c = '888888',
                Merge_Histories_Created__c = false
        ));

        insert testContacts;

        // Create some existing merge histories to test duplicate prevention
        List<Merge_History__c> existingHistories = new List<Merge_History__c>();
        existingHistories.add(new Merge_History__c(
                Contact__c = testContacts[0].Id,
                Type__c = 'BPAY CRN',
                Name = '123456' // Same as Contact1's BPAY_CRN__c
        ));
        existingHistories.add(new Merge_History__c(
                Contact__c = testContacts[0].Id,
                Type__c = 'ShelterBuddy ID (PID)',
                Name = 'PID001' // Same as Contact1's ShelterBuddy_ID_PID__c
        ));

        insert existingHistories;
    }

    @IsTest
    static void testBatchWithNoParameters() {
        // Test default constructor
        Test.startTest();
        PopulateMergeHistoryBatch batch = new PopulateMergeHistoryBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify results
        verifyMergeHistoriesCreated();
    }

    @IsTest
    static void testBatchWithRecordIds() {
        List<Contact> contacts = [SELECT Id FROM Contact WHERE ShelterBuddy_ID_PID__c = 'PID001' OR ShelterBuddy_ID_PID__c = 'PID002'];
        Set<String> recordIds = new Set<String>();
        for(Contact c : contacts) {
            recordIds.add(c.Id);
        }

        Test.startTest();
        PopulateMergeHistoryBatch batch = new PopulateMergeHistoryBatch(recordIds);
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify only the specified contacts were processed
        List<Contact> processedContacts = [SELECT Id, Merge_Histories_Created__c FROM Contact WHERE Id IN :recordIds];
        for(Contact c : processedContacts) {
            System.assertEquals(true, c.Merge_Histories_Created__c, 'Contact should be marked as processed');
        }

        // Verify merge histories were created for specified contacts
        List<Merge_History__c> histories = [SELECT Id, Contact__c FROM Merge_History__c WHERE Contact__c IN :recordIds];
        System.assert(!histories.isEmpty(), 'Merge histories should be created for specified contacts');
    }

    @IsTest
    static void testBpayCrnHistoryProcessing() {
        Contact testContact = [SELECT Id, BPAY_CRN_History__c FROM Contact WHERE ShelterBuddy_ID_PID__c = 'PID001' LIMIT 1];

        Test.startTest();
        PopulateMergeHistoryBatch batch = new PopulateMergeHistoryBatch(new Set<String>{testContact.Id});
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify BPAY CRN History was processed correctly
        List<Merge_History__c> histories = [
                SELECT Id, Type__c, Name
                FROM Merge_History__c
                WHERE Contact__c = :testContact.Id
                AND Type__c IN ('BPAY CRN', 'Second BPAY CRN')
                ORDER BY Type__c, Name
        ];

        // Should have:
        // - BPAY_CRN__c: '123456' (but already exists, so not created again)
        // - Second_BPAY_CRN__c: '212345'
        // - BPAY_CRN_History__c: '111111'(BPAY), '222222'(BPAY) - '123456' is excluded because it's current
        // - BPAY_CRN_History_2__c: '333333'(BPAY), '444444'(BPAY)

        Set<String> expectedBpayNumbers = new Set<String>{'111111', '222222', '333333', '444444', '212345'};

        for(Merge_History__c history : histories) {
            if(expectedBpayNumbers.contains(history.Name)) {
                expectedBpayNumbers.remove(history.Name);
            }
        }

        System.assertEquals(0, expectedBpayNumbers.size(), 'All expected BPAY numbers should have merge histories: ' + expectedBpayNumbers);
    }

    @IsTest
    static void testPidHistoryProcessing() {
        Contact testContact = [SELECT Id, Merged_PIDs__c, Merged_PIDs_2__c FROM Contact WHERE ShelterBuddy_ID_PID__c = 'PID001' LIMIT 1];

        Test.startTest();
        PopulateMergeHistoryBatch batch = new PopulateMergeHistoryBatch(new Set<String>{testContact.Id});
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify PID History was processed correctly
        List<Merge_History__c> histories = [
                SELECT Id, Name
                FROM Merge_History__c
                WHERE Contact__c = :testContact.Id
                AND Type__c = 'ShelterBuddy ID (PID)'
                ORDER BY Name
        ];

        // Should have:
        // - ShelterBuddy_ID_PID__c: 'PID001' (but already exists, so not created again)
        // - Merged_PIDs__c: 'OLD001', 'OLD002' - 'PID001' is excluded because it's current
        // - Merged_PIDs_2__c: 'OLD003', 'OLD004'

        Set<String> expectedPids = new Set<String>{'OLD001', 'OLD002', 'OLD003', 'OLD004'};

        for(Merge_History__c history : histories) {
            if(expectedPids.contains(history.Name)) {
                expectedPids.remove(history.Name);
            }
        }

        System.assertEquals(0, expectedPids.size(), 'All expected PIDs should have merge histories: ' + expectedPids);
    }

    // Helper method to verify merge histories were created
    private static void verifyMergeHistoriesCreated() {
        // Verify contacts are marked as processed
        List<Contact> processedContacts = [SELECT Id FROM Contact WHERE Merge_Histories_Created__c = true AND ShelterBuddy_ID_PID__c != null];
        System.assert(processedContacts.size() > 0, 'At least some contacts should be marked as processed');

        // Verify merge histories were created
        List<Merge_History__c> allHistories = [SELECT Id, Contact__c, Type__c, Name FROM Merge_History__c];
        System.assert(allHistories.size() >= 2, 'Should have created at least some merge histories');

        // Verify different types of merge histories exist
        List<Merge_History__c> bpayHistories = [SELECT Id FROM Merge_History__c WHERE Type__c = 'BPAY CRN'];
        List<Merge_History__c> secondBpayHistories = [SELECT Id FROM Merge_History__c WHERE Type__c = 'Second BPAY CRN'];
        List<Merge_History__c> pidHistories = [SELECT Id FROM Merge_History__c WHERE Type__c = 'ShelterBuddy ID (PID)'];

        System.assert(bpayHistories.size() > 0 || secondBpayHistories.size() > 0 || pidHistories.size() > 0,
                'Should have created at least one type of merge history');
    }
}