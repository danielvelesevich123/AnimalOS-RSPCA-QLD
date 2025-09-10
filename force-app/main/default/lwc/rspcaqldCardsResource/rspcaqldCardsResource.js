import {api, LightningElement} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldCardsResource extends LightningElement {
    @api category;
    @api tag;
    @api imageUrl;
    @api header;
    @api description;

    locationDark = constants.locationDark;
}