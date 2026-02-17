import {api, LightningElement} from 'lwc';

export default class AosErrorMessages extends LightningElement {
    @api title = 'Errors:';
    @api errors;
}