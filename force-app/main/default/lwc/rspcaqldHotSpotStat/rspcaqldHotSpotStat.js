import {api, LightningElement} from 'lwc';

export default class RspcaqldHotSpotStat extends LightningElement {
    @api statLabel;
    @api statValue;
    @api linkLabel;
    @api linkUrl;
}