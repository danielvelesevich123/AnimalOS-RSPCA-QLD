import {LightningElement, api} from 'lwc';
import {execute, showToast, validate, copy} from 'c/verticUtils';

const delay = 500; // Delay in milliseconds for search
export default class AnimalWelfareLocationOfInterest extends LightningElement {
    @api recordId;
    isInit;
    isSearch;
    @api locationOfInterest = {};
    searchBy = 'Id';
    searchMessage;
    yesNoOptions = [
        {label: 'Yes', value: 'Yes'},
        {label: 'No', value: 'No'}
    ];
    @api
    hideLocationSafety = false;

    async connectedCallback() {
        this.locationOfInterest = copy(this.locationOfInterest);

        if (this.recordId) {
            this.locationOfInterest.Id = this.recordId;
            this.isInit = true;
            await this.search();
            this.isInit = false;
        }
    }

    async search(searchWithDelay) {
        if (this.isInit === false) {
            let form = this.template.querySelector(`[data-id="form"]`);

            if (Array.isArray(form)) {
                form = form[0];
            }

            let formValidateResult = validate(form, {});
            if (formValidateResult.allValid !== true) {
                return;
            }
        }

        if (searchWithDelay === true) {
            if (this.searchTimeout) {
                clearTimeout(this.searchTimeout);
            }

            this.searchTimeout = setTimeout(() => {
                this.search();
            }, delay);
            return;
        }

        this.isSearch = true;
        this.searchMessage = 'Searching by ' + this.searchBy + '...';
        await execute('AnimalWelfareLOISearchProc', {
            searchBy: this.searchBy,
            locationOfInterest: this.locationOfInterest
        })
            .then(response => {
                this.locationOfInterest = response.dto.locationOfInterest || this.locationOfInterest;
                if (this.locationOfInterest.Id) {
                    this.searchMessage = 'Location of Interest found successfully. All inputs are populated.';
                } else {
                    this.searchMessage = 'No Location of Interest found for the given ' + this.searchBy;
                }
                this.refreshHistoryComponents();
            })
            .catch(errors => {
                showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error');
            })
            .finally(() => {
                this.isSearch = false;
            });
    }

    get showSearchMessage() {
        return this.searchMessage !== undefined && this.searchMessage !== null && this.searchMessage !== '';
    }

    get locationAddressNotEmpty() {
        return this.locationOfInterest.animalos__Address__Street__s || this.locationOfInterest.Id;
    }

    get showHistory() {
        return this.isSearch === false && this.locationOfInterest.Id;
    }

    get locationOfInterestUrl() {
        return location.hostname + '/' + this.locationOfInterest.Id;
    }

    handleLOIFieldChange(event) {
        this.locationOfInterest = this.handleFieldChange(this.locationOfInterest, event);
    }

    handleFieldChange(map, event) {
        let index = event.target.getAttribute('data-index');
        let path = event.target.getAttribute('data-path');
        let isCheckbox = event.target.type === 'toggle' || event.target.type === 'checkbox' || event.target.type === 'checkbox-button';
        let value = isCheckbox ? event.target.checked : event.target?.selectedValues || event.target?.value || event.detail?.value;
        path = path.replaceAll('[data-index]', '[' + index + ']');
        return this.setMapValue(map, path, value);
    }

    handleLOIAddressChange(event) {
        this.locationOfInterest.animalos__Address__Street__s = event.target.street;
        this.locationOfInterest.animalos__Address__City__s = event.target.city;
        this.locationOfInterest.animalos__Address__StateCode__s = this.formatState(event.target.province);
        this.locationOfInterest.animalos__Address__PostalCode__s = event.target.postalCode;
        this.locationOfInterest.animalos__Address__CountryCode__s = event.target.country === 'Australia' ? 'AU' : event.target.country;
    }

    handleManageSelected(event) {
        let selectedJobContacts = event.detail.selectedJobContacts || [];
        if (selectedJobContacts.length !== 0) {
            this.dispatchEvent(new CustomEvent('addjobcontacts', {
                bubbles: false,
                composed: false,
                detail: {
                    selectedJobContacts: selectedJobContacts
                }
            }));
        }
    }

    handleLOILookupChange(event) {
        this.handleLOIFieldChange(event);
        if (this.locationOfInterest.Id) {
            this.search();
        }
    }
    handleSearchAddressChange(event) {
        this.locationOfInterest.animalos__Address__Street__s = event.target.street;
        this.locationOfInterest.animalos__Address__City__s = event.target.city;
        this.locationOfInterest.animalos__Address__StateCode__s = this.formatState(event.target.state);
        this.locationOfInterest.animalos__Address__PostalCode__s = event.target.postCode;
        this.locationOfInterest.animalos__Address__CountryCode__s = event.target.country === 'Australia' ? 'AU' : event.target.country;
        this.search();
    }

    handleCoordinatesChange(event) {
        this.locationOfInterest = this.handleFieldChange(this.locationOfInterest, event);
        if (this.locationOfInterest.animalos__Address__Latitude__s && this.locationOfInterest.animalos__Address__Longitude__s) {
            this.search(true);
        }
    }

    refreshHistoryComponents() {
        if (this.locationAddressNotEmpty) {
            if (this.refs.locationHistory) {
                this.refs.locationHistory.refresh();
            }
        }
    }

    setMapValue(map, path, value) {
        if (!path || path.length === 0) {
            return value;
        }
        if (!Array.isArray(path)) {
            path = path.split('.');
        }

        let key = path[0];
        if (key.startsWith('[') && key.endsWith(']')) {
            key = parseInt(key.substring(0, key.length - 1).substring(1));
        }

        map[key] = map[key] || {};

        path.splice(0, 1);
        map[key] = this.setMapValue(map[key], path, value);

        return map;
    }

    formatState(state) {
        switch (state) {
            case 'New South Wales' :
                return 'NSW';
            case 'South Australia' :
                return 'SA';
            case 'Tasmania' :
                return 'TAS';
            case 'Victoria' :
                return 'VIC';
            case 'Western Australia' :
                return 'WA';
            case 'Northern Territory' :
                return 'NT';
            case 'Queensland' :
                return 'QLD';
            case 'Australian Capital Territory' :
                return 'ACT';
            default :
                return state;
        }
    }

    get jobVar() {
        return {
            animalos__Location_Of_Interest__c: this.locationOfInterest.Id,
            animalos__Address__Street__s: this.locationOfInterest.animalos__Address__Street__s,
            animalos__Address__City__s: this.locationOfInterest.animalos__Address__City__s,
            animalos__Address__StateCode__s: this.locationOfInterest.animalos__Address__StateCode__s,
            animalos__Address__PostalCode__s: this.locationOfInterest.animalos__Address__PostalCode__s,
            animalos__Address__CountryCode__s: this.locationOfInterest.animalos__Address__CountryCode__s,
        }
    }

    @api setAddress(address) {
        this.locationOfInterest.animalos__Address__Street__s = address.street;
        this.locationOfInterest.animalos__Address__City__s = address.city;
        this.locationOfInterest.animalos__Address__StateCode__s = address.state;
        this.locationOfInterest.animalos__Address__PostalCode__s = address.postCode;
        this.locationOfInterest.animalos__Address__CountryCode__s = address.country;
        this.searchBy = 'Address';
        this.search();
    }

    get showLocationSafety() {
        return this.hideLocationSafety === false;
    }

    get searchByAddress() {
        return this.searchBy === 'Address';
    }

    get searchByName() {
        return this.searchBy === 'Id';
    }

    get searchByCoordinates() {
        return this.searchBy === 'Coordinates';
    }

    get searchByNameVariant() {
        return this.searchBy === 'Id' ? 'brand' : 'neutral';
    }

    get searchByAddressVariant() {
        return this.searchBy === 'Address' ? 'brand' : 'neutral';
    }

    get searchByCoordinatesVariant() {
        return this.searchBy === 'Coordinates' ? 'brand' : 'neutral';
    }

    handleSearchByClick(event) {
        const newMode = event.currentTarget?.dataset?.value;
        if (!newMode || newMode === this.searchBy) {
            return;
        }
        this.searchBy = newMode;
        this.locationOfInterest = {};
    }
}