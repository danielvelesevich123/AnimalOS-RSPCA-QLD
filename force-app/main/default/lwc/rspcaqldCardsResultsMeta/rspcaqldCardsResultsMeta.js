import {api, LightningElement} from 'lwc';

export default class RspcaqldCardsResultsMeta extends LightningElement {
    @api viewResult;
    @api allResult;
    @api orderOptions;
    @api orderValue;
    @api orderDirection;

    handleChange(evt) {
        this.orderValue = evt.detail.value;
        this.dispatchEvent(new CustomEvent("orderchange", {detail: {value : this.orderValue}}));
    }

    handleChangeOrder(evt) {
        this.orderDirection = evt.detail.value;
        this.dispatchEvent(new CustomEvent("orderdirectionchange", {detail: {value : this.orderDirection}}));
    }
}