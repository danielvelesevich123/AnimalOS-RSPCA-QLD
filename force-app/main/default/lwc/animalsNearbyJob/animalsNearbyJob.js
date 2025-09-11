import {api, LightningElement} from 'lwc';

export default class AnimalsNearbyJob extends LightningElement {
    @api animalReferrals;
    @api index;

    get cardTitle() {
        return this.animalReferrals[0].animalos__Job__r.animalos__Full_Address__c;
    }
}


