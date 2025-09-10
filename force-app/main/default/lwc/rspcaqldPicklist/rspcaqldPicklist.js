import {
    api,
    LightningElement
} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldPicklist extends LightningElement {
    @api label;
    @api placeholder;
    @api helptext;
    @api valueArray = [];
    @api hasError = false;
    @api disabled = false;
    @api readOnly = false;
    @api checked = false;
    @api required = false;
    @api isOpen = false;
    @api hideSelected = false;
    @api multiselect = false;
    @api multiselectClick = false;
    @api multiselectLimit;
    @api orderDirection = 'asc';
    @api errorMessage = constants.requiredText;
    @api disableFilter = {};
    optionValues = [];
    privateOptions;
    privateValue = '';

    @api
    get value() {
        return this.privateValue;
    }

    set value(item) {
        this.privateValue = item;
        if (this.multiselect) {
            if (this.privateValue && this.valueArray.length > 0) {
                let values = this.privateValue.split('; ');
                let _valueArray = [];
                for (let i = 0; i < values.length; i++) {
                    if (this.optionValues.includes(values[i])) _valueArray.push(values[i]);
                }
                this.valueArray = _valueArray;
                this.privateValue = this.valueArray.join('; ');
            } else {
                this.valueArray = [];
            }

            if (this.valueArray.length == 0) this.checked = false;
        }
    }

    @api
    set options(items) {
        if (items) {
            this.privateOptions = JSON.parse(JSON.stringify(items));
            this.privateOptions.map(item => {
                this.optionValues.push(item.value);
            });
        }
    }

    get options() {
        this.privateOptions.map(item => {
            item.class = '';
            if (this.checked) {
                item.visible = true;
                if ((!this.multiselect && item.value === this.value) || (this.multiselect && this.valueArray.includes(item.value))) {
                    item.checked = true;
                } else {
                    item.checked = false;
                    if (this.multiselect && this.multiselectLimit != null && this.valueArray.length >= Number(this.multiselectLimit)) {
                        item.class = 'disabled';
                    }
                }

                if (this.disableFilter && this.valueArray.length > 0) {
                    for (let i = 0; i < this.valueArray.length; i++) {
                        for (let filter in this.disableFilter) {
                            if (this.valueArray[i].includes(filter)) {
                                for (let j = 0; j < this.disableFilter[filter].length; j++) {
                                    if (item.value.includes(this.disableFilter[filter][j])) {
                                        item.class = 'disabled';
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }

                item.hideSelected = this.hideSelected && item.checked ? false : true;
            } else {
                item.hideSelected = true;
                item.checked = false;
                if (this.value) {
                    item.visible = item.value.toLowerCase().includes(this.value.toLowerCase()) ||
                                   item.value.toLowerCase().replace(/é/g, 'e').includes(this.value.toLowerCase());
                } else {
                    item.visible = true;
                }
            }
        });
        return this.privateOptions;
    }

    get iconClass() {
        let chevronUp = (this.hideSelected ? this.orderDirection == 'desc' : this.isOpen);
        return (chevronUp ? 'utility:chevronup' : 'utility:chevrondown');
    }

    get tabIndex() {
        return this.isOpen ? -1 : 0;
    }

    get picklistClass() {
        return 'input-dropdown slds-form-element' + (this.hasError ? ' slds-has-error' : '') + (this.isOpen ? ' dropdown-open' : '') +
            (this.hideSelected ? ' hideselected' : '');
    }

    get isHelptext() {
        return this.helptext ? true : false;
    }

    @api
    clear() {
        this.value = null;
        this.checked = false;
    }

    connectedCallback() {
        if (this.multiselect) {
            if (this.value) {
                this.checked = true;
            }
        } else {
            if (this.privateOptions) {
                for (var i = 0; i < this.privateOptions.length; i++) {
                    if (this.privateOptions[i].value === this.value) {
                        this.checked = true;
                        break;
                    }
                }
            }
        }
    }

    renderedCallback() {
        this.template.querySelector('.input-dropdown').addEventListener('focusout',
            this.handleFocusOut);
        if (this.hideSelected) {
            this.template.querySelector('.slds-input').style.width = this.value ? (this.value.replace(/\s/g, '').length*7 + (this.value.match(/ /g) || []).length*4 + (this.value.match(/m/g) || []).length*4 + (this.value.match(/w/g) || []).length*4 + 16 - (this.value.match(/t/g) || []).length*2 - (this.value.match(/f/g) || []).length*2) + 'px' : '16px';
        }
    }

    handleInputClick(evt) {
        this.isOpen = true;
        this.template.querySelector('.slds-input').focus();
    }

    handleIconClick(evt) {
        if (this.hideSelected) {
            this.orderDirection = this.orderDirection == 'asc' ? 'desc' : 'asc';
            this.dispatchEvent(new CustomEvent("changeorder", {detail: {value : this.orderDirection}}));
        } else {
            if (!this.isOpen) setTimeout(() => this.handleInputClick(), 150);
        }
    }

    handleInputChange(evt) {
        this.value = evt.target.value;
        this.dispatchEvent(new CustomEvent("change", {detail: {value : this.value}}));
    }

    handleFocusOut = (evt) => {
        setTimeout(() => this.handleClose(), 150);
    }

    handleClose(evt) {
        if (this.multiselectClick) {
            this.multiselectClick = false;
            this.template.querySelector('.slds-input').focus();
        } else {
            this.isOpen = false;
            if (!this.checked || (!this.multiselect && !this.optionValues.includes(this.value))) {
                this.value = null;
                this.dispatchEvent(new CustomEvent("change", {detail: {value : this.value}}));
            }
            this.template.querySelector('.input-dropdown').blur();
        }
    }

    handleValueClick(evt) {
        if (this.multiselect) {
            if (this.valueArray.includes(evt.currentTarget.dataset.item)) {
                var index = this.valueArray.indexOf(evt.currentTarget.dataset.item);
                this.valueArray.splice(index, 1);
            } else {
                this.valueArray.push(evt.currentTarget.dataset.item);
            }

            if (this.valueArray.length > 0) {
                this.value = this.valueArray.join('; ');
                this.checked = true;
            } else {
                this.value = null;
                this.checked = false;
            }
            this.multiselectClick = true;
        } else {
            this.value = evt.currentTarget.dataset.item;
            this.checked = true;
        }
        if (this.hideSelected) this.orderDirection = 'asc';
        this.dispatchEvent(new CustomEvent("change", {detail: {value : this.value}}));
    }
}