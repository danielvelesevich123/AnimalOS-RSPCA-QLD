import {api, LightningElement} from 'lwc';

export default class AnimalsNearbyJob extends LightningElement {
    @api job;
    @api index;

    get cardTitle() {
        return this.job.animalos__Full_Address__c;
    }

    get animalReferrals() {
        return this.job.animalos__Animal_Referrals__r || [];
    }
}