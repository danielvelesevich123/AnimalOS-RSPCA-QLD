import {api, LightningElement, wire} from 'lwc';

export default class RspcaqldSectionNextPages extends LightningElement {
    @api firstHeader;
    @api firstLinkLabel;
    @api firstLinkUrl;
    @api secondHeader;
    @api secondLinkLabel;
    @api secondLinkUrl;
    @api customClass;
    @api disableTopMargin = false;
    @api backgroundColor;
    @api imageUrl;
    @api imageKey;
    imageContentURL = { data: [] };
    get mainClass() {
        return 'section-next-pages' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '') +
            (this.disableTopMargin ? ' disable-margin' : '');
    }

    get backgroundTemplateStyle() {
        return this.backgroundColor ? 'background:' + this.backgroundColor : '';
    }

    get backgroundStyle() {
        let image = this.imageContentURL.data ? this.imageContentURL.data : (this.imageUrl ? this.imageUrl : null);
        return 'background: lightgray 50% / cover url(' + image + ');';
    }
}