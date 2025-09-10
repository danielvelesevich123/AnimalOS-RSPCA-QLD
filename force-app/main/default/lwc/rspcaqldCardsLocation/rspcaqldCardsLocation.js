import {api, LightningElement} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import * as constants from 'c/constants';

export default class RspcaqldCardsLocation extends NavigationMixin(LightningElement) {
    @api imageUrl;
    @api locationTypes;
    @api isPetbarn = false;
    @api categories;
    @api header;
    @api address;
    @api phone;
    @api link;
    locationDark = constants.locationDark;

    get phoneLink() {return this.phone ? 'tel:' + this.phone : '#';}

    get imageClass() {return 'cards-location-image' + (this.isPetbarn ? ' petbarn' : '');}
}