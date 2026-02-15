import {api, LightningElement, wire} from "lwc";
import {getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi';

export default class VerticSelect extends LightningElement {
    @api required;
    @api label;

    @api noneLabel;
    @api selectOptions;
    @api exclude;
    @api autocomplete;
    @api variant;

    recordTypeOptions = [];
    fieldOptions = [];
    controllerValues;
    options;
    multiPicklist = false;
    objectInitialized = false;
    picklistInitialized = false;

    @api disabled = false;
    dependsOnValueMissing = false;

    get computedDisabled() {
        return this.disabled || this.dependsOnValueMissing;
    }

    _placeholder;
    @api
    get placeholder() {
        return this._placeholder || 'Select an Option...';
    }

    set placeholder(value) {
        this._placeholder = value;
    }

    _value;
    @api
    get value() {
        return this._value;
    }

    set value(val) {
        this._value = val;
    }

    _dependsOn;
    @api
    get dependsOn() {
        return this._dependsOn;
    }

    set dependsOn(val) {
        this._dependsOn = val;
        this.setupOptions();
    }

    _sobjectType;
    @api
    get sobjectType() {
        return this._sobjectType;
    }

    set sobjectType(value) {
        this._sobjectType = value;
    }

    _sobjectField;
    @api
    get sobjectField() {
        return this._sobjectField === 'RecordTypeId' ? undefined : this.sobjectType + '.' + this._sobjectField;
    }

    set sobjectField(value) {
        this._sobjectField = value;
    }

    @api
    get recordTypeId() {
        return this._recordTypeId || '012000000000000AAA';
    }

    _recordTypeId;
    set recordTypeId(value) {
        this._recordTypeId = value;
    }

    @api
    validate() {
        return this.template.querySelector('c-combobox').checkValidity();
    }

    @wire(getObjectInfo, {objectApiName: '$sobjectType'})
    handleObjectInfo({error, data}) {
        if (data) {
            if (data.fields[this._sobjectField]?.dataType === 'MultiPicklist') {
                this.multiPicklist = true;
            }

            const recordTypeInfos = data.recordTypeInfos;
            if (!recordTypeInfos) {
                return;
            }

            const options = [];
            for (const recordTypeId in recordTypeInfos) {
                const recordType = recordTypeInfos[recordTypeId];
                if (recordType.available && !recordType.master) {
                    options.push({
                        value: recordTypeId,
                        label: recordType.name
                    });
                }
            }
            this.recordTypeOptions = options;
            this.setupOptions();
            this.objectInitialized = true;
        } else if (error) {
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: '$sobjectField'
    })
    handlePicklistValues({error, data}) {
        if (data && data.values) {
            this.fieldOptions = data.values;
            this.controllerValues = data.controllerValues && Object.keys(data.controllerValues).length > 0 ? data.controllerValues : null;
            this.setupOptions();

            setTimeout(() => {
                this.picklistInitialized = true;
            });
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    setupOptions() {
        //init record type options
        if (this.sobjectType && this._sobjectField === 'RecordTypeId') {
            this.options = [...this.recordTypeOptions];
            this.picklistInitialized = true;
            return;
        }

        let options = [];
        this.dependsOnValueMissing = false;

        if (this.selectOptions && this.selectOptions.length > 0) {
            options = [...this.selectOptions];
        } else if (this.fieldOptions && this.fieldOptions.length > 0) {
            options = [...this.fieldOptions];
            // Apply dependency and disabled input if no controller is empty
            if (this.controllerValues) {
                if (this.dependsOn) {
                    const controllingValue = this.controllerValues[this.dependsOn];

                    if (controllingValue) {
                        options = options.filter(option => option.validFor && option.validFor.length > 0 && option.validFor.includes(controllingValue));
                    }
                } else {
                    this.dependsOnValueMissing = true;
                }
            }
        }

        // Add none label option if specified
        if (this.noneLabel && options.length > 0) {
            options = [
                {label: this.noneLabel, value: ''},
                ...options
            ];
        }

        // Exclude specified values
        const excludedValues = this.excludedValues;

        if (excludedValues.length > 0) {
            options = options.filter(option => !excludedValues.includes(option.value));
        }

        // Validate current value
        if (this.dependsOnValueMissing === true) {
            this.value = '';
        } else if(this.options && this.options.length > 0){
            if (this.multiPicklist === true) {
                //value is semi-colon separated for multi-picklist
                const currentValues = this.value ? this.value.split(';') : [];
                const validValues = options.map(option => option.value);
                const filteredValues = currentValues.filter(val => validValues.includes(val));
                this.value = filteredValues.join(';');
            } else {
                if (!options.some(option => option.value === this.value)) {
                    this.value = '';
                }
            }
        }

        // Set the final options
        this.options = [...options];
    }

    handleChange(event) {
        this.value = event.detail.value;
        // Dispatch change event
        const changeEvent = new CustomEvent('change', {
            bubbles: false,
            composed: false,
            detail: {value: this.value}
        });
        this.dispatchEvent(changeEvent);
    }

    get excludedValues() {
        if (!this.exclude) {
            return [];
        }
        return this.exclude.split(',').map(val => val.trim()).filter(val => val !== '');
    }

    get computedVariant() {
        return this.variant ? this.variant : (this.label !== undefined && this.label !== null && this.label !== '' ? 'standard' : 'label-hidden');
    }

    get loading() {
        return this.picklistInitialized === false || this.objectInitialized === false;
    }
}