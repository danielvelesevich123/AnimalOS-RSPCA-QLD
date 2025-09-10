@IsTest
private class OpportunityCallRDUpdate_TDTMTest {
    @TestSetup static void setup() {

        TDTM_Manager.init(new Set<Type>{
            OpportunityCallRDUpdate_TDTM.class,
            RDConsecutiveClosedLostOpps_TDTM.class
        });

        Account testAcc = new Account(
            Name = 'asdg'
        );
        insert testAcc;

        npe03__Recurring_Donation__c testRD = new npe03__Recurring_Donation__c(
            Name = 'Test RD 1',
            npe03__Date_Established__c = Date.newInstance(2021, 10, 20),
            npe03__Amount__c = 10,
            npe03__Installment_Period__c = 'Monthly',
            npsp__Day_of_Month__c = '2',
            npsp__StartDate__c = Date.today(),
            npe03__Organization__c = testAcc.Id
        );
        insert testRD;

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opp 1',
            AccountId = testAcc.Id,
            StageName = 'Closed Lost',
            Amount = 100,
            CloseDate = Date.newInstance(2021, 10, 18),
            npe03__Recurring_Donation__c = testRD.Id
        );
        Opportunity testOpp1 = new Opportunity(
            AccountId = testAcc.Id,
            Name = 'Test Opp 2',
            StageName = 'Closed Won',
            Amount = 101,
            CloseDate = Date.today()
        );
        insert new List<Opportunity>{
            testOpp, testOpp1
        };
    }
    static testMethod void testBehaviorAfterInsert() {

        npe03__Recurring_Donation__c testRDAfterOppInsert = [
            SELECT Consecutive_Declines__c
            FROM npe03__Recurring_Donation__c
            LIMIT 1
        ];
        System.assertEquals(1, testRDAfterOppInsert.Consecutive_Declines__c);
    }

    static testMethod void testBehaviorAfterDelete() {

        Opportunity testOpp = [
            SELECT Name
            FROM Opportunity
            WHERE Amount = 100
        ];
        delete testOpp;

        npe03__Recurring_Donation__c testRDAfterOppDelete = [
            SELECT Consecutive_Declines__c
            FROM npe03__Recurring_Donation__c
            LIMIT 1
        ];
        System.assertEquals(0, testRDAfterOppDelete.Consecutive_Declines__c);

    }

    static testMethod void testBehaviorAfterUpdate() {

        npe03__Recurring_Donation__c testRD = [
            SELECT Id, Name
            FROM npe03__Recurring_Donation__c
            LIMIT 1
        ];
        Opportunity testOpp = [
            SELECT Id, Name, npe03__Recurring_Donation__c
            FROM Opportunity
            WHERE Amount = 100
        ];
        Opportunity testOpp1 = [
            SELECT Id, Name, npe03__Recurring_Donation__c
            FROM Opportunity
            WHERE Amount = 101
        ];

        testOpp.npe03__Recurring_Donation__c = null;
        update testOpp;
        npe03__Recurring_Donation__c testRDAfterOppUpdate = [
            SELECT Consecutive_Declines__c
            FROM npe03__Recurring_Donation__c
        ];
        System.assertEquals(0, testRDAfterOppUpdate.Consecutive_Declines__c);

        testOpp1.npe03__Recurring_Donation__c = testRD.Id;
        update testOpp1;
        npe03__Recurring_Donation__c testRDAfterOppUpdate1 = [
            SELECT Consecutive_Declines__c
            FROM npe03__Recurring_Donation__c
        ];
        System.assertEquals(0, testRDAfterOppUpdate1.Consecutive_Declines__c);
    }
}