import getImage from '@salesforce/apex/ManagedContentService.getImageByContentKey';
import {api, wire, LightningElement} from 'lwc';


export default class RspcaqldCardsService extends LightningElement {
    @api iconName;
    @wire(getImage, {contentKey: '$iconName'}) iconURL;
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