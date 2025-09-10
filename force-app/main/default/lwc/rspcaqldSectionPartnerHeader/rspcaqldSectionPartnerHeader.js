import getPartner from '@salesforce/apex/ManagedContentService.getPartnerByContentKey';
import {LightningElement, wire, api} from 'lwc';
import * as constants from 'c/constants';
import {MessageContext, publish} from "lightning/messageService";
import breadcrumbs from '@salesforce/messageChannel/Breadcrumbs__c';
import {CurrentPageReference} from "lightning/navigation";

export default class RspcaqldSectionPartnerHeader extends LightningElement {
    @api contentKey;
    partner = {};
    rspcaLogo = constants.colourLogoURL;

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    getContentType(currentPageReference) {
        if (currentPageReference && currentPageReference.attributes && currentPageReference.attributes.contentKey) {
            this.contentKey = currentPageReference.attributes?.contentKey;
        }
    }

    @wire(getPartner, {contentKey: '$contentKey'})
    wiredArticle({ error, data }) {
        if (data) {
            this.partner = data;
            publish(this.messageContext, breadcrumbs,
                {parents: [{label: 'About us', url: '/our-pillars'}, {label: 'Our Partners', url: '/our-partners'}], current: this.partner.title});
        }
    };
}