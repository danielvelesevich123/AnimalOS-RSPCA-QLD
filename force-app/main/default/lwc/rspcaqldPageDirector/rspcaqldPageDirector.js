import {LightningElement, wire, api} from 'lwc';
import {MessageContext, publish} from 'lightning/messageService';
import breadcrumbs from '@salesforce/messageChannel/Breadcrumbs__c';
import {CurrentPageReference} from "lightning/navigation";

export default class RspcaqldPageOurPartners extends LightningElement {
    @api parentsString;
    @api otherHeader = 'Meet the rest of the board';
    @api headerSize;
    @api headerMobileSize;
    @api viewLinkLabel = 'View all';
    @api viewLinkUrl = 'our-board';
    @api contentLink = 'director';
    contentKey = null;
    director = {};
    otherDirectorsString = '';

    @wire(CurrentPageReference)
    getContentType(currentPageReference) {
        if (currentPageReference) {
            this.contentKey = currentPageReference.attributes?.contentKey;
        }
    }

    get isOtherDirectors() {
        return this.otherDirectorsString ? true : false;
    }

    get parents() {
        let _parents = []
        if (this.parentsString) _parents = JSON.parse(this.parentsString);
        return _parents;
    }

    messageContext = { data: [] };
}