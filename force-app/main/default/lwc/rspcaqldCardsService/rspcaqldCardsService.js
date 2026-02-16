import {api, LightningElement} from 'lwc';


export default class RspcaqldCardsService extends LightningElement {
    @api iconName;
    iconURL = { data: null };
    @api header;
    @api description;
    @api linkUrl;
    @api linkLabel;

    get mainClass() {
        return 'cards-service' + (this.isLink ? ' with-link' : '');
    }

    get isLink() {
        return this.linkLabel ? true : false;
    }
}