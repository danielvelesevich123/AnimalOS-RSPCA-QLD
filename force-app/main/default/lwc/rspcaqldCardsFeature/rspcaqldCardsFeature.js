import {api, LightningElement} from 'lwc';
import {NavigationMixin} from "lightning/navigation";


export default class RspcaqldCardsFeature extends NavigationMixin(LightningElement) {
    @api iconName;
    iconURL = { data: null };
    @api header;
    @api description;
    @api withBackground = false;
    @api link;

    get featureClass() {
        return 'cards-feature' + (this.withBackground ? ' with-background' : '') + (this.link ? ' clickable' : '');
    }

    handleClick(evt) {
        if (this.link) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.link
                },
            });
        }
    }
}