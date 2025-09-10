import {api, LightningElement} from 'lwc';

export default class RspcaqldCounter extends LightningElement {
    @api label;
    @api minValue = 0;
    @api value = 0;
    @api withoutLabel = false;

    get mainClass() {
        return 'input-counter' + (this.withoutLabel ? ' without-label' : '');
    }

    handleMinus(evt) {
        if (this.value > this.minValue) this.value--;
        this.dispatchEvent(new CustomEvent("change", {detail: {value : this.value}}));
    }

    handlePlus(evt) {
        this.value++;
        this.dispatchEvent(new CustomEvent("change", {detail: {value : this.value}}));
    }
}