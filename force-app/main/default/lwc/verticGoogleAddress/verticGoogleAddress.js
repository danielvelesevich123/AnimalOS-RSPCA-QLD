import {BaseElement, showToast} from 'c/verticBase';
import {api} from "lwc";

export default class VerticGoogleAddress extends BaseElement {
    @api label;
    @api placeholder = 'Search for an address...';
    @api disabled;
    @api required;
    @api unit;
    @api street;
    @api city;
    @api state;
    @api postCode;
    @api country;
    @api shortNameFor;
    @api uppercaseFor;
    @api searchDebounce = 500;
    @api showAdditionalFields;
    @api addressDisabled;
    @api searchOnly = false;
    @api hideUnit;
    selectedOption;
    filteredOptions = [];
    @api streetOnly;

    connectedCallback() {
        this.unit = null;
        this.streetOnly = null;

        if (this.street != null) {
            if (this.hideUnit) {
                this.streetOnly = this.street;
            } else {
                let parts = this.street.split('/');
                if (parts.length > 1) {
                    this.unit = parts[0];
                    this.streetOnly = parts.splice(1).join('/');
                } else {
                    this.streetOnly = this.street;
                }
            }
        }

        if (this.streetOnly) {
            this.setShowAdditionalFields(true);
        }
    }

    setShowAdditionalFields(value) {
        this.showAdditionalFields = this.searchOnly === false && value;
    }

    get searchTerm() {
        let autocomplete = this.template.querySelector('[name="autocomplete"]');
        return autocomplete.value;
    }

    get streetFieldSize() {
        return this.hideUnit ? 'slds-col slds-size_1-of-1' : 'slds-col slds-size_2-of-3'
    }

    @api
    set searchTerm(searchTerm) {
        let autocomplete = this.template.querySelector('[name="autocomplete"]');
        autocomplete.value = searchTerm;
    }

    @api
    validate() {
        this.clearErrors();
        let hasNoError = this.required === true && this.street && this.city && this.state || this.required !== true || this.required === undefined;
        if (!hasNoError) {
            this.showErrors(['Complete this field.']);
        }
        return hasNoError;
    }

    get elementContainerClasses() {
        let classes = 'slds-form-element';
        if (this.required) {
            classes += ' is-required';
        }
        if (this.errorMessages?.length > 0) {
            classes += ' slds-has-error';
        }
        return classes;
    }

    handleFieldChange(event) {
        switch (event.target.dataset.id) {
            case 'unit':
                this.unit = event.target.value;
                this.streetFormat();
                break;
            case 'street':
                this.streetOnly = event.target.value;
                this.streetFormat();
                break;
            case 'city':
                this.city = event.target.value?.split(' ').map(v => v.charAt(0).toUpperCase() + v.slice(1)).join(' ');
                break;
            case 'state':
                this.state = event.target.value;
                break;
            case 'postCode':
                this.postCode = event.target.value?.replace(/\D/g, '').slice(0, 4);
                event.target.value = this.postCode;
                break;
            case 'country':
                this.country = event.target.value;
                break;
        }
        this.dispatchEvent(new CustomEvent('change', {
            bubbles: false,
            composed: false
        }));
    }

    handleSearchTermChange(event) {
        let searchLookup = this.template.querySelector('[data-id="searchLookup"]');

        if (typeof this.searchTerm == null || this.searchTerm.length < 3) {
            searchLookup.classList.add('slds-combobox-lookup');
            searchLookup.classList.remove('slds-is-open');
            return;
        }

        searchLookup.classList.add('slds-is-open');
        searchLookup.classList.remove('slds-combobox-lookup');

        setTimeout(this.search.bind(this, this.searchTerm.slice()), this.searchDebounce);
    }

    handleSelect(event) {
        let selectedItem = event.currentTarget.dataset.record;

        this.selectedOption = selectedItem;

        let searchLookup = this.template.querySelector('[data-id="searchLookup"]');
        searchLookup.classList.remove('slds-is-open');

        this.searchTerm = selectedItem;

        this.search(undefined, event.currentTarget.dataset.value);

        this.dispatchEvent(new CustomEvent('select', {
            bubbles: false,
            composed: false
        }));
    }

    handleClear(event) {
        let searchLookup = this.template.querySelector('[data-id="searchLookup"]');
        searchLookup.classList.add('slds-combobox-lookup');

        this.selectedOption = null;
        this.searchTerm = null;
    }

    search(searchTerm, placeId) {
        if (!placeId && searchTerm === this.searchTerm) {
            this.execute('vertic_GoogleAddressSearchProc',
                {
                    searchTerm: this.searchTerm,
                    types: 'address'
                }
            ).then(response => {
                let predictions = response.dto.googleResponse.predictions || [];
                this.filteredOptions = predictions.map(({place_id, description}) => ({
                    value: place_id,
                    label: description
                }));
            }).catch(errors => {
                showToast(this, 'Error', errors[0].message, 'error');
            });
        } else if (placeId) {
            this.execute('vertic_GoogleAddressSearchProc',
                {
                    placeId: placeId
                }
            ).then(response => {
                let result = response.dto.googleResponse.result;
                let componentByType;
                let componentByTypeShort = [];
                let componentByTypeLong = [];

                if (result.address_components) {
                    result.address_components.forEach(({types, short_name}) => {
                        componentByTypeShort[types[0]] = short_name
                    });
                    result.address_components.forEach(({types, long_name}) => {
                        componentByTypeLong[types[0]] = long_name
                    });
                }

                componentByType = componentByTypeLong;
                if (this.shortNameFor && this.shortNameFor.indexOf('unit') >= 0) {
                    componentByType = componentByTypeShort;
                }
                this.unit = componentByType['subpremise'];
                if (this.uppercaseFor && this.uppercaseFor.indexOf('unit') >= 0) {
                    this.unit = this.unit.toUpperCase();
                }

                componentByType = componentByTypeLong;
                if (this.shortNameFor && this.shortNameFor.indexOf('street') >= 0) {
                    componentByType = componentByTypeShort;
                }
                this.streetOnly = [componentByType['street_number'] || '', componentByType['route'] || ''].join(' ');
                if (this.uppercaseFor && this.uppercaseFor.indexOf('street') >= 0) {
                    this.streetOnly = this.streetOnly.toUpperCase();
                }

                componentByType = componentByTypeLong;
                if (this.shortNameFor && this.shortNameFor.indexOf('city') >= 0) {
                    componentByType = componentByTypeShort;
                }
                this.city = componentByType['locality'] || componentByType['administrative_area_level_2']
                if (this.uppercaseFor && this.uppercaseFor.indexOf('city') >= 0) {
                    this.city = this.city.toUpperCase();
                }

                componentByType = componentByTypeLong;
                if (this.shortNameFor && this.shortNameFor.indexOf('state') >= 0) {
                    componentByType = componentByTypeShort;
                }
                this.state = componentByType['administrative_area_level_1'];
                if (this.uppercaseFor && this.uppercaseFor.indexOf('state') >= 0) {
                    this.state = this.state.toUpperCase();
                }

                componentByType = componentByTypeLong;
                if (this.shortNameFor && this.shortNameFor.indexOf('postCode') >= 0) {
                    componentByType = componentByTypeShort;
                }
                this.postCode = componentByType['postal_code']
                if (this.uppercaseFor && this.uppercaseFor.indexOf('postCode') >= 0) {
                    this.postCode = this.postCode.toUpperCase();
                }

                componentByType = componentByTypeLong;
                if (this.shortNameFor && this.shortNameFor.indexOf('country') >= 0) {
                    componentByType = componentByTypeShort;
                }
                this.country = componentByType['country'];
                if (this.uppercaseFor && this.uppercaseFor.indexOf('country') >= 0) {
                    this.country = this.country.toUpperCase();
                }

                this.streetFormat();

                this.setShowAdditionalFields(true);

                this.validate();

                this.dispatchEvent(new CustomEvent('change', {
                    bubbles: false,
                    composed: false,
                    detail: {
                        country: this.country,
                        state: this.state,
                        city: this.city,
                        postCode: this.postCode,
                        street: this.street
                    }
                }));
            }).catch(errors => {
                showToast(this, 'Error', errors[0].message, 'error');
            });
        }
    }

    streetFormat() {
        var parts = [];
        if (this.unit != null) {
            parts.push(this.unit);
        }
        if (this.streetOnly != null) {
            parts.push(this.streetOnly);
        }

        let street = parts.join('/');

        let oldStreet = this.street;
        if (oldStreet !== street) {
            this.street = street;
        }
    }

    handleEnterManuallyClick(event) {
        this.setShowAdditionalFields(true);
    }

    handleClearAddressClick(event) {
        this.setShowAdditionalFields(false);

        this.unit = null;
        this.streetOnly = null;
        this.street = null;
        this.city = null;
        this.state = null;
        this.postCode = null;
        this.country = null;
    }
}