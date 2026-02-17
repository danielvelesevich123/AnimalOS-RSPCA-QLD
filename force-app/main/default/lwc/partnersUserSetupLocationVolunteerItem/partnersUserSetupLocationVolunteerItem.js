import {api, LightningElement} from 'lwc';

export default class PartnersUserSetupLocationVolunteerItem extends LightningElement {

    @api
    isBusy = false;
    @api
    locationVolunteer = {};
    @api
    index;
    @api
    isUserActive;


    handleActivateLocationVolunteerClick() {
        this.dispatchEvent(new CustomEvent('action', {
            detail: {
                action: 'activate',
                index: this.index
            },
            bubbles: false,
            composed: false
        }));
    }

    handleDeactivateLocationVolunteerClick() {
        this.dispatchEvent(new CustomEvent('action', {
            detail: {
                action: 'deactivate',
                index: this.index
            },
            bubbles: false,
            composed: false
        }));
    }

    get isActive() {
        return this.locationVolunteer.aos_Status__c !== 'Inactive';
    }

    get activateButtonDisabled() {
        return this.isUserActive === false || this.isBusy;
    }

    get locationName() {
        return this.locationVolunteer.aos_Location__r.RecordType.DeveloperName === 'Foster' && this.locationVolunteer.aos_Location__r.animalos__Parent_Block__r ? this.locationVolunteer.aos_Location__r.animalos__Parent_Block__r.Name + ' / ' + this.locationVolunteer.aos_Location__r.Name : this.locationVolunteer.aos_Location__r.animalos__Full_Location_Name__c;
    }

    get locationURL() {
        return '/' + this.locationVolunteer.aos_Location__c;
    }
}