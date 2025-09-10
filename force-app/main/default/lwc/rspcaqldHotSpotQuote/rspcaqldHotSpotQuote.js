import {api, LightningElement} from 'lwc';

export default class RspcaqldHotSpotQuote extends LightningElement {
    @api iconKey;
    @api quote;
    @api signature;
    @api linkUrl;
    @api linkLabel;
}