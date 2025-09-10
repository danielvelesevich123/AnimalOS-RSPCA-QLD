import {api} from 'lwc';
import BaseElement from 'c/verticBase';

export default class VerticCounter extends BaseElement {
    @api placeholder;
    @api required = false;
    @api disabled = false;
    @api label;
    @api variant;
    @api value;
    @api min = 0;
    @api max = 9999;

    handleValueChange(event) {
        this.value = event.target.value;
        this.triggerChangeEvent();
    }

    handleDecrease() {
        this.value = Math.max(this.min, this.value ? --this.value : this.min);
        this.triggerChangeEvent();
    }
    handleIncrease() {
        this.value = Math.min(this.max, this.value ? ++this.value : this.min + 1);
        this.triggerChangeEvent();
    }

    triggerChangeEvent() {
        this.dispatchEvent(new CustomEvent('change', {
            bubbles: false,
            composed: false,
            detail: {value: this.value}
        }));
    }
}