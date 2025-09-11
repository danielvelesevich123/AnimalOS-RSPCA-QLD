import {api, LightningElement} from 'lwc';

export default class ResourcesNearbyResource extends LightningElement {
    @api resource;
    @api index;

    get userUrl() {
        return location.hostname + '/' + this.resource.animalos__User__c;
    }

    get userName() {
        return this.resource.animalos__User__r?.Name;
    }

    get mobile() {
        return this.resource.animalos__User__r?.MobilePhone;
    }

    get phone() {
        return this.resource.animalos__User__r?.Phone;
    }

    get companyName() {
        return this.resource.animalos__User__r?.CompanyName;
    }

    get distanceToJob() {
        return this.resource.distanceToJob;
    }

    get skills() {
        return this.resource.animalos__Resource_Skills__r?.records || [];
    }
}


