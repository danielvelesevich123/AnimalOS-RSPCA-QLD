import {api, LightningElement} from 'lwc';

export default class LocationNearby extends LightningElement {
    @api locationNearby = {};
    @api view;
}