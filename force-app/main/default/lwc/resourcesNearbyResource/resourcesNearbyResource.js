import {api, LightningElement} from 'lwc';

export default class ResourcesNearbyResource extends LightningElement {
    @api resource;
    @api index;
    @api jobId;

    get contactUrl() {
        return location.hostname + '/' + this.resource.aos_Contact__c;
    }

    get contactName() {
        return this.resource.aos_Contact__r?.Name;
    }

    get hasContact() {
        return this.resource.aos_Contact__c !== undefined;
    }

    get accountUrl() {
        return location.hostname + '/' + this.resource.aos_Contact__r?.AccountId;
    }

    get accountName() {
        return this.resource.aos_Contact__r?.Account?.Name;
    }

    get hasAccount() {
        return this.resource.aos_Contact__r?.AccountId !== undefined;
    }

    get mobile() {
        return this.resource.aos_Contact__r?.MobilePhone;
    }

    get phone() {
        return this.resource.aos_Contact__r?.Phone;
    }

    get skills() {
        return this.resource.animalos__Resource_Skills__r || [];
    }

    get distance() {
        return this.resource.distance;
    }
}