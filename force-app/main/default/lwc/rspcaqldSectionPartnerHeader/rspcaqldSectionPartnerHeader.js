import {LightningElement, wire, api} from 'lwc';
import * as constants from 'c/constants';
import {MessageContext, publish} from "lightning/messageService";
import breadcrumbs from '@salesforce/messageChannel/Breadcrumbs__c';
import {CurrentPageReference} from "lightning/navigation";

export default class RspcaqldSectionPartnerHeader extends LightningElement {
    @api contentKey;
    partner = {};
    rspcaLogo = constants.colourLogoURL;

    messageContext = { data: [] };
    @wire(CurrentPageReference)
    getContentType(currentPageReference) {
        if (currentPageReference && currentPageReference.attributes && currentPageReference.attributes.contentKey) {
            this.contentKey = currentPageReference.attributes?.contentKey;
        }
    }
}