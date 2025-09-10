import doSubscribe from '@salesforce/apex/rspcaqldSubscribe.doSubscribe';
import {api, LightningElement, wire} from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import getPortalSetting from '@salesforce/apex/rspcaqldUtils.getPortalSetting';
import * as constants from 'c/constants';

export default class RspcaqldSectionSubscribe extends NavigationMixin(LightningElement) {
    @api customMetadata = 'Main';
    @api header;
    @api tcAndPP;
    @api subscribeButton;
    @api firstName;
    @api lastName;
    @api email;
    @api thankYouMessage;
    isSubmitting = false;
    isSubmitted = false;

    @wire(getPortalSetting, {customMetadataName: '$customMetadata'}) wiredPortalSetting ({ error, data }) {
        if (data) {
            this.portalSetting = data;
            if (!this.header) this.header = this.portalSetting.Hotspot_Email_Subscribe_Header_Text__c;
            if (!this.tcAndPP) this.tcAndPP = this.portalSetting.Hotspot_Email_Subscribe_T_C_and_PP__c;
            if (!this.subscribeButton) this.subscribeButton = this.portalSetting.Hotspot_Email_Subscribe_Button_Text__c;
            if (!this.thankYouMessage) this.thankYouMessage = this.portalSetting.Hotspot_Email_Subscribe_Thank_You__c;
        }
        if (error) {}
    }

    get submittedClass() {
        return 'subscribe-submit' + (this.isSubmitted ? ' active' : '');
    }

    handleFirstNameChange(event) {
        this.firstName = event.detail.value;
        this.template.querySelector('.first-name').setCustomValidity('');
        this.template.querySelector('.first-name').reportValidity();
    }
    handleLastNameChange(event) {
        this.lastName = event.detail.value;
        this.template.querySelector('.last-name').setCustomValidity('');
        this.template.querySelector('.last-name').reportValidity();
    }
    handleEmailChange(event) {
        this.email = event.detail.value;
        this.validateEmail();
    }

    handleClick(event) {
        this.template.querySelector('.first-name').setCustomValidity(this.firstName ? '' : constants.requiredText);
        this.template.querySelector('.first-name').reportValidity();
        this.template.querySelector('.last-name').setCustomValidity(this.lastName ? '' : constants.requiredText);
        this.template.querySelector('.last-name').reportValidity();

        let emailValid = this.validateEmail();

        if (this.firstName && this.lastName && this.email && emailValid) {
            this.isSubmitting = true;
            doSubscribe({ firstName: this.firstName, lastName: this.lastName, email: this.email})
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

    validateEmail() {
        let emailValid = false;
        let emailValue = this.template.querySelector('.email').value;
        if (emailValue) {
            const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            emailValid = emailValue.match(emailRegex);
            this.template.querySelector('.email').setCustomValidity(emailValid ? '' : 'The email address is incorrect');
        } else {
            this.template.querySelector('.email').setCustomValidity(constants.requiredText);
        }
        this.template.querySelector('.email').reportValidity();
        return emailValid;
    }

    refresh() {
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.isSubmitted = false;
    }
}