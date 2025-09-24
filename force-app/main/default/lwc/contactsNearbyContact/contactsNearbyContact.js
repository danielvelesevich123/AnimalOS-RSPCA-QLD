import {api, LightningElement} from 'lwc';

export default class ContactsNearbyContact extends LightningElement {
    @api contact;
    @api index;

    get contactUrl() {
        return location.hostname + '/' + this.contact.Id;
    }

    get contactName() {
        return this.contact.Name;
    }

    get accountUrl() {
        return location.hostname + '/' + this.contact.AccountId;
    }

    get accountName() {
        return this.contact.Account?.Name;
    }

    get hasAccount() {
        return this.contact.AccountId !== undefined;
    }

    get mobile() {
        return this.contact.MobilePhone;
    }

    get phone() {
        return this.contact.Phone;
    }

    get distance() {
        return this.contact.distance;
    }

    get email() {
        return this.contact.Email;
    }
}