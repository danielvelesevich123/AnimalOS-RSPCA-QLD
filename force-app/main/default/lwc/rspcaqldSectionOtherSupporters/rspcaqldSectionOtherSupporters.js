import {api, LightningElement} from 'lwc';

export default class RspcaqldSectionOtherSupporters extends LightningElement {
    @api customClass;
    @api header;
    @api supportersString;
    @api otherSupporters;

    get mainClass() {
        return 'page-partners medium-width' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get supporters() {
        if (this.otherSupporters) {
            return this.otherSupporters;
        } else if (this.supportersString) {
            return JSON.parse(this.supportersString);
        }
        return null;
    }
}