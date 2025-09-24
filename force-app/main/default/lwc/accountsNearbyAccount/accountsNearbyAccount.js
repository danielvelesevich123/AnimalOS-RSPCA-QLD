import {api, LightningElement} from 'lwc';

export default class AccountsNearbyAccount extends LightningElement {
    @api account;
    @api index;

    get accountUrl() {
        return location.hostname + '/' + this.account.Id;
    }

    get accountName() {
        return this.account.Name;
    }

    get phone() {
        return this.account.Phone;
    }

    get distance() {
        return this.account.distance;
    }

    get email() {
        return this.account.Email__c;
    }
}