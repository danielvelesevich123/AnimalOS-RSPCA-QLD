import {LightningElement, api} from 'lwc';
import timezone from '@salesforce/i18n/timezone'

export default class VerticInput extends LightningElement {

    connectedCallback() {
        if (this.type === 'BOOLEAN' && typeof this.value === 'string') {
            this.value = this.value === 'true';
        }
        if (!this.guid) {
            this.guid = crypto.randomUUID();
        }
    }

    @api guid;
    @api record;
    @api fieldName;
    @api type;
    @api label;
    @api required = false;
    @api labelHidden = false;
    @api value;
    @api helpText;
    @api cssClass = this.labelHidden ? 'label-hidden' : '';
    @api placeholder;
    @api readOnly = false;
    @api fractionalDigits = 0;
    @api disabled = false;
    @api allowNewRecords = false;
    @api overrideNewEvent = false;
    @api wordBreak = false;
    @api sObject;
    @api multiSelect = false;
    @api searchField = 'Name';
    @api subtitleField;
    @api showSubtitleLabel = false;
    @api subtitleSeparator;
    @api filter = '';
    @api iconTag;
    @api options = [];
    @api pattern;
    @api formatPattern;
    @api formatGroups;
    @api messageWhenPatternMismatch;
    @api picklistType;

    trueFalseOptions = [{
        label: 'TRUE', value: 'TRUE'
    }, {
        label: 'FALSE', value: 'FALSE'
    }]

    handleNumberFieldChange(event) {
        this.value = parseFloat(event.target.value);
        this.dispatchEvent(new CustomEvent('change', {
            bubbles: false,
            composed: false,
            detail: {
                value: this.value
            }
        }));
    }

    handleFieldChange(event) {
        let isCheckbox = event.target.type === 'toggle' || event.target.type === 'checkbox' || event.target.type === 'checkbox-button';
        this.value = isCheckbox ? event.target.checked : event.target?.selectedValues || event.target?.value || event.target?.selected || event.detail?.value;
        if (this.isBOOLEAN && event.target.type === 'button') {
            this.value = this.value === 'TRUE';
        }
        if (this.value && this.formatPattern && this.formatGroups) {
            let newValue = this.value.replace(new RegExp(this.formatPattern, 'g'), this.formatGroups);
            if (this.value !== newValue) {
                this.value = newValue;
            }
        }
        this.dispatchEvent(new CustomEvent('change', {
            bubbles: false,
            composed: false,
            detail: {
                value: this.value
            }
        }));
    }

    handleAddNewClick(event) {
        this.dispatchEvent(new CustomEvent('addnew', {
            bubbles: false,
            composed: false
        }));
    }

    handleSearchClick(event) {
        if (this.disabled) return;
        this.dispatchEvent(new CustomEvent('searchiconclick', {
            bubbles: false,
            composed: false
        }));
    }

    get isTEXTAREA() {
        return this.type === 'TEXTAREA';
    }

    get isPHONE() {
        return this.type === 'PHONE';
    }

    get isEMAIL() {
        return this.type === 'EMAIL';
    }

    get isURL() {
        return this.type === 'URL';
    }

    get isTIME() {
        return this.type === 'TIME';
    }

    get isPICKLIST() {
        return this.type === 'PICKLIST';
    }

    get isMULTIPICKLIST() {
        return this.type === 'MULTIPICKLIST';
    }

    get isBOOLEAN() {
        return this.type === 'BOOLEAN';
    }

    get isINTEGER() {
        return this.type === 'INTEGER';
    }

    get isDOUBLE() {
        return this.type === 'DOUBLE';
    }

    get isPERCENT() {
        return this.type === 'PERCENT';
    }

    get isCURRENCY() {
        return this.type === 'CURRENCY';
    }

    get isDATE() {
        return this.type === 'DATE';
    }

    get isDATETIME() {
        return this.type === 'DATETIME';
    }

    get isSTRING() {
        return this.type === 'STRING';
    }

    get isREFERENCE() {
        return this.type === 'REFERENCE' || this.type === 'ID';
    }

    get isFieldNameRecordTypeId() {
        return this.fieldName === 'RecordTypeId';
    }

    get variant() {
        return this.labelHidden ? 'label-hidden' : '';
    }

    get isClickable() {
        return !this.isFieldNameRecordTypeId;
    }

    get readonlyContainerStyle() {
        return this.wordBreak === true ? 'word-break: break-word; white-space: break-spaces;' : ''
    }

    get placeholderFormula() {
        return this.placeholder || this.isMULTIPICKLIST ? 'Select Options' : this.isPICKLIST ? 'Select an Option' : this.isREFERENCE ? 'Start typing to search for a record' : '';
    }

    get booleanValueFormatted() {
        return this.value === true ? 'TRUE' : 'FALSE';
    }

    get listValueFormatted() {
        return (this.value || '').split(';');
    }

    get decimalStep() {
        return (this.fractionalDigits > 0 ? '0.' + ''.padEnd(this.fractionalDigits - 1, '0') : '') + '1';
    }

    get isRadioGroup() {
        return this.picklistType === 'radioGroup';
    }
}