import {LightningElement, api, track, wire} from 'lwc';
import doSubmit from '@salesforce/apex/rspcaqldCtaFormCtrl.doSubmit';
import {NavigationMixin} from "lightning/navigation";
import getPortalSetting from '@salesforce/apex/rspcaqldUtils.getPortalSetting';
import * as constants from 'c/constants';

export default class RspcaqldSectionContactUs extends NavigationMixin(LightningElement) {
    @api customClass;
    @api customMetadata = 'Main';
    @api generalHeader;
    @api generalDescription;
    @api generalBodyString;
    @api otherHeader;
    @api otherLeftColumnBodyString;
    @api otherRightColumnBodyString;
    @api thankYouMessage;
    portalSetting;

    arrowRightWhite = constants.arrowRightWhite;
    requiredText = constants.requiredText;

    isPrivacyPolicy = false;
    isNewsletterRequired = false;
    isPrivacyPolicyError = false;
    isSubmitting = false;

    @track contact = {
        organisation: null,
        firstName: '',
        lastName: '',
        email: '',
        phone: ''
    };

    @track cs = {
        partnershipType: null,
        description: '',
        reason: 'General Enquiry',
        marketingOptin: false,
        privacyPolicy: false,
    };

    @wire(getPortalSetting, {customMetadataName: '$customMetadata'}) wiredPortalSetting ({ error, data }) {
        if (data) {
            this.portalSetting = data;
            this.cs.marketingOptin = this.portalSetting.Subscribe_to_Newsletter_Default_Value__c;
            this.cs.privacyPolicy = this.portalSetting.Privacy_Statement_Default_Value__c;
            this.isPrivacyPolicy = this.portalSetting.Privacy_Statement_Required__c;
            this.isNewsletterRequired = this.portalSetting.Subscribe_to_Newsletter_Required__c;
        }
        if (error) {}
    }

    get mainClass() {
        return 'page-contact-us' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get generalBody() {
        return this.generalBodyString ? JSON.parse(this.generalBodyString) : [];
    }

    get otherLeftColumnBody() {
        return this.otherLeftColumnBodyString ? JSON.parse(this.otherLeftColumnBodyString) : [];
    }

    get otherRightColumnBody() {
        return this.otherRightColumnBodyString ? JSON.parse(this.otherRightColumnBodyString) : [];
    }

    get submittedClass() {
        return 'contact-us-form-submit' + (this.isSubmitted ? ' active' : '');
    }

    handleFieldChange(evt) {
        let requiredFields = 'first-name,last-name,email,phone';
        let fieldName= evt.currentTarget.dataset.name;
        let fieldValue = evt.detail.value;

        if (requiredFields.includes(fieldName)) this.reportValidity(fieldName, '');

        if (fieldName == 'first-name') this.contact.firstName = fieldValue;
        if (fieldName == 'last-name') this.contact.lastName = fieldValue;
        if (fieldName == 'email') this.contact.email = fieldValue;
        if (fieldName == 'phone') this.contact.phone = fieldValue;
        if (fieldName == 'description') this.cs.description = fieldValue;
        if (fieldName == 'marketing-optin') this.cs.marketingOptin = fieldValue;
        if (fieldName == 'privacy-policy') {
            this.isPrivacyPolicyError = false;
            this.cs.privacyPolicy = fieldValue;
        }
    }

    handlePhoneKeydown(evt) {
        var keyCode = evt.which || evt.keyCode || 0;
        var regexp = new RegExp(/^[0-9-]+$/);
        var regexpApostrophe = new RegExp("'");

        if (((evt.metaKey || evt.ctrlKey) && keyCode != 65 && keyCode != 67 && keyCode != 86 && keyCode != 88) ||
            (!evt.metaKey && !evt.ctrlKey && keyCode >= 48 && ! regexp.test(evt.key) && ! regexpApostrophe.test(evt.key))) {
            evt.preventDefault();
        }
    }

    handleSubmit(evt) {
        if (this.validateDetails()) {
            this.isSubmitting = true;
            doSubmit({ contactString: JSON.stringify(this.contact), caseString: JSON.stringify(this.cs)})
                .then(result => {
                    this.isSubmitting = false;
                    this.isSubmitted = true;
                    setTimeout(() => this.refresh(), 3000);
                })
                .catch(error => {
                    this.isSubmitting = false;
                    console.log(error);
                })
        }
    }

    validateDetails() {
        this.reportValidity('first-name', this.contact.firstName ? '' : constants.requiredText);
        this.reportValidity('last-name', this.contact.lastName ? '' : constants.requiredText);
        let isPhoneValid = this.validatePhone();
        let isEmailValid = this.validateEmail();
        this.isPrivacyPolicyError = this.portalSetting.Privacy_Statement_Required__c && !this.cs.privacyPolicy;

        return this.contact.firstName && this.contact.lastName && isPhoneValid
            && isEmailValid && !this.isPrivacyPolicyError;
    }

    reportValidity(fieldName, errorMessage) {
        this.template.querySelector('[data-name="' + fieldName + '"]').setCustomValidity(errorMessage);
        this.template.querySelector('[data-name="' + fieldName + '"]').reportValidity();
    }

    validatePhone() {
        if (this.template.querySelector('.phone-input')) {
            let errorMessage = this.contact.phone ? (this.contact.phone.length == 10 && this.contact.phone.startsWith('0') ? '' : 'Phone format is incorrect.' + (! this.contact.phone.startsWith('0') ? " It should start with '0'" : ' Phone must be 10 digits in length')) : constants.requiredText;
            this.template.querySelector('.phone-input').setCustomValidity(errorMessage);
            this.template.querySelector('.phone-input').reportValidity();
            return this.contact.phone && this.contact.phone.length == 10 && this.contact.phone.startsWith('0');
        }
        return false;
    }

    validateEmail() {
        let emailValid = false;
        if (this.template.querySelector('.email-input')) {
            if (this.contact.email) {
                const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                emailValid = this.contact.email.match(emailRegex);
                this.template.querySelector('.email-input').setCustomValidity(emailValid ? '' : 'The email address is incorrect');
            } else {
                this.template.querySelector('.email-input').setCustomValidity(constants.requiredText);
            }
            this.template.querySelector('.email-input').reportValidity();
        }

        return emailValid;
    }

    refresh() {
        this.contact = {
            organisation: null,
            firstName: '',
            lastName: '',
            email: '',
            phone: ''
        };

        this.cs = {
            partnershipType: null,
            description: '',
            reason: 'General Enquiry',
            marketingOptin: false,
            privacyPolicy: false,
        };

        this.isSubmitted = false;
    }
}