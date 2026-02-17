import {api, LightningElement} from 'lwc';

export default class AosSpinner extends LightningElement {
    @api label;
    @api isBusy;
    @api size = 'medium';
    @api variant = 'brand';
}