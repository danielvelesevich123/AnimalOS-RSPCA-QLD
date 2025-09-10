import {api, LightningElement} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldCardsEvent extends LightningElement {
    @api imageUrl;
    @api time;
    @api header;
    @api address;
    @api eventId;
    calendarDark = constants.calendarDark;

    get link() {return '../../../../events/details/' + this.eventId;}
}