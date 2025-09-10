import {api, LightningElement} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldHotSpotEventDetails extends LightningElement {
    calendarWhite = constants.calendarWhite;
    clockWhite = constants.clockWhite;
    locationWhite = constants.locationWhite;

    @api header;
    @api date;
    // @api startTime;
    // @api endTime;
    @api addressOne;
    @api addressTwo;
    @api otherAddress;
    @api time;
    @api link;

    get isLink() {return this.link ? true : false;}
    get isTime() {return this.time ? true : false;}
    get isAddressOne() {return this.addressOne ? true : false;}
    get isAddressTwo() {return this.addressTwo ? true : false;}

    // get time() {
    //     return `${this.startTime} - ${this.endTime}`;
    // }
}