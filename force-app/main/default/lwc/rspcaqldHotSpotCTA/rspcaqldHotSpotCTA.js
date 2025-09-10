import {api, LightningElement} from 'lwc';

export default class RspcaqldHotSpotCta extends LightningElement {
    @api imageUrl;
    @api imageKey;
    @api header;
    @api linkUrl;
    @api linkLabel;
}