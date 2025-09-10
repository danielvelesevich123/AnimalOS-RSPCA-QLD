import {api, LightningElement} from 'lwc';
import {NavigationMixin} from "lightning/navigation";

export default class RspcaqldCardsTeam extends NavigationMixin(LightningElement) {
    @api imageUrl;
    @api header;
    @api position;
    @api link;
}