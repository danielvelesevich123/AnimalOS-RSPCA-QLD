import {api, track} from 'lwc';
import BaseElement from 'c/verticBase';

export default class VerticMultiSelect extends BaseElement {
    @api placeholder = 'Select an Option';
    @api required = false;
    @api disabled = false;
    @api options;
    @api label;
    @api labelHidden;
    @api value;
    @api selectedValuesList;
    unselectedOptions;

    // @track dynamicPlaceholder;

    connectedCallback() {
        this.selectedValuesList = this.value ? this.value.split(';'): [];
        this.alignOptions();
    }

    @api
    validate() {
        this.clearErrors();
        let hasNoError = this.required === true && this.value || this.required !== true || this.required === undefined;
        this.template.querySelector('c-vertic-select').clearErrors();
        if (!hasNoError) {
            this.template.querySelector('c-vertic-select').showErrors(['Complete this field.']);
        }
        return hasNoError;
    }

    get getPlaceholder() {
        return this.selectedValuesList.length > 0 ? (this.selectedValuesList.length + ' value(s) selected') : this.placeholder;
    }

    handleFieldChange(event) {
        this.selectedValuesList = this.value ? this.value.split(';') : [];
        let newValue = event.target.value;
        if (this.selectedValuesList.indexOf(newValue) >= 0) {
            this.resetInput(event);
            return;
        }
        this.selectedValuesList.push(newValue);
        this.value = this.selectedValuesList.join(';');
        this.resetInput(event);
        this.alignOptions();
        this.validate();
        this.dispatchEvent(new CustomEvent('change', {
            bubbles: false,
            composed: false,
            detail: {
                value: this.value
            }
        }));
    }

    handleRemove(event) {
        this.selectedValuesList = this.selectedValuesList.filter(data => data !== event.target.label);
        this.value = this.selectedValuesList.join(';');
        this.resetInput();
        this.alignOptions();
        this.dispatchEvent(new CustomEvent('change', {
            bubbles: false,
            composed: false,
            detail: {
                value: this.value
            }
        }));
    }

    @api
    resetInput(event) {
        // this.dynamicPlaceholder = this.selectedValuesList.length > 0 ? (this.selectedValuesList.length + ' value(s) selected') : undefined;
        // if (event) {
        //     event.target.value = '';
        // } else {
            let select = this.template.querySelector('c-vertic-select');
            select.setValue(undefined);
        // }
    }

    alignOptions() {
        this.unselectedOptions = this.options.filter(option => (this.selectedValuesList || []).indexOf(option.value) < 0);
    }
}