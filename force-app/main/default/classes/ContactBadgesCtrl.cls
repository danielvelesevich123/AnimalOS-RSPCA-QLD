public class ContactBadgesCtrl extends BadgesBaseCtrl {

    @AuraEnabled
    public static String getBadges(Id recordId) {
        try {
            return JSON.serialize(new BadgesProcessor(recordId).process());
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }

    public class BadgesProcessor {

        private Id recordId;
        private Contact contactVar;
        private Contact contact;

        private List<npe03__Recurring_Donation__c> recurringDonations;
        private List<npe5__Affiliation__c> affiliations;

        private List<npe5__Affiliation__c> stuffAffiliations = new List<npe5__Affiliation__c>();
        private List<npe5__Affiliation__c> boardMemberAffiliations = new List<npe5__Affiliation__c>();
        private List<Opportunity> majorDonorOpportunities = new List<Opportunity>();
        private List<Opportunity> confirmedBequestorOpportunities = new List<Opportunity>();
        private List<npe03__Recurring_Donation__c> activeRecurringDonations = new List<npe03__Recurring_Donation__c>();

        private BadgesResponse response = new BadgesResponse();

        public BadgesProcessor(Id recordId) {
            this.recordId = recordId;
        }

        public BadgesResponse process() {
            retrieveContact();
            populateBadges();
            return this.response;
        }

        private void retrieveContact() {
            List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Id = :this.recordId];
            if (!contacts.isEmpty()) {
                this.contactVar = contacts.get(0);
            }
        }

        private void populateBadges() {
            initMetaData();
            populateContactIcons();
            populateRecurringDonationIcons();
            populateOpportunityIcons();
            populateAffiliationIcons();
        }

        private void initMetaData() {
            this.contact = (Contact) vertic_Utils.arrays.firstOrNull([
                    SELECT Id,npsp__Deceased__c, npsp__Do_Not_Contact__c, Review_Before_Contact__c, Active_Member__c, Gold_Bequestor_Status__c
                    FROM Contact
                    WHERE Id = :this.recordId
            ]);

            this.recurringDonations = [
                    SELECT Id, npsp__Status__c
                    FROM npe03__Recurring_Donation__c
                    WHERE npe03__Contact__c = :this.contactVar.Id
            ];


            for (npe03__Recurring_Donation__c recurringDonation : this.recurringDonations) {
                if (recurringDonation.npsp__Status__c == 'Active') {
                    this.activeRecurringDonations.add(recurringDonation);
                }
            }

            this.affiliations = [
                    SELECT Id, npe5__Role__c, npe5__Organization__r.Name
                    FROM npe5__Affiliation__c
                    WHERE npe5__Contact__c = :this.recordId
            ];

            for (npe5__Affiliation__c affiliation : affiliations) {
                if (affiliation.npe5__Role__c == 'Staff Member' && affiliation.npe5__Organization__r.Name == 'RSPCA QLD') {
                    this.stuffAffiliations.add(affiliation);
                }
                if (affiliation.npe5__Role__c == 'Board Member' && affiliation.npe5__Organization__r.Name == 'RSPCA QLD') {
                    this.boardMemberAffiliations.add(affiliation);
                }
            }

            for (Opportunity opportunityVar : [
                    SELECT Amount, StageName, RecordType.DeveloperName,
                            npe03__Recurring_Donation__c, //Days_Since_Payment__c,
                            npe03__Recurring_Donation__r.npsp__Status__c,
                            npe01__Membership_End_Date__c, IsClosed
                    FROM Opportunity
                    WHERE npsp__Primary_Contact__c = :this.recordId
            ]) {
                if (opportunityVar.RecordType != null && 'MajorGift'.equals(opportunityVar.RecordType.DeveloperName)
                        && 'Closed Won'.equals(opportunityVar.StageName)) {
                    this.majorDonorOpportunities.add(opportunityVar);
                }
                if(opportunityVar.RecordType !=null && 'Gift_In_Will'.equals(opportunityVar.RecordType.DeveloperName)
                        && ('Confirmed'.equalsIgnoreCase(opportunityVar.StageName) || 'Confirmed - Parked'.equalsIgnoreCase(opportunityVar.StageName))){
                    this.confirmedBequestorOpportunities.add(opportunityVar);
                }
            }
        }

        private void populateContactIcons(){
            if(this.contact.Review_Before_Contact__c == true){
                this.response.badges.add(new Badge(
                        'standard:incident',
                        'Review Notes Before Contact'
                ));
            }

            if (this.contact.npsp__Do_Not_Contact__c == true
                || this.contact.npsp__Deceased__c == true
            ) {
                String title = this.contact.npsp__Deceased__c == true
                                ? 'Deceased'
                                : 'Do not Contact';

                this.response.badges.add(new Badge(
                        'standard:first_non_empty',
                        title
                ));
            }

            if(this.contact.Active_Member__c == true){
                this.response.badges.add(new Badge(
                        'standard:team_member',
                        'Member')
                );
            }

            if(this.contact.Gold_Bequestor_Status__c != null){
                this.response.badges.add(new Badge(
                        'standard:reward',
                        'Gold Bequestor'
                ));
            }
        }

        private void populateRecurringDonationIcons() {
            if (this.activeRecurringDonations.size() > 0) {
                this.response.badges.add(new Badge(
                        'standard:investment_account',
                        'Active Recurring Donor',
                        'slds-badge'
                ));
            }
        }


        private void populateOpportunityIcons() {
            if (this.majorDonorOpportunities.size() > 0) {
                this.response.badges.add(new Badge(
                        'standard:opportunity',
                        'Major Donor')
                );
            }

            if(this.confirmedBequestorOpportunities.size() > 0){
                this.response.badges.add(new Badge(
                        'standard:contract',
                        'Confirmed Bequestor')
                );
            }

        }

        private void populateAffiliationIcons() {

                if (this.stuffAffiliations.size() > 0) {
                    this.response.badges.add(new Badge(
                            'standard:employee_contact',
                            'Staff')
                    );
                }

            if(this.boardMemberAffiliations.size() > 0) {
                this.response.badges.add(new Badge(
                        'standard:groups',
                        'Board Member'
                ));
            }

        }


    }
}