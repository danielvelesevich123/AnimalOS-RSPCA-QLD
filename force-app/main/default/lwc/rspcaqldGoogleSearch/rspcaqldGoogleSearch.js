import {
    api,
    wire,
    LightningElement
} from 'lwc';
import getPortalCustomSetting from '@salesforce/apex/rspcaqldUtils.getPortalCustomSetting';
import getHttp from '@salesforce/apex/rspcaqldUtils.getHttp';
import * as constants from 'c/constants';

export default class RspcaqldGoogleSearch extends LightningElement {
    @api label;
    @api placeholder;
    @api helptext;
    @api value = '';
    @api addressValue = '';
    @api hasError = false;
    @api disabled = false;
    @api checked = false;
    @api required = false;
    @api isOpen = false;
    options = [];
    googleApiKey;
    closeDark = constants.closeDark;

    get iconClass() {
        return 'default color-100 ' + (this.isOpen ? 'fa-solid fa-chevron-up' : 'fa-solid fa-chevron-down');
    }

    get tabIndex() {
        return this.isOpen ? -1 : 0;
    }

    get picklistClass() {
        return 'input-dropdown input-google-search slds-form-element ' + (this.hasError ? 'slds-has-error ' : '') + (this.isOpen ? 'dropdown-open ' : '');
    }

    get isAddressValue() {return this.addressValue ? true : false;}
    get isHelptext() {return this.helptext ? true : false;}

    @api
    clear() {
        this.value = null;
        this.addressValue = null;
        this.checked = false;
        this.disabled = false;
    }

    connectedCallback() {
        getPortalCustomSetting()
            .then(result => {
                this.googleApiKey = result.Google_Maps_Api_Key__c;
            })
    }

    renderedCallback() {
        this.template.querySelector('.input-dropdown').addEventListener('focusout',
            this.handleFocusOut);
    }

    handleInputClick(evt) {
        this.template.querySelector('.slds-input').focus();
        if (this.options.length > 0) this.isOpen = true;
    }

    handleIconClick(evt) {
       this.clear();
       this.dispatchEvent(new CustomEvent("change", {detail: {value : null}}));
    }

    handleInputChange(evt) {
        this.dispatchEvent(new CustomEvent("type", {detail: {value : evt.target.value}}));
        this.value = evt.target.value;
        this.getAddress();
    }

    handleFocusOut = (evt) => {
        setTimeout(() => this.handleClose(), 150);
    }

    handleClose(evt) {
        this.isOpen = false;
        if (!this.checked) this.value = null;
        this.template.querySelector('.input-dropdown').blur();
    }

    handleValueClick(evt) {
        this.dispatchEvent(new CustomEvent("select"));
        this.value = evt.currentTarget.dataset.label;
        this.addressValue = evt.currentTarget.dataset.item;
        this.disabled = true;
        this.checked = true;
        this.options = [];

        let url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=" + encodeURI(this.addressValue) + "&key=" + this.googleApiKey;
        getHttp({strURL: url})
            .then(result => {
                this.dispatchEvent(new CustomEvent("change", {detail: {value : result}}));
            })
            .catch(error => {
                this.options = [];
                console.log(error);
            });
    }

    getAddress() {
        let url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=" + encodeURI(this.value) + "&components=country:AU&types=address&key=" + this.googleApiKey;
        getHttp({strURL: url})
            .then(result => {
                this.options = [];
                let predictions = JSON.parse(result).predictions;
                if (predictions.length > 0) {
                    for (var i = 0; i < predictions.length; i++) {
                        this.options.push(
                            {
                                value: predictions[i].place_id,
                                label: predictions[i].description,
                                checked: false
                            });
                    }
                    this.isOpen = true;
                }
            })
            .catch(error => {
                this.options = [];
                console.log(error);
            });
    }
}