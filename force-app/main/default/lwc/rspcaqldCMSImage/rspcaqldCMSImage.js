import {LightningElement, wire, api} from 'lwc';
import getImage from '@salesforce/apex/ManagedContentService.getImageByContentKey';

export default class RspcaqldCmsImage extends LightningElement {
    @api className;
    @api imageKey;
    @wire(getImage, {contentKey: '$imageKey'}) url;
}