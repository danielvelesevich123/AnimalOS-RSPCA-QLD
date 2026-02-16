import {LightningElement, api} from 'lwc';

export default class RspcaqldCmsImage extends LightningElement {
    @api className;
    @api imageKey;
    url = { data: null };
}