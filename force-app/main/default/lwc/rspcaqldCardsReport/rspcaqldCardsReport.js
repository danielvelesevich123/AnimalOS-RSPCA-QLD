import {api, LightningElement} from 'lwc';

export default class RspcaqldCardsReport extends LightningElement {
    @api iconName;
    @api iconUrl;
    @api header;
    @api description;
    @api linkLabel;
    @api linkUrl;
    @api type = 'information';
    @api active = false;
    @api customColor;

    get reportClass() {
        return 'cards-report ' + (this.type == 'information' ? 'information' : 'urgent') + (this.active ? ' active' : '');
    }

    get reportStyle() {
        return this.customColor ? 'border-color:' + this.customColor + ' !important;' : '';
    }

    get iconStyle() {
        return this.customColor ? 'background-color:' + this.customColor + ';' : '';
    }

    get telLink() {
        return this.linkUrl ? 'tel:' + this.linkUrl : '#';
    }

    get isUrgent() {
        return this.type == 'urgent' ? true : false;
    }

    get isIconName() {
        return this.iconName ? true : false;
    }

    get isIconUrl() {
        return this.iconUrl ? true : false;
    }

    get uLinkUrl() {
        return this.linkUrl && !this.linkUrl.startsWith('/') && !this.linkUrl.startsWith('https') ? '../' + this.linkUrl : this.linkUrl;
    }

    handleClick(evt) {
        this.active = true;
        if (this.active) {
            this.dispatchEvent(new CustomEvent("selectreport", {
                detail: {
                    type : this.type
                }
            }));
        }
    }
}