import getImage from '@salesforce/apex/ManagedContentService.getImageByContentKey';
import {api, wire, LightningElement} from 'lwc';

export default class RspcaqldCardsInfoStep extends LightningElement {
    @api iconName;
    @wire(getImage, {contentKey: '$iconName'}) iconURL;
    @api header;
    @api description;
    @api subdescription;

    get isSubdescription() {
        return this.subdescription ? true : false;
    }
}