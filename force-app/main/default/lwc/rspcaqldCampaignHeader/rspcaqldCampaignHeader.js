import {api, LightningElement, wire} from 'lwc';
import {colourLogoURL, whiteLogoURL} from "c/constants";
import {
    publish,
    MessageContext,
} from 'lightning/messageService';
import mobileMenu from '@salesforce/messageChannel/MobileMenu__c';

export default class RspcaqldCampaignHeader extends LightningElement {
    @api headerLinksString;
    mobileOpen = false;

    @wire(MessageContext)
    messageContext;

    get logoUrl() {
        return this.mobileOpen ? whiteLogoURL : colourLogoURL;
    }

    get mainClass() {
        return 'site-header campaign-header' + (this.mobileOpen ? ' open' : '');
    }

    get mobileMenuClass() {
        return 'subnav' + (this.mobileOpen ? ' active' : '');
    }

    get mobileMenuIconClass() {
        return this.mobileOpen ? 'utility:close' : 'utility:rows';
    }

    get headerLinks() {
        return this.headerLinksString ? JSON.parse(this.headerLinksString) : [];
    }

    handleMobileMenuClick(evt) {
        this.mobileOpen = !this.mobileOpen;
        publish(this.messageContext, mobileMenu, {open: this.mobileOpen});
    }
}