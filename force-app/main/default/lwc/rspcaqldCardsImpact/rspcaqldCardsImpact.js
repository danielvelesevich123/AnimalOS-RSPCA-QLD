import {api, LightningElement} from 'lwc';
import {NavigationMixin} from "lightning/navigation";

export default class RspcaqldCardsImpact extends NavigationMixin(LightningElement) {
    @api imageUrl;
    @api header;
    @api description;
    @api link;

    handleClick(evt) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.link
            },
        });
    }
}