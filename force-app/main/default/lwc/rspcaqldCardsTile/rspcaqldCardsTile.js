import {api, LightningElement} from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import * as constants from 'c/constants';

export default class RspcaqldCardsTile extends NavigationMixin(LightningElement) {
    @api address;
    @api title;
    @api link;
    @api displayIcon = false;
    locationIcon = constants.locationDark;

    get isLocation() {
        return this.address ? true : false;
    }

    handleClick(evt) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.link
            },
        });
    }
}