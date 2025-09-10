import {api, LightningElement} from 'lwc';
import {NavigationMixin} from "lightning/navigation";

export default class RspcaqldCard extends NavigationMixin(LightningElement) {
    @api imageUrl;
    @api header;
    @api description;
    @api link;

    get linkTarget() {
        return this.link && this.link.startsWith('http') ? '_blank' : '_self';
    }
}