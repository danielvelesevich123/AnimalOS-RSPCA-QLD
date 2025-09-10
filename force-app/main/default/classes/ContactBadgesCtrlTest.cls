@IsTest
private class ContactBadgesCtrlTest {
    @IsTest
    static void test() {
//        Account account = new Account(Name = 'test');
//        insert account;
//
//        Contact contact = new Contact(
//            AccountId = account.Id,
//            LastName = 'testName',
//            npsp__Deceased__c = true,
//            Philanthropy_Level__c = 'Major Donor Affiliated'
//        );
//        insert contact;
//
//        List<Opportunity> opportunities = new List<Opportunity>();
//
//        Opportunity opp = new Opportunity(
//            Name = 'test',
//            StageName = 'Pledged',
//            CloseDate = Date.today().addDays(5),
//            npsp__Primary_Contact__c = contact.Id,
//            RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(Opportunity.SObjectType, 'Bequest')
//        );
//        opportunities.add(opp);
//
//        Opportunity opp1 = new Opportunity(
//            Name = 'test',
//            StageName = 'Closed Won',
//            npsp__Primary_Contact__c = contact.Id,
//            CloseDate = Date.today(),
//            RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(Opportunity.SObjectType, 'MajorGift')
//        );
//        opportunities.add(opp1);
//
//        Opportunity opp3 = new Opportunity(
//            Name = 'test',
//            StageName = 'Active Raffle',
//            npsp__Primary_Contact__c = contact.Id,
//            CloseDate = Date.today().addDays(5),
//            RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(Opportunity.SObjectType, 'Membership')
//        );
//        opportunities.add(opp3);
//
//        Opportunity opp4 = new Opportunity(
//            Name = 'test',
//            StageName = 'Active Raffle',
//            npsp__Primary_Contact__c = contact.Id,
//            CloseDate = Date.today().addDays(5),
//            RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(Opportunity.SObjectType, 'Raffle_Ticket')
//        );
//        opportunities.add(opp4);
//
//        Opportunity opp5 = new Opportunity(
//            Name = 'test',
//            StageName = 'Enrolled',
//            npsp__Primary_Contact__c = contact.Id,
//            CloseDate = Date.today().addDays(5),
//            RecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(Opportunity.SObjectType, 'Home_Ever_After')
//        );
//        opportunities.add(opp5);
//
//        insert opportunities;
//
//        Animal__c animal = new Animal__c(
//            Contact__c = contact.Id
//        );
//        insert animal;
//        Id pricebookId = Test.getStandardPricebookId();
//
//        pmdm__Program__c program1 = new pmdm__Program__c(
//            Name = 'Aged Care',
//            Default_Price_Book__c = pricebookId,
//            pmdm__Status__c = 'Active'
//        );
//        insert program1;
//
//        pmdm__ProgramEngagement__c programEngagement1 = new pmdm__ProgramEngagement__c(
//            pmdm__Program__c = program1.Id,
//            pmdm__Contact__c = contact.Id
//        );
//        insert programEngagement1;
//
//        pmdm__Program__c program2 = new pmdm__Program__c(
//            Name = 'Emergency Boarding',
//            Default_Price_Book__c = pricebookId,
//            pmdm__Status__c = 'Active'
//        );
//        insert program2;
//
//        pmdm__ProgramEngagement__c programEngagement2 = new pmdm__ProgramEngagement__c(
//            pmdm__Program__c = program2.Id,
//            pmdm__Contact__c = contact.Id
//        );
//        insert programEngagement2;
//
//        pmdm__Program__c program3 = new pmdm__Program__c(
//            Name = 'Access to Vet Care',
//            Default_Price_Book__c = pricebookId,
//            pmdm__Status__c = 'Active'
//        );
//        insert program3;
//
//        pmdm__ProgramEngagement__c programEngagement3 = new pmdm__ProgramEngagement__c(
//            pmdm__Program__c = program3.Id,
//            pmdm__Contact__c = contact.Id
//        );
//        insert programEngagement3;
//
//        pmdm__Program__c program4 = new pmdm__Program__c(
//            Name = 'Domestic Violence',
//            Default_Price_Book__c = pricebookId,
//            pmdm__Status__c = 'Active'
//        );
//        insert program4;
//
//        pmdm__ProgramEngagement__c programEngagement4 = new pmdm__ProgramEngagement__c(
//            pmdm__Program__c = program4.Id,
//            pmdm__Contact__c = contact.Id
//        );
//        insert programEngagement4;
//
//        pmdm__Program__c program5 = new pmdm__Program__c(
//            Name = 'Homelessness',
//            Default_Price_Book__c = pricebookId,
//            pmdm__Status__c = 'Active'
//        );
//        insert program5;
//
//        pmdm__ProgramEngagement__c programEngagement5 = new pmdm__ProgramEngagement__c(
//            pmdm__Program__c = program5.Id,
//            pmdm__Contact__c = contact.Id
//        );
//        insert programEngagement5;
//
//        String response = ContactBadgesCtrl.getBadges(contact.Id);
//        BadgesBaseCtrl.BadgesResponse badgesResponse = (BadgesBaseCtrl.BadgesResponse)JSON.deserializeStrict(response, BadgesBaseCtrl.BadgesResponse.class);
//        System.assertEquals(true, badgesResponse.badges.size() > 0);
    }
}