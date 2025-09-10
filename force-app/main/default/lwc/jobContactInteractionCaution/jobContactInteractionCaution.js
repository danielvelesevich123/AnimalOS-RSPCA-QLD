import {LightningElement, api} from 'lwc';
import jobView from "./jobView.html";
import jobMobileView from "./jobMobileView.html";

export default class JobContactInteractionCaution extends LightningElement {
    @api index;
    @api interactionCaution = {};
    @api view;

    get interactionCautionUrl() {
        return location.hostname + '/' + this.interactionCaution.Id;
    }

    render() {
        if(this.view === 'job') {
            return jobView;
        }
        if(this.view === 'jobMobile' || this.view === 'locationsNearbyMobile') {
            return jobMobileView;
        }

        return jobView;
    }

    get interactionCautionSourceType() {
        return this.interactionCaution.animalos__Caution_Source__c + ' ' + this.interactionCaution.animalos__Caution_Type__c;
    }
}