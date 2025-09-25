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

    get distanceBilling() {
        return this.account.distanceBilling;
    }

    get distanceShipping() {
        return this.account.distanceShipping;
    }

    get email() {
        return this.account.Email__c;
    }
}