import {api, LightningElement} from 'lwc';
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

    get mainClass() {
        return 'cards-article' + (this.isLarge ? ' large' : '');
    }

    get icon() {
        return this.isWhite ? constants.infoBlack : constants.infoWhite;
    }
}