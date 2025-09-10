import {
    api,
    LightningElement
} from 'lwc';

export default class RspcaqldCheckbox extends LightningElement {
    @api label;
    @api labelLeft = false;
    @api additionalLabel = false;
    @api checked = false;
    @api disabled = false;
    @api helptext;
    @api required = false;
    @api vertical = false;
    @api error = false;
    @api errorMessage;

    get checkboxClass() {
        return 'input-checkbox' + (this.vertical ? ' vertical' : '') + (this.error ? ' error' : '') + (this.errorMessage ? '' : ' without-error-message') + (this.disabled ? ' disabled' : '');
    }
    get iconName() {
        return (this.checked ? 'check_box' : 'check_box_outline_blank');
    }

    get iconClass() {
        return 'material-symbols-outlined' + (this.checked ? ' checked' : '') + (this.helptext ? ' helptext-label' : '');
    }

    get labelRight() {
        return !this.labelLeft;
    }

    get isHelptext() {
        return this.helptext ? true : false;
    }

    get isAdditionalLabel() {
        return this.additionalLabel ? true : false;
    }

    handleToggleClick(evt) {
        this.checked = ! this.checked;
        this.dispatchEvent(new CustomEvent("change", {detail: {value : this.checked}}));
    }
}