import {api, LightningElement, wire} from 'lwc';

export default class RspcaqldSectionPartners extends LightningElement {
    @api customClass;
    @api cardSize = 'Big';
    @api header;
    @api linkLabel;
    @api linkUrl;
    @api partnerKeys;
    partners = { data: [] };
    @api isTitle = false;
    @api isCategory = false;
    @api isWhiteCards = false;
    @api isWhiteBackground = false;
    @api isBlueHeader = false;
    @api isCenterHeader = false;
    @api isDisplayPopup = false;
    @api isDisableRedirect = false;

    get mainClass() {
        return 'page-partners medium-width' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get templateStyle() {
        return this.isWhiteBackground ? 'background: #FFF' : '';
    }

    get isHeader() {return this.header ? true : false;}
    get isLink() {return this.linkLabel ? true : false;}

    get headerClass() {
        return (this.isBlueHeader ? 'blue ' : '') + (this.isCenterHeader ? 'center' : '');
    }
}