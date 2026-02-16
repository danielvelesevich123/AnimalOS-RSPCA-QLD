import {api, LightningElement} from 'lwc';

export default class RspcaqldCardsInfoStep extends LightningElement {
    @api iconName;
    iconURL = { data: null };
    @api header;
    @api description;
    @api subdescription;

    get isSubdescription() {
        return this.subdescription ? true : false;
    }
}