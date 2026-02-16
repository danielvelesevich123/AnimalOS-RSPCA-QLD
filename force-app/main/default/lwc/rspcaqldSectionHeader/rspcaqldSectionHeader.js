import {api, wire, LightningElement} from 'lwc';
import * as constants from 'c/constants';
import headerAction from '@salesforce/messageChannel/HeaderAction__c';
import {MessageContext, publish} from "lightning/messageService";

export default class RspcaqldSectionHeader extends LightningElement {
    @api quickLinksLabel;
    @api quickLinks;
    @api quickLinksString;
    @api actionLink;
    @api actionLinkLabel;
    @api actionLinkIcon;
    @api actionLinkClass;
    @api headerTextWidth;
    @api headerHeight;
    @api headerMaxWidth;
    @api imageHeight;
    @api imageBottomAlign = false;
    @api learnMoreCards;
    @api learnMoreCardsString;
    @api infoCards;
    @api infoCardsString;

    _header;
    _subheader;
    _description;

    @api isQuickLinksIconRight = false;
    @api isShapeImage = false;
    @api isSearchString = false;
    isPopupOpen = false;

    @api imageUrl;
    @api imageKey;
    imageContentURL = { data: [] };
    @api pawPrintLabel;

    @api isThankYouHeader = false;

    messageContext = { data: [] };
    closeDark = constants.closeDark;

    get thankYouName() {
        let cookieThankYou = this.getCookie('thankYouName');
        cookieThankYou = cookieThankYou ? decodeURI(cookieThankYou) : null;
        return cookieThankYou ? cookieThankYou : 'Friend';
    }

    @api
    set header(value) {
        this._header = value;
    }

    get header() {
        if (this.isThankYouHeader) {
            if (this._header.includes('{thankYouName}')) this._header = this._header.replaceAll('{thankYouName}', this.thankYouName);
        }
        return this._header;
    }

    @api
    set subheader(value) {
        this._subheader = value;
    }

    get subheader() {
        if (this.isThankYouHeader) {
            if (this._subheader.includes('{thankYouName}')) this._subheader = this._subheader.replaceAll('{thankYouName}', this.thankYouName);
        }
        return this._subheader;
    }

    @api
    set description(value) {
        this._description = value;
    }

    get description() {
        if (this.isThankYouHeader) {
            if (this._description.includes('{thankYouName}')) this._description = this._description.replaceAll('{thankYouName}', this.thankYouName);
        }
        return this._description;
    }

    get mainClass() {
        return 'section-header' + ((this.isLMCards || this.isInfoCards) ? ' with-cards' : '') + (this.isImage ? '' : ' without-image') + (this.isHidePawPrint ? ' without-paw' : '');
    }

    get image(){
        return this.imageContentURL.data ? this.imageContentURL.data : (this.imageUrl ? this.imageUrl : null);
    }
    get isImage() {return this.image ? true : false;}

    get pawPrint() {
        // return this.pawPrintLabel ? constants[this.pawPrintLabel.split(' ')[0].toLowerCase() + this.pawPrintLabel.split(' ')[1] + 'Paw'] : null;
        return this.pawPrintLabel ? constants.officialRSPCAPaw : null;
    }
    get pawPrintClass() {
        return 'paw-print' + (this.pawPrintLabel ? (this.pawPrintLabel == 'Official RSPCA Left' ? '' : ' paw-right') : null);
    }
    get isHidePawPrint() {return this.pawPrint ? false : true;}

    get headerRightColumnClass() {
        return 'section-header-right-column' + (this.pawPrint ? ' with-paw-print' : '') + (!this.pawPrint && !this.image ? ' empty-column' : '') + (this.imageBottomAlign && this.image ? ' bottom-align' : '');
    }

    get headerTextStyle() {
        return this.headerTextWidth ? 'width: ' + this.headerTextWidth + 'px; max-width:90vw;' : '';
    }
    get headerStyle() {
        return this.headerHeight ? 'height: ' + this.headerHeight + 'px' : '';
    }
    get headerElementsStyle() {
        return this.headerMaxWidth ? 'max-width: ' + this.headerMaxWidth + 'px' : '';
    }
    get imageStyle() {
        return this.imageHeight ? 'height: ' + this.imageHeight + 'px' : '';
    }

    get imageClass() {
        return 'man-img' + (this.isShapeImage ? ' shape' : '');
    }

    get isLinks() {return this.isQuickLinks || this.isActionLink ? true : false;}
    get isQuickLinks() {return this.qlinks && this.qlinks.length > 0 ? true : false;}
    get isActionLink() {return this.alink ? true : false;}

    get isQuickLinksLabel() {return this.quickLinksLabel ? true : false;}
    get qlinks() {
        if (this.quickLinks) {
            return this.quickLinks;
        } else if (this.quickLinksString) {
            let linksArray = JSON.parse(this.quickLinksString);
            let links = [];

            for (let i = 0; i < linksArray.length; i++) {
                let link = {label: linksArray[i][0], url: linksArray[i][1], icon: (linksArray[i][2] ? linksArray[i][2] : null), isIcon: (linksArray[i][2] ? true : false)}
                links.push(link);
            }
            return links;
        }
        return [];
    }

    get alink() {
        if (this.actionLink) {
            return this.actionLink;
        } else if (this.actionLinkLabel || this.actionLinkIcon) {
            return {label: this.actionLinkLabel, icon: this.actionLinkIcon, isIcon: (this.actionLinkIcon ? true : false), class: this.actionLinkClass};
        }
        return null;
    }

    get isLMCards() {return this.lmCards ? true : false;}
    get lmCards() {
        let cards = this.learnMoreCards ? this.learnMoreCards : (this.learnMoreCardsString ? JSON.parse(this.learnMoreCardsString) : null);
        if (cards) {return this.handleUpdateCards(cards);}
        return null;
    }

    get isInfoCards() {return this.iCards ? true : false;}
    get iCards() {
        let cards = this.infoCards ? this.infoCards : (this.infoCardsString ? JSON.parse(this.infoCardsString) : null);
        if (cards) {return this.handleUpdateCards(cards);}
        return null;
    }

    get isHeader() {return this.header ? true : false;}
    get isSubheader() {return this.subheader ? true : false;}
    get isDescription() {return this.description ? true : false;}

    get linkClass() {
        return this.isQuickLinksIconRight ? 'right-icon-link' : '';
    }

    get firstLink() {
        return this.qlinks && this.qlinks.length > 0 ? this.qlinks[0] : {};
    }

    get mobileQlinkBtn() {
        return 'green-btn quick-link-btn' + (this.qlinks.length > 1 ? '' : ' full-width');
    }
    get mobileQlinkPopupBtn() {
        return 'neutral-arrow-btn' + (this.qlinks.length > 1 ? '' : ' hide-arrow');
    }

    get linksPopupClass() {return this.isPopupOpen ? 'pop-up-quicklink pop-up-container active' : 'pop-up-quicklink pop-up-container';}

    get backdropClass() {return this.isSupportOpen ? 'backdrop open' : 'backdrop';}

    handleActionClick(evt) {
        publish(this.messageContext, headerAction, {class: this.alink.class});
        // this.dispatchEvent(new CustomEvent("actionclick"));
    }

    handlePopupOpen(evt) {
        this.isPopupOpen = true;
    }

    handlePopupClose(evt) {
        this.isPopupOpen = false;
    }

    handleButtonClick(evt) {
        let url = evt.detail.value;
        window.location.replace(url);
    }

    handleUpdateCards(cards) {
        let keyCount = 0;
        cards.map(item => {
            item.icon = item.icon;
            item.key = keyCount;
            keyCount++;
        });
        return cards;
    }

    getCookie(name) {
        var cookieString = "; " + document.cookie;
        var parts = cookieString.split("; " + name + "=");
        if (parts.length === 2) {
            return parts.pop().split(";").shift();
        }
        return null;
    }
}