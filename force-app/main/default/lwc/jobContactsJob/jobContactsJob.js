import {api, LightningElement} from 'lwc';
import locationView from './locationView.html';
import animalWelfareLocationView from './animalWelfareLocationView.html';
import locationsNearbyView from './locationsNearbyView.html';
import locationsNearbyMobileView from './locationsNearbyMobileView.html';
import animalWelfareLocationsNearbyView from './animalWelfareLocationsNearbyView.html';

export default class JobContactsJob extends LightningElement {
    @api jobContacts = [];
    @api index;
    @api disableSelect = false;
    @api view;
    isExpanded = false;

    render() {
        if (this.view === 'location') {
            return locationView;
        }
        if (this.view === 'animalWelfareLocation') {
            return animalWelfareLocationView;
        }
        if (this.view === 'locationsNearby') {
            return locationsNearbyView;
        }
        if(this.view === 'locationsNearbyMobile') {
            return locationsNearbyMobileView;
        }
        if (this.view === 'animalWelfareLocationsNearby') {
            return animalWelfareLocationsNearbyView;
        }

        return locationView;
    }

    get showJobContactsTable() {
        return this.jobContacts.length > 0;
    }

    handleSelectChange(event) {
        this.dispatchEvent(new CustomEvent('action', {
            detail: {
                action: 'select',
                index: this.index,
                selected: event.target.checked
            },
            bubbles: false,
            composed: false
        }));
    }

    get jobUrl() {
        return location.hostname + '/' + this.jobContacts[0].animalos__Job__c;
    }

    get caseUrl() {
        return location.hostname + '/' + this.jobContacts[0].animalos__Job__r.aos_Case__c;
    }

    get caseNumber() {
        return this.jobContacts[0].animalos__Job__r.aos_Case__r?.CaseNumber;
    }

    get jobCreatedDate() {
        return this.jobContacts[0].animalos__Job__r.CreatedDate;
    }

    get jobName() {
        return this.jobContacts[0].animalos__Job__r.Name;
    }

    get jobStatus() {
        return this.jobContacts[0].animalos__Job__r.animalos__Status__c;
    }

    get jobOwnerUrl() {
        return location.hostname + '/' + this.jobContacts[0].animalos__Job__r.OwnerId;
    }

    get jobOwnerName() {
        return this.jobContacts[0].animalos__Job__r.Owner.Name;
    }

    get jobAdvisory() {
        return this.jobContacts[0].animalos__Job__r.animalos__Advisory__c;
    }

    get currentJobAdvisory() {
        return this.jobContacts[0].animalos__Job__r.animalos__Current_Job_Advisory__c;
    }

    changeState(event) {
        event.preventDefault();
        event.stopPropagation();
        this.isExpanded = !this.isExpanded;
    }

    get iconName() {
        return this.isExpanded === false ? "utility:chevronright" : "utility:chevrondown";
    }

    handleJobContactAction(event) {
        let detail = event.detail;
        detail.index = this.index;
        this.dispatchEvent(new CustomEvent('action', {
            bubbles: false,
            composed: false,
            detail: detail
        }));
    }
}