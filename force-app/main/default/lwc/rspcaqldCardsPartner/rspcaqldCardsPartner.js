import {api, LightningElement} from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import * as constants from 'c/constants';

export default class RspcaqldCardsPartner extends NavigationMixin(LightningElement) {
    @api imageUrl;
    @api category;
    @api title;
    @api description;
    @api link;
    @api cardSize = 'Big';
    @api isWhite = false;
    // @api isSmall = false;
    @api isTitle = false;
    @api isCategory = false;
    @api isDisplayPopup = false;
    @api isDisableRedirect = false;
    isPopup = false;
    infoBlack = constants.infoBlack;
    closeWhite = constants.closeWhite;

    get partnerClass() {
        return 'cards-partner ' + this.cardSize.toLowerCase() + (this.isWhite ? ' white' : ' transparent') +
            (this.isDisableRedirect ? ' disable-redirect' : '');
    }

    get partnerImageClass() {
        return 'cards-partner-image' + (this.isWhite ? ' white' : '');
    }

    get popupClass() {return this.isPopup ? 'partner-pop-up pop-up-container active' : 'partner-pop-up pop-up-container';}
    get backdropClass() {return this.isPopup ? 'backdrop open' : 'backdrop';}

    get linkTarget() {
        return this.link && this.link.startsWith('http') ? '_blank' : '_self';
    }

    handleClick(evt) {this.isPopup = true;}
    handlePopupClose(evt) {this.isPopup = false;}

    handlePopupClick(evt) {
        if (evt.target.className == 'pop-up' || evt.target.className == 'pop-up-close-block') this.handlePopupClose();
    }
}