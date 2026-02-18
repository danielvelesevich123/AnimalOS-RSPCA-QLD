import {api, LightningElement} from 'lwc';
import jobView from './jobView.html';
import jobMobileView from './jobMobileView.html';
import contactView from './contactView.html';
import animalWelfareContactView from './animalWelfareContactView.html';
import locationsNearbyView from './locationsNearbyView.html';
import locationsNearbyMobileView from './locationsNearbyMobileView.html';

export default class JobContact extends LightningElement {
    @api jobContact = {};
    @api index;
    @api view;
    @api disableSelect = false;
    isExpanded = false;
    isCautionsExpanded = false;
    jobContactAdvisories = [];
    contactAdvisories = [];

    render() {
        if (this.view === 'job') {
            return jobView;
        }

        if (this.view === 'jobMobile') {
            return jobMobileView;
        }

        if (this.view === 'contact') {
            return contactView;
        }

        if (this.view === 'animalWelfareContact') {
            return animalWelfareContactView;
        }

        if(this.view === 'locationsNearby' || this.view === 'animalWelfareLocationsNearby') {
            return locationsNearbyView;
        }

        if(this.view === 'locationsNearbyMobile') {
            return locationsNearbyMobileView;
        }

        return jobView;
    }

    connectedCallback() {
        //init jobContact advisories
        let relatedInteractionCautions = this.jobContact.animalos__Interaction_Cautions__r?.records || [];
        if (this.jobContact.animalos__Observed_Physical_Violence__c) {
            let relatedInteractionCaution = relatedInteractionCautions.find(caution => caution.animalos__Caution_Type__c === 'Physical Violence' && caution.animalos__Caution_Source__c === 'Observed');
            this.jobContactAdvisories.push({
                short: 'Has Physical Violence Observed.',
                long: 'Observed Physical Violence: ' + (relatedInteractionCaution?.animalos__Caution_Details__c ? relatedInteractionCaution.animalos__Caution_Details__c : '')
            });
        }
        if (this.jobContact.animalos__Observed_Verbal_Abuse__c) {
            let relatedInteractionCaution = relatedInteractionCautions.find(caution => caution.animalos__Caution_Type__c === 'Verbal Abuse' && caution.animalos__Caution_Source__c === 'Observed');
            this.jobContactAdvisories.push({
                short: 'Has Verbal Abuse Observed.',
                long: 'Observed Verbal Abuse: ' + (relatedInteractionCaution?.animalos__Caution_Details__c ? relatedInteractionCaution.animalos__Caution_Details__c : '')
            });
        }
        if (this.jobContact.animalos__Observed_Firearms_Weapons__c) {
            let relatedInteractionCaution = relatedInteractionCautions.find(caution => caution.animalos__Caution_Type__c === 'Firearms/weapons' && caution.animalos__Caution_Source__c === 'Observed');
            this.jobContactAdvisories.push({
                short: 'Has Firearms/Weapons Observed.',
                long: 'Observed Firearms/Weapons: ' + (relatedInteractionCaution?.animalos__Caution_Details__c ? relatedInteractionCaution.animalos__Caution_Details__c : '')
            });
        }
        if (this.jobContact.animalos__Observed_Known_to_Police__c) {
            let relatedInteractionCaution = relatedInteractionCautions.find(caution => caution.animalos__Caution_Type__c === 'Known to Police' && caution.animalos__Caution_Source__c === 'Observed');
            this.jobContactAdvisories.push({
                short: 'Has Known to Police Observed.',
                long: 'Observed Known to Police: ' + (relatedInteractionCaution?.animalos__Caution_Details__c ? relatedInteractionCaution.animalos__Caution_Details__c : '')
            });
        }
        if (this.jobContact.animalos__Observed_Substance_Abuse__c) {
            let relatedInteractionCaution = relatedInteractionCautions.find(caution => caution.animalos__Caution_Type__c === 'Suspected Substance Abuse' && caution.animalos__Caution_Source__c === 'Observed');
            this.jobContactAdvisories.push({
                short: 'Has Suspected Substance Abuse Observed.',
                long: 'Observed Suspected Substance Abuse: ' + (relatedInteractionCaution?.animalos__Caution_Details__c ? relatedInteractionCaution.animalos__Caution_Details__c : '')
            });
        }
        if (this.jobContact.animalos__Reported_Physical_Violence__c) {
            let relatedInteractionCaution = relatedInteractionCautions.find(caution => caution.animalos__Caution_Type__c === 'Physical Violence' && caution.animalos__Caution_Source__c === 'Reported');
            this.jobContactAdvisories.push({
                short: 'Has Physical Violence Reported.',
                long: 'Reported Physical Violence: ' + (relatedInteractionCaution?.animalos__Caution_Details__c ? relatedInteractionCaution.animalos__Caution_Details__c : '')
            });
        }
        if (this.jobContact.animalos__Reported_Verbal_Abuse__c) {
            let relatedInteractionCaution = relatedInteractionCautions.find(caution => caution.animalos__Caution_Type__c === 'Verbal Abuse' && caution.animalos__Caution_Source__c === 'Reported');
            this.jobContactAdvisories.push({
                short: 'Has Verbal Abuse Reported.',
                long: 'Reported Verbal Abuse: ' + (relatedInteractionCaution?.animalos__Caution_Details__c ? relatedInteractionCaution.animalos__Caution_Details__c : '')
            });
        }
        if (this.jobContact.animalos__Reported_Firearms_Weapons__c) {
            let relatedInteractionCaution = relatedInteractionCautions.find(caution => caution.animalos__Caution_Type__c === 'Firearms/weapons' && caution.animalos__Caution_Source__c === 'Reported');
            this.jobContactAdvisories.push({
                short: 'Has Firearms/Weapons Reported.',
                long: 'Reported Firearms/Weapons: ' + (relatedInteractionCaution?.animalos__Caution_Details__c ? relatedInteractionCaution.animalos__Caution_Details__c : '')
            });
        }
        if (this.jobContact.animalos__Reported_Known_to_Police__c) {
            let relatedInteractionCaution = relatedInteractionCautions.find(caution => caution.animalos__Caution_Type__c === 'Known to Police' && caution.animalos__Caution_Source__c === 'Reported');
            this.jobContactAdvisories.push({
                short: 'Has Known to Police Reported.',
                long: 'Reported Known to Police: ' + (relatedInteractionCaution?.animalos__Caution_Details__c ? relatedInteractionCaution.animalos__Caution_Details__c : '')
            });
        }
        if (this.jobContact.animalos__Reported_Substance_Abuse__c) {
            let relatedInteractionCaution = relatedInteractionCautions.find(caution => caution.animalos__Caution_Type__c === 'Suspected Substance Abuse' && caution.animalos__Caution_Source__c === 'Reported');
            this.jobContactAdvisories.push({
                short: 'Has Suspected Substance Abuse Reported.',
                long: 'Reported Suspected Substance Abuse: ' + (relatedInteractionCaution?.animalos__Caution_Details__c ? relatedInteractionCaution.animalos__Caution_Details__c : '')
            });
        }
        if (this.jobContactAdvisories.length === 0) {
            this.jobContactAdvisories.push({short: 'No Cautions.', long: 'No Cautions.'});
        }
        //init contact advisories
        if (this.jobContact.animalos__Contact__r.animalos__Observed_Physical_Violence__c) {
            this.contactAdvisories.push({
                short: 'Has Physical Violence Observed.',
                long: 'Observed Physical Violence History: ' +
                    this.jobContact.animalos__Contact__r.animalos__Number_of_Observed_Physical_Violence__c +
                    ' Jobs Reported, Last Job ' +
                    new Date(this.jobContact.animalos__Contact__r.animalos__Last_Observed_Physical_Violence__c).toLocaleDateString() +
                    '.'
            });
        }
        if (this.jobContact.animalos__Contact__r.animalos__Observed_Verbal_Abuse__c) {
            this.contactAdvisories.push({
                short: 'Has Verbal Abuse Observed.',
                long: 'Observed Verbal Abuse History: ' +
                    this.jobContact.animalos__Contact__r.animalos__Number_of_Observed_Verbal_Abuse__c +
                    ' Jobs Reported, Last Job ' +
                    new Date(this.jobContact.animalos__Contact__r.animalos__Last_Observed_Verbal_Abuse__c).toLocaleDateString() +
                    '.'
            });
        }
        if (this.jobContact.animalos__Contact__r.animalos__Observed_Firearms_Weapons__c) {
            this.contactAdvisories.push({
                short: 'Has Firearms/Weapons Observed.',
                long: 'Observed Firearms/Weapons History: ' +
                    this.jobContact.animalos__Contact__r.animalos__Number_of_Observed_Firearms_Weapons__c +
                    ' Jobs Reported, Last Job ' +
                    new Date(this.jobContact.animalos__Contact__r.animalos__Last_Observed_Firearms_Weapons__c).toLocaleDateString() +
                    '.'
            });
        }
        if (this.jobContact.animalos__Contact__r.animalos__Observed_Known_to_Police__c) {
            this.contactAdvisories.push({
                short: 'Has Known to Police Observed.',
                long: 'Observed Known to Police History: ' +
                    this.jobContact.animalos__Contact__r.animalos__Number_of_Observed_Known_to_Police__c +
                    ' Jobs Reported, Last Job ' +
                    new Date(this.jobContact.animalos__Contact__r.animalos__Last_Observed_Known_to_Police__c).toLocaleDateString() +
                    '.'
            });
        }
        if (this.jobContact.animalos__Contact__r.animalos__Observed_Substance_Abuse__c) {
            this.contactAdvisories.push({
                short: 'Has Suspected Substance Abuse Observed.',
                long: 'Observed Suspected Substance Abuse History: ' +
                    this.jobContact.animalos__Contact__r.animalos__Number_of_Observed_Substance_Abuse__c +
                    ' Jobs Reported, Last Job ' +
                    new Date(this.jobContact.animalos__Contact__r.animalos__Last_Observed_Substance_Abuse__c).toLocaleDateString() +
                    '.'
            });
        }
        if (this.jobContact.animalos__Contact__r.animalos__Reported_Physical_Violence__c) {
            this.contactAdvisories.push({
                short: 'Has Physical Violence Reported.',
                long: 'Reported Physical Violence History: ' +
                    this.jobContact.animalos__Contact__r.animalos__Number_of_Reported_Physical_Violence__c +
                    ' Jobs Reported, Last Job ' +
                    new Date(this.jobContact.animalos__Contact__r.animalos__Last_Reported_Physical_Violence__c).toLocaleDateString() +
                    '.'
            });
        }
        if (this.jobContact.animalos__Contact__r.animalos__Reported_Verbal_Abuse__c) {
            this.contactAdvisories.push({
                short: 'Has Verbal Abuse Reported.',
                long: 'Reported Verbal Abuse History: ' +
                    this.jobContact.animalos__Contact__r.animalos__Number_of_Reported_Verbal_Abuse__c +
                    ' Jobs Reported, Last Job ' +
                    new Date(this.jobContact.animalos__Contact__r.animalos__Last_Reported_Verbal_Abuse__c).toLocaleDateString() +
                    '.'
            });
        }
        if (this.jobContact.animalos__Contact__r.animalos__Reported_Firearms_Weapons__c) {
            this.contactAdvisories.push({
                short: 'Has Firearms/Weapons Reported.',
                long: 'Reported Firearms/Weapons History: ' +
                    this.jobContact.animalos__Contact__r.animalos__Number_of_Reported_Firearms_Weapons__c +
                    ' Jobs Reported, Last Job ' +
                    new Date(this.jobContact.animalos__Contact__r.animalos__Last_Reported_Firearms_Weapons__c).toLocaleDateString() +
                    '.'
            });
        }
        if (this.jobContact.animalos__Contact__r.animalos__Reported_Known_to_Police__c) {
            this.contactAdvisories.push({
                short: 'Has Known to Police Reported.',
                long: 'Reported Known to Police History: ' +
                    this.jobContact.animalos__Contact__r.animalos__Number_of_Reported_Known_to_Police__c +
                    ' Jobs Reported, Last Job ' +
                    new Date(this.jobContact.animalos__Contact__r.animalos__Last_Reported_Known_to_Police__c).toLocaleDateString() +
                    '.'
            });
        }
        if (this.jobContact.animalos__Contact__r.animalos__Reported_Substance_Abuse__c) {
            this.contactAdvisories.push({
                short: 'Has Suspected Substance Abuse Reported.',
                long: 'Reported Suspected Substance Abuse History: ' +
                    this.jobContact.animalos__Contact__r.animalos__Number_of_Reported_Substance_Abuse__c +
                    ' Jobs Reported, Last Job ' +
                    new Date(this.jobContact.animalos__Contact__r.animalos__Last_Reported_Substance_Abuse__c).toLocaleDateString() +
                    '.'
            });
        }
        if (this.contactAdvisories.length === 0) {
            this.contactAdvisories.push({short: 'No Cautions.', long: 'No Cautions.'});
        }
    }

    get showJobContactAdvisories() {
        return this.jobContactAdvisories.length > 0;
    }

    get showContactAdvisories() {
        return this.contactAdvisories.length > 0;
    }

    handleSelectChange(event) {
        this.dispatchEvent(new CustomEvent('action', {
            detail: {
                action: 'select',
                index: this.index,
                id: this.jobContact.Id,
                selected: event.target.checked
            },
            bubbles: false,
            composed: false
        }));
    }

    get jobContactUrl() {
        return location.hostname + '/' + this.jobContact.Id;
    }

    get jobUrl() {
        return location.hostname + '/' + this.jobContact.animalos__Job__r.Id;
    }

    get jobName() {
        return this.jobContact.animalos__Job__r.Name;
    }

    get caseUrl() {
        return location.hostname + '/' + this.jobContact.animalos__Job__r.aos_Case__c;
    }

    get caseNumber() {
        return this.jobContact.animalos__Job__r.aos_Case__r?.CaseNumber;
    }

    get jobOwnerUrl() {
        return location.hostname + '/' + this.jobContact.animalos__Job__r.OwnerId;
    }

    get jobOwnerName() {
        return this.jobContact.animalos__Job__r.Owner.Name;
    }

    get locationUrl() {
        return location.hostname + '/' + this.jobContact.animalos__Job__r.animalos__Location_Of_Interest__r?.Id;
    }

    get locationName() {
        return this.jobContact.animalos__Job__r.animalos__Location_Of_Interest__r?.Name;
    }

    get contactUrl() {
        return location.hostname + '/' + this.jobContact.animalos__Contact__r.Id;
    }

    changeState(event) {
        event.preventDefault();
        event.stopPropagation();
        this.isExpanded = !this.isExpanded;
    }

    changeCautionsState(event) {
        event.preventDefault();
        event.stopPropagation();
        this.isCautionsExpanded = !this.isCautionsExpanded;
    }

    get iconName() {
        return this.isExpanded === false ? 'utility:chevronright' : 'utility:chevrondown';
    }

    get cautionsIconName() {
        return this.isCautionsExpanded === false ? 'utility:chevronright' : 'utility:chevrondown';
    }

    get hasEmail() {
        return this.jobContact.animalos__Contact__r.Email;
    }

    get hasPhone() {
        return this.jobContact.animalos__Contact__r.Phone;
    }

    get hasMobilePhone() {
        return this.jobContact.animalos__Contact__r.MobilePhone;
    }

    get hasAddress() {
        return this.jobContact.animalos__Contact__r.MailingStreet || this.jobContact.animalos__Contact__r.MailingCity || this.jobContact.animalos__Contact__r.MailingState || this.jobContact.animalos__Contact__r.MailingPostalCode;
    }
}