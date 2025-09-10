import {api, track, LightningElement} from 'lwc';
import indicators from '@salesforce/resourceUrl/animalos__indicatorIcons';

export default class AnimalWelfareJobContact extends LightningElement {
    @api jobContact;
    @api index;
    @api hideActions = false;
    @track contactAdvisories = [];
    showAddViolenceForm = false;
    isContactCentreUser = false;
    isInspector = false;
    flagColor = 'default';
    isBusy = false;

    connectedCallback() {
        if (this.showActions) {
            this.isBusy = true;
        }

        let isObserved = false;
        let isReported = false;
        let existingInteractionCautions = this.jobContact.animalos__Interaction_Cautions__r?.records || [];
        if (this.jobContact.animalos__Contact__r.animalos__Observed_Physical_Violence__c || (existingInteractionCautions.find(ic => ic.animalos__Caution_Type__c === 'Physical Violence' && ic.animalos__Caution_Source__c === 'Observed') !== undefined)) {
            this.contactAdvisories.push('Has Physical Violence Observed.');
            isObserved = true;
        }
        if (this.jobContact.animalos__Contact__r.animalos__Observed_Verbal_Abuse__c || (existingInteractionCautions.find(ic => ic.animalos__Caution_Type__c === 'Verbal Abuse' && ic.animalos__Caution_Source__c === 'Observed') !== undefined)) {
            this.contactAdvisories.push('Has Verbal Abuse Observed.');
            isObserved = true;
        }
        if (this.jobContact.animalos__Contact__r.animalos__Observed_Firearms_Weapons__c || (existingInteractionCautions.find(ic => ic.animalos__Caution_Type__c === 'Firearms/weapons' && ic.animalos__Caution_Source__c === 'Observed') !== undefined)) {
            this.contactAdvisories.push('Has Firearms/Weapons Observed.');
            isObserved = true;
        }
        if (this.jobContact.animalos__Contact__r.animalos__Observed_Known_to_Police__c || (existingInteractionCautions.find(ic => ic.animalos__Caution_Type__c === 'Known to Police' && ic.animalos__Caution_Source__c === 'Observed') !== undefined)) {
            this.contactAdvisories.push('Has Known to Police Observed.');
            isObserved = true;
        }
        if (this.jobContact.animalos__Contact__r.animalos__Observed_Substance_Abuse__c || (existingInteractionCautions.find(ic => ic.animalos__Caution_Type__c === 'Suspected Substance Abuse' && ic.animalos__Caution_Source__c === 'Observed') !== undefined)) {
            this.contactAdvisories.push('Has Suspected Substance Abuse Observed.');
            isObserved = true;
        }
        if (this.jobContact.animalos__Contact__r.animalos__Reported_Physical_Violence__c || (existingInteractionCautions.find(ic => ic.animalos__Caution_Type__c === 'Physical Violence' && ic.animalos__Caution_Source__c === 'Reported') !== undefined)) {
            this.contactAdvisories.push('Has Physical Violence Reported.');
            isReported = true;
        }
        if (this.jobContact.animalos__Contact__r.animalos__Reported_Verbal_Abuse__c || (existingInteractionCautions.find(ic => ic.animalos__Caution_Type__c === 'Verbal Abuse' && ic.animalos__Caution_Source__c === 'Reported') !== undefined)) {
            this.contactAdvisories.push('Has Verbal Abuse Reported.');
            isReported = true;
        }
        if (this.jobContact.animalos__Contact__r.animalos__Reported_Firearms_Weapons__c || (existingInteractionCautions.find(ic => ic.animalos__Caution_Type__c === 'Firearms/weapons' && ic.animalos__Caution_Source__c === 'Reported') !== undefined)) {
            this.contactAdvisories.push('Has Firearms/Weapons Reported.');
            isReported = true;
        }
        if (this.jobContact.animalos__Contact__r.animalos__Reported_Known_to_Police__c || (existingInteractionCautions.find(ic => ic.animalos__Caution_Type__c === 'Known to Police' && ic.animalos__Caution_Source__c === 'Reported') !== undefined)) {
            this.contactAdvisories.push('Has Known to Police Reported.');
            isReported = true;
        }
        if (this.jobContact.animalos__Contact__r.animalos__Reported_Substance_Abuse__c || (existingInteractionCautions.find(ic => ic.animalos__Caution_Type__c === 'Suspected Substance Abuse' && ic.animalos__Caution_Source__c === 'Reported') !== undefined)) {
            this.contactAdvisories.push('Has Suspected Substance Abuse Reported.');
            isReported = true;
        }
        if (this.contactAdvisories.length === 0) {
            this.contactAdvisories.push('No Advisories.');
        }
        this.flagColor = isObserved ? 'red' : (isReported ? 'yellow' : 'default');
    }

    get showContactAdvisories() {
        return this.contactAdvisories.length > 0;
    }

    get showActions() {
        return this.hideActions !== true && this.showAddViolenceForm !== true;
    }

    get jobContactFullAddress() {
        return (this.jobContact.animalos__Contact__r.MailingStreet || '') + ' ' + (this.jobContact.animalos__Contact__r.MailingCity || '') + ' ' + (this.jobContact.animalos__Contact__r.MailingState || '') + ' ' + (this.jobContact.animalos__Contact__r.MailingPostalCode || '') + ' ' + (this.jobContact.animalos__Contact__r.MailingCountry || '');
    }

    get contactName() {
        return ((this.jobContact.animalos__Contact__r.FirstName || '') + ' ' + (this.jobContact.animalos__Contact__r.LastName || '')).trim();
    }

    get contactHasId() {
        return this.jobContact.animalos__Contact__r.Id !== undefined;
    }

    get contactUrl() {
        return location.hostname + '/' + this.jobContact.animalos__Contact__r.Id;
    }

    get jobContactUrl() {
        return location.hostname + '/' + this.jobContact.Id
    }

    get jobContactHasId() {
        return this.jobContact.Id !== undefined;
    }

    handleDeleteClick() {
        this.dispatchEvent(new CustomEvent('action', {
            detail: {
                action: 'delete',
                index: this.index
            },
            bubbles: false,
            composed: false
        }));
    }

    handleEditClick() {
        this.dispatchEvent(new CustomEvent('action', {
            detail: {
                action: 'edit',
                index: this.index
            },
            bubbles: false,
            composed: false
        }));
    }

    handleAddViolenceFormSubmit(event) {
        let interactionCaution = JSON.parse(JSON.stringify(event.detail.interactionCaution));
        this.showAddViolenceForm = false;

        this.dispatchEvent(new CustomEvent('action', {
            detail: {
                action: 'add_violence',
                index: this.index,
                interactionCaution: interactionCaution
            },
            bubbles: false,
            composed: false
        }));
    }

    handleAddViolenceClick() {
        this.showAddViolenceForm = true;
    }

    handleAddViolenceFormCancel(event) {
        this.showAddViolenceForm = false;
    }

    handleSearchCompleted(event) {
        this.isBusy = false;
        if (event?.detail?.payload?.contact) {
            this.dispatchEvent(new CustomEvent('action', {
                detail: {
                    action: 'contact_found',
                    index: this.index,
                    contact: event.detail.payload.contact
                },
                bubbles: false,
                composed: false
            }));
        }
        if (event?.detail?.payload?.isContactCentreUser) {
            this.isContactCentreUser = event.detail.payload.isContactCentreUser;
        }
        if (event?.detail?.payload?.isInspector) {
            this.isInspector = event.detail.payload.isInspector;
        }
    }

    get violenceIcon() {
        return indicators + '/' + this.flagColor + '.png';
    }

    get isVerballyOrPhysicallyAbusive() {
        return this.jobContact.Verbally_or_Physically_Abusive__c === 'Yes';
    }

    get showWarning() {
        return this.isVerballyOrPhysicallyAbusive && this.contactAdvisories?.filter(item => item !== 'No Advisories.')?.length === 0;
    }
}