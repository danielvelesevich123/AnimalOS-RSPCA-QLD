import {api} from 'lwc';
import BaseElement from 'c/verticBase';

export default class VerticCounter extends BaseElement {
    @api placeholder;
    @api required = false;
    @api disabled = false;
    @api label;
    @api helpText;
    @api variant;
    @api value;
    @api step = 1;
    @api min = 0;
    @api max = 9999;

    connectedCallback() {
        super.connectedCallback();

        this.value = parseFloat(this.value);
    }

    handleValueChange(event) {
        let stepFloat = this.stepFloat;
        this.value = Math.round(event.target.value / stepFloat) * stepFloat;
        let strValue = this.value + '';
        event.target.value = strValue + (strValue.indexOf('.') < 0 && event.target.value.indexOf('.') >= 0 ? '.' : '');
        this.triggerChangeEvent();
    }

    handleDecrease() {
        let newValue = parseFloat(this.value) - this.stepFloat;
        this.value = Math.max(this.minFloat, this.value ? newValue : this.minFloat).toFixed(this.scale);
        this.triggerChangeEvent();
    }
    handleIncrease() {
        let newValue = parseFloat(this.value) + this.stepFloat;
        this.value = Math.min(this.maxFloat, this.value ? newValue : this.maxFloat).toFixed(this.scale);
        this.triggerChangeEvent();
    }

    triggerChangeEvent() {
        this.dispatchEvent(new CustomEvent('change', {
            bubbles: false,
            composed: false,
            detail: {value: this.value}
        }));
    }

    get stepFloat() {
        return parseFloat(this.step);
    }
    get maxFloat() {
        return parseFloat(this.max);
    }
    get minFloat() {
        return parseFloat(this.min);
    }

    get scale() {
        return this.step && this.step.indexOf('.') >= 0 ? this.step.split('.')[1].length : 0;
    }
}