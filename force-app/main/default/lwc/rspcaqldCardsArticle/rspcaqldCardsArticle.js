import getImage from '@salesforce/apex/ManagedContentService.getImageByContentKey';
import {api, LightningElement, wire} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldCardsArticle extends LightningElement {
    @api category;
    @api isCategory = false;
    @api isLarge = false;
    @api isWhite = false;
    @api tag;
    @api imageId;
    @api imageUrl;
    @api header;
    @api description;
    @api link;

    @wire(getImage, {recordId: '$imageId'})
    wiredImage({ error, data }) {
        if (data) this.imageUrl = data;
    };

    get mainClass() {
        return 'cards-article' + (this.isLarge ? ' large' : '');
    }

    get icon() {
        return this.isWhite ? constants.infoBlack : constants.infoWhite;
    }
}