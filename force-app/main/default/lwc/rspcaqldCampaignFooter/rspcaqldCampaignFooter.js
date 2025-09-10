import {api, LightningElement} from 'lwc';
import {colourLogoURL, acncLogoUrl} from "c/constants";
import formFactorPropertyName from '@salesforce/client/formFactor';
import * as constants from "c/constants";

export default class RspcaqldCampaignFooter extends LightningElement {
    colourLogoURL = colourLogoURL;
    acncLogoUrl = acncLogoUrl;
    @api footerLinksString;
    @api isFooterPromise = false;
    @api ourPromiseHeader;
    @api ourPromiseDescription;
    @api ourPromiseLocationLink;
    @api ourPromisePhone;
    @api ourPromiseEmail;
    @api footerAcknowledgement;
    @api companyABN;
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

    get footerLinks() {
        return this.footerLinksString ? JSON.parse(this.footerLinksString) : [];
    }

    get isCookieLink() {return this.cookieLink ? true : false;}
    get isOurPromiseLocationLink() {return this.ourPromiseLocationLink ? true : false;}
    get isOurPromisePhone() {return this.ourPromisePhone ? true : false;}
    get isOurPromiseEmail() {return this.ourPromiseEmail ? true : false;}

    get opLocation() {
        return this.ourPromiseLocationLink ? JSON.parse(this.ourPromiseLocationLink) : {};
    }

    get viewfacebookLink() {
        return formFactorPropertyName === 'Large' ? this.facebookLink : this.mobileFacebookLink;
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
}