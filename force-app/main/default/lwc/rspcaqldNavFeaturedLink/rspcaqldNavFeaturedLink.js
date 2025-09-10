import {api, LightningElement} from 'lwc';
import {NavigationMixin} from "lightning/navigation";

export default class RspcaqldNavFeaturedLink extends NavigationMixin(LightningElement) {
    @api vertical = false;
    @api header;
    @api subheader;
    @api imageUrl;
    @api link;

    get backgroundStyle() {
        return this.imageUrl ? 'background: lightgray 50% / cover url(' + this.imageUrl.replace(/\s/g, "%20") + ');' : '';
    }
}