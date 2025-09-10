import {LightningElement, api} from 'lwc';
import PORTAL_RESOURCE from '@salesforce/resourceUrl/PortalResource';
import formFactorPropertyName from '@salesforce/client/formFactor';
import * as constants from 'c/constants';

export default class RspcaqldFooter extends LightningElement {
    @api ourPromiseHeader;
    @api ourPromiseDescription;
    @api ourPromiseLocationLink;
    @api ourPromisePhone;
    @api ourPromiseEmail;
    @api adoptFooterLinksString;
    @api resourcesFooterLinksString;
    @api getinvolvedFooterLinksString;
    @api welfareFooterLinksString;
    @api wildlifeFooterLinksString;
    @api communityFooterLinksString;
    @api servicesFooterLinksString;
    @api charityFooterLinksString;
    @api partnersFooterLinksString;
    @api footerAcknowledgement;
    @api companyABN;
    @api termsConditionsLink;
    @api privacyLink;
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

    envelopeWhite = constants.envelopeWhite;
    facebookWhite = constants.facebookWhite;
    instagramWhite = constants.instagramWhite;
    linkedinWhite = constants.linkedinWhite;
    locationWhite = constants.locationWhite;
    phoneWhite = constants.phoneWhite;
    tiktokWhite = constants.tiktokWhite;
    xWhite = constants.xWhite;
    youtubeWhite = constants.youtubeWhite;

    footerImage = PORTAL_RESOURCE + '/img/footer-image.png';
    charityLogo = PORTAL_RESOURCE + '/img/charity_logo.png';
    adopt = false;
    resources = false;
    involved = false;
    welfare = false;
    wildlife = false;
    community = false;
    pet = false;
    charity = false;
    partners = false;

    get adoptFooterLinks() {
        return this.adoptFooterLinksString ? JSON.parse(this.adoptFooterLinksString) : {};
    }

    get resourcesFooterLinks() {
        return this.resourcesFooterLinksString ? JSON.parse(this.resourcesFooterLinksString) : {};
    }

    get getinvolvedFooterLinks() {
        return this.getinvolvedFooterLinksString ? JSON.parse(this.getinvolvedFooterLinksString) : {};
    }

    get welfareFooterLinks() {
        return this.welfareFooterLinksString ? JSON.parse(this.welfareFooterLinksString) : {};
    }

    get wildlifeFooterLinks() {
        return this.wildlifeFooterLinksString ? JSON.parse(this.wildlifeFooterLinksString) : {};
    }

    get communityFooterLinks() {
        return this.communityFooterLinksString ? JSON.parse(this.communityFooterLinksString) : {};
    }

    get servicesFooterLinks() {
        return this.servicesFooterLinksString ? JSON.parse(this.servicesFooterLinksString) : {};
    }

    get charityFooterLinks() {
        return this.charityFooterLinksString ? JSON.parse(this.charityFooterLinksString) : {};
    }

    get partnersFooterLinks() {
        return this.partnersFooterLinksString ? JSON.parse(this.partnersFooterLinksString) : {};
    }

    handleAdopt(evt) {this.adopt = !this.adopt}
    get adoptBlock() {return this.getBlockClass(this.adopt);}
    get adoptIcon() {return this.getBlockIcon(this.adopt);}

    handleResources(evt) {this.resources = !this.resources}
    get resourcesBlock() {return this.getBlockClass(this.resources);}
    get resourcesIcon() {return this.getBlockIcon(this.resources);}

    handleInvolved(evt) {this.involved = !this.involved}
    get involvedBlock() {return this.getBlockClass(this.involved);}
    get involvedIcon() {return this.getBlockIcon(this.involved);}

    handleWelfare(evt) {this.welfare = !this.welfare}
    get welfareBlock() {return this.getBlockClass(this.welfare);}
    get welfareIcon() {return this.getBlockIcon(this.welfare);}

    handleWildlife(evt) {this.wildlife = !this.wildlife}
    get wildlifeBlock() {return this.getBlockClass(this.wildlife);}
    get wildlifeIcon() {return this.getBlockIcon(this.wildlife);}

    handleCommunity(evt) {this.community = !this.community}
    get communityBlock() {return this.getBlockClass(this.community);}
    get communityIcon() {return this.getBlockIcon(this.community);}

    handlePet(evt) {this.pet = !this.pet}
    get petBlock() {return this.getBlockClass(this.pet);}
    get petIcon() {return this.getBlockIcon(this.pet);}

    handleCharity(evt) {this.charity = !this.charity}
    get charityBlock() {return this.getBlockClass(this.charity);}
    get charityIcon() {return this.getBlockIcon(this.charity);}

    handlePartners(evt) {this.partners = !this.partners}
    get partnersBlock() {return this.getBlockClass(this.partners);}
    get partnersIcon() {return this.getBlockIcon(this.partnersv);}

    get isTermsConditionsLink() {return this.termsConditionsLink ? true : false;}
    get isPrivacyLink() {return this.privacyLink ? true : false;}
    get isCookieLink() {return this.cookieLink ? true : false;}
    get isOurPromiseLocationLink() {return this.ourPromiseLocationLink ? true : false;}
    get isOurPromisePhone() {return this.ourPromisePhone ? true : false;}
    get isOurPromiseEmail() {return this.ourPromiseEmail ? true : false;}

    get viewfacebookLink() {
        return formFactorPropertyName === 'Large' ? this.facebookLink : this.mobileFacebookLink;
    }

    get opLocation() {
        return this.ourPromiseLocationLink ? JSON.parse(this.ourPromiseLocationLink) : {};
    }

    get opPhone() {
        if (this.ourPromisePhone) {
            let _opPhone = JSON.parse(this.ourPromisePhone);
            _opPhone.link = 'tel:' + _opPhone.link;
            return _opPhone;
        }
        return {};
    }

    get opEmail() {
        if (this.ourPromiseEmail) {
            let _opEmail = JSON.parse(this.ourPromiseEmail);
            _opEmail.link = 'mailto:' + _opEmail.link;
            return _opEmail;
        }
        return {};
    }

    getBlockClass(open) {
        return 'site-footer-links-col-block' + (open ? ' open' : '');
    }
    getBlockIcon(open) {
        return open ? 'utility:chevronup' : 'utility:chevrondown';
    }
}