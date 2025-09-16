import {api, LightningElement} from 'lwc';

export default class ResourcesNearbyResource extends LightningElement {
    @api resource;
    @api index;
    @api jobId;

    get contactUrl() {
        return location.hostname + '/' + this.resource.animalos__Contact__c;
    }

    get contactName() {
        return this.resource.animalos__Contact__r?.Name;
    }

    get mobile() {
        return this.resource.animalos__Contact__r?.MobilePhone;
    }

    get phone() {
        return this.resource.animalos__Contact__r?.Phone;
    }

    get companyName() {
        return this.resource.animalos__Contact__r?.Account?.Name;
    }

    get skills() {
        return this.resource.animalos__Resource_Skills__r?.records || [];
    }
}


