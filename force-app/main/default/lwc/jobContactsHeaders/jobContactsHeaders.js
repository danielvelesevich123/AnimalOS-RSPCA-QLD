import {api, LightningElement} from 'lwc';
import jobView from "./jobView.html";
import jobMobileView from "./jobMobileView.html";
import locationView from "./locationView.html";
import locationsNearbyView from "./locationsNearbyView.html";
import locationsNearbyMobileView from "./locationsNearbyMobileView.html";
import contactView from "./contactView.html";
import animalWelfareContactView from "./animalWelfareContactView.html";
import animalWelfareLocationView from "./animalWelfareLocationView.html";
import animalWelfareLocationsNearbyView from "./animalWelfareLocationsNearbyView.html";

export default class JobContactsHeaders extends LightningElement {
    @api view;
    @api disableSelect = false;

    render() {
        if(this.view === 'job') {
            return jobView;
        }
        if(this.view === 'jobMobile') {
            return jobMobileView;
        }
        if(this.view === 'location') {
            return locationView;
        }
        if(this.view === 'locationsNearby') {
            return locationsNearbyView;
        }
        if(this.view === 'locationsNearbyMobile') {
            return locationsNearbyMobileView;
        }
        if(this.view === 'contact') {
            return contactView;
        }
        if(this.view === 'animalWelfareContact') {
            return animalWelfareContactView;
        }
        if(this.view === 'animalWelfareLocation') {
            return animalWelfareLocationView;
        }
        if(this.view === 'animalWelfareLocationsNearby') {
            return animalWelfareLocationsNearbyView;
        }

        return jobView;
    }

    handleSelectAllChange(event) {
        this.dispatchEvent(new CustomEvent('selectall', {
            bubbles: false,
            composed: false,
            detail: {checked: event.target.checked === true}
        }));
    }
}