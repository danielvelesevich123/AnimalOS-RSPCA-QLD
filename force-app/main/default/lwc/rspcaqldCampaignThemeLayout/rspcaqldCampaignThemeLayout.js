import {api, LightningElement, wire} from 'lwc';
import mobileMenu from '@salesforce/messageChannel/MobileMenu__c';
import headerAction from '@salesforce/messageChannel/HeaderAction__c';
import {
    subscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';

/**
 * @slot header
 * @slot footer
 * @slot default
 */
export default class RspcaqldCampaignThemeLayout extends LightningElement {
    headerActionSubscription;
    mobileSubscription;
    mobileOpen= false;
    @api headerFooterLinksString;
    @api isHeader = false;
    @api isFooterPromise = false;
    @api ourPromiseHeader = 'Our Promise';
    @api ourPromiseDescription = 'We will transition from being reactive to proactive as we seek to address the root cause of animal welfare issues; and by building Socially Conscious Animal Communities. Learn how';
    @api ourPromiseLocationLink = '{"label": "RSPCA Locations", "link": "locations"}';
    @api ourPromisePhone = '{"label": "07 3426 9999<br>(General enquiries)", "link": "07 3426 9999"}';
    @api ourPromiseEmail = '{"label": "Send us an email", "link": "rspcaadmin@rspcaqld.org.au"}';
    @api contactUsLink = 'contact-us';
    @api termsConditionsLink = 'terms-and-conditions';
    @api privacyLink = 'privacy-policy';
    @api fundraiseLink;
    @api giftLink;
    @api footerAcknowledgement = 'RSPCA respectfully acknowledges and recognises Aboriginal and Torres Strait Islander peoples as the Traditional Owners and Custodians of the lands, waters, animals and plants where we live, learn and work.';
    @api companyABN = '74 851 544 037';
    @api cookieLink;
    @api isFacebook = false;
    @api facebookLink;
    @api mobileFacebookLink;
    @api isInstagram = false;
    @api instagramLink;
    @api isXTwitter = false;
    @api xtwitterLink;
    @api isLinkedin = false;
    @api linkedinLink;
    @api isYoutube = false;
    @api youtubeLink;
    @api isTiktok = false;
    @api tiktokLink;

    @wire(MessageContext)
    messageContext;

    get mobileClass() {
        return this.mobileOpen ? 'mobile-open-fixed' : '';
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.mobileSubscription) {
            this.mobileSubscription = subscribe(
                this.messageContext,
                mobileMenu,
                (message) => this.handleMobileMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }

        if (!this.headerActionSubscription) {
            this.headerActionSubscription = subscribe(
                this.messageContext,
                headerAction,
                (message) => this.handleHeaderActionMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMobileMessage(message) {
        if (message) {
            this.mobileOpen = message.open;
        }
    }

    handleHeaderActionMessage(message) {
        this.querySelectorAll('*')[0].querySelector('.' + message.class).scrollIntoView({ block: 'start',  behavior: 'smooth' });
    }
}