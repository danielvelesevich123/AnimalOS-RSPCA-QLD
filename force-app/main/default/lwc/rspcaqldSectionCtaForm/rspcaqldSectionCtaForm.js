import {LightningElement, track, wire, api} from 'lwc';
import getImage from '@salesforce/apex/ManagedContentService.getImageByContentKey';
import getPicklistValues from '@salesforce/apex/rspcaqldUtils.getPicklistValues';
import doSubmit from '@salesforce/apex/rspcaqldCtaFormCtrl.doSubmit';
import getPortalSetting from '@salesforce/apex/rspcaqldUtils.getPortalSetting';
import {NavigationMixin} from "lightning/navigation";
import * as constants from 'c/constants';

export default class RspcaqldSectionCtaForm extends NavigationMixin(LightningElement) {
    @api customClass;
    @api formType = 'Partner';
    @api icon;
    @wire(getImage, {contentKey: '$icon'}) iconURL;
    @api header = 'Call to action title here';
    @api description = 'If the form required is a large multi step for the cta should link to it’s separate page. For example adopt a pet, report cruelty and report injured wildlife have their own forms.';
    @wire(getPicklistValues, {fieldName: 'Case.Partnership_Enquiry_Type__c'}) partnershipTypes;
    @wire(getPicklistValues, {fieldName: 'Case.Education_Enquiry_Type__c'}) educationTypes;
    @wire(getPicklistValues, {fieldName: 'Case.Preferred_Contact_Method__c'}) preferredContactMethodTypes;
    @api preferredLocations = [
        {label: 'Brisbane, Wacol Shelter', value: 'Brisbane, Wacol Shelter'},
        {label: 'Bundaberg Shelter', value: 'Bundaberg Shelter'},
        {label: 'Cairns Shelter', value: 'Cairns Shelter'},
        {label: 'Dakabin Shelter', value: 'Dakabin Shelter'},
        {label: 'Gympie Shelter', value: 'Gympie Shelter'},
        {label: 'Kingaroy Shelter', value: 'Kingaroy Shelter'},
        {label: 'Mackay Shelter', value: 'Mackay Shelter'},
        {label: 'Noosa Shelter', value: 'Noosa Shelter'},
        {label: 'Toowoomba Shelter', value: 'Toowoomba Shelter'},
        {label: 'Brisbane Wildlife Hospital', value: 'Brisbane Wildlife Hospital'},
        {label: 'Eumundi Wildlife Rehab Centre', value: 'Eumundi Wildlife Rehab Centre'},
        {label: 'Wacol World for Pets', value: 'Wacol World for Pets'},
        {label: 'Ascot Op Shop', value: 'Ascot Op Shop'},
        {label: 'Ashmore Op Shop', value: 'Ashmore Op Shop'},
        {label: 'Brassall Op Shop', value: 'Brassall Op Shop'},
        {label: 'Brendale Op Shop', value: 'Brendale Op Shop'},
        {label: 'Bundaberg Op Shop', value: 'Bundaberg Op Shop'},
        {label: 'Bundall Op Shop', value: 'Bundall Op Shop'},
        {label: 'Gympie Op Shop', value: 'Gympie Op Shop'},
        {label: 'Lawnton Op Shop', value: 'Lawnton Op Shop'},
        {label: 'Loganholme Op Shop', value: 'Loganholme Op Shop'},
        {label: 'Moorooka Op Shop', value: 'Moorooka Op Shop'},
        {label: 'New Farm Op Shop', value: 'New Farm Op Shop'},
        {label: 'North Tamborine Op Shop', value: 'North Tamborine Op Shop'},
        {label: 'Paddington Op Shop', value: 'Paddington Op Shop'},
        {label: 'Robina Op Shop', value: 'Robina Op Shop'},
        {label: 'Rockhampton Op Shop', value: 'Rockhampton Op Shop'},
        {label: 'Sherwood Op Shop', value: 'Sherwood Op Shop'},
        {label: 'Stafford Op Shop', value: 'Stafford Op Shop'},
        {label: 'Stones Corner Op Shop', value: 'Stones Corner Op Shop'},
        {label: 'Toowoomba Op Shop', value: 'Toowoomba Op Shop'},
        {label: 'Townsville Op Shop', value: 'Townsville Op Shop'},
        {label: 'Underwood Op Shop', value: 'Underwood Op Shop'},
        {label: 'Brisbane Superstore Op Shop', value: 'Brisbane Superstore Op Shop'},
        {label: 'Wacol Black Cat Café', value: 'Wacol Black Cat Café'}
    ];
    @api thankYouMessage;
    @api customMetadata = 'Main';
    @api hideWedgeShape = false;
    portalSetting;
    isPrivacyPolicy = false;
    isNewsletterRequired = false;
    isPrivacyPolicyError = false;
    isVolunteerDeclarationError = false;
    isSubmitting = false;
    isSubmitted = false;
    requiredText = constants.requiredText;

    @track contact = {
        organisation: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: ''
    };

    @track cs = {
        partnershipType: '',
        educationType: '',
        description: '',
        location: '',
        preferredContactMethod: '',
        volunteerDeclaration: false,
        marketingOptin: false,
        privacyPolicy: false
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

    get containerClass() {
        return 'cta-form-container' + (this.hideWedgeShape ? '' : ' wedge-shape');
    }

    get mainClass() {
        return 'section-cta-form' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get desktopSubmittedClass() {
        return 'cta-form-submit-desktop' + (this.isSubmitted ? ' active' : '');
    }

    get mobileSubmittedClass() {
        return 'cta-form-submit-mobile' + (this.isSubmitted ? ' active' : '');
    }

    get organisationLabel() {
        return this.formType == 'Partner' ? 'Business Name' : 'Name of School, Early Learning Centre or Group';
    }

    get descriptionLabel() {
        let label;
        switch (this.formType) {
            case 'Education': label = 'Message'; break;
            case 'Partner': label = 'Please describe the nature of your partnership enquiry'; break;
            case 'Volunteer': label = 'Tell us what sort of volunteer role you\'re interested in'; break;
            default: label = 'Message';
        }

        return label;
    }

    get descriptionPlaceholder() {
        let placeholder;
        switch (this.formType) {
            case 'Education': placeholder = 'Please include any topics of interest'; break;
            case 'Partner': placeholder = 'Please describe the nature of your partnership enquiry'; break;
            case 'Volunteer': placeholder = 'Looking for something animal facing, or more of the office life? Tell us here'; break;
            default: placeholder = 'Message';
        }

        return placeholder;
    }

    get locationLabel() {
        let label;
        switch (this.formType) {
            case 'Education': label = 'Location'; break;
            case 'Volunteer': label = 'Where are you interested in volunteering?'; break;
            default: label = 'Location';
        }

        return label;
    }

    get locationPlaceholder() {
        let placeholder;
        switch (this.formType) {
            case 'Education': placeholder = 'Your suburb'; break;
            case 'Volunteer': placeholder = 'Select option'; break;
            default: placeholder = 'Location';
        }

        return placeholder;
    }

    get isPartner() {return this.formType && this.formType == 'Partner';}
    get isEducation() {return this.formType && this.formType == 'Education';}
    get isVolunteer() {return this.formType && this.formType == 'Volunteer';}

    handleFieldChange(evt) {
        let fieldName= evt.currentTarget.dataset.name;
        let fieldValue = evt.detail.value;

        if (fieldName == 'organisation') this.contact.organisation = fieldValue;
        if (fieldName == 'first-name') this.contact.firstName = fieldValue;
        if (fieldName == 'last-name') this.contact.lastName = fieldValue;
        if (fieldName == 'email') {
            this.validateEmail();
            this.contact.email = fieldValue;
        }
        if (fieldName == 'phone') {
            this.validatePhone();
            this.contact.phone = fieldValue;
        }
        if (fieldName == 'partnership-type') this.cs.partnershipType = fieldValue;
        if (fieldName == 'education-type') this.cs.educationType = fieldValue;
        if (fieldName == 'description') this.cs.description = fieldValue;
        if (fieldName == 'location') this.cs.location = fieldValue;
        if (fieldName == 'preferred-contact-method-type') this.cs.preferredContactMethod = fieldValue;
        if (fieldName == 'volunteer-declaration') {
            this.isVolunteerDeclarationError = false;
            this.cs.volunteerDeclaration = fieldValue;
        }
        if (fieldName == 'marketing-optin') this.cs.marketingOptin = fieldValue;
        if (fieldName == 'privacy-policy') {
            this.isPrivacyPolicyError = false;
            this.cs.privacyPolicy = fieldValue;
        }

        this.validateFields(fieldName);
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
            this.cs.reason = this.getReason();

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

    getReason() {
        switch (this.formType) {
            case 'Education': return 'Education Enquiry';
            case 'Partner': return 'Partnership Enquiry';
            case 'Volunteer': return 'Volunteer Enquiry';
            default: return 'Partnership Enquiry';
        }
    }

    refresh() {
        this.contact = {
            organisation: '',
            firstName: '',
            lastName: '',
            email: '',
            phone: ''
        };

        this.cs = {
            partnershipType: '',
            educationType: '',
            description: '',
            location: '',
            preferredContactMethod: '',
            volunteerDeclaration: false,
            marketingOptin: false,
            privacyPolicy: false
        };

        this.isSubmitted = false;
    }

    validateFields(fieldName) {
        let requiredFields = 'first-name,last-name';
        let picklistRequiredFields = '';
        if (this.isEducation) {
            requiredFields += ',organisation,location';
            picklistRequiredFields += 'education-type';
        }
        if (this.isVolunteer) picklistRequiredFields += 'location';

        if (requiredFields.includes(fieldName)) this.reportValidity(fieldName, '');
        if (picklistRequiredFields.includes(fieldName)) this.reportPicklistValidity(fieldName, '');
        if (fieldName == 'email') this.validateEmail();
        if (fieldName == 'phone') this.validatePhone();
    }

    validateDetails() {
        let isEducation = this.isEducation;
        let isPartner = this.isPartner;
        let isVolunteer = this.isVolunteer;

        this.reportValidity('first-name', this.contact.firstName ? '' : this.requiredText);
        this.reportValidity('last-name', this.contact.lastName ? '' : this.requiredText);
        if (isEducation) this.reportValidity('organisation', this.contact.organisation ? '' : this.requiredText);
        if (isEducation) this.reportPicklistValidity('education-type', this.cs.educationType ? false : true);
        if (isVolunteer) this.reportPicklistValidity('location', this.cs.location ? '' : this.requiredText);
        if (isEducation) this.reportValidity('location', this.cs.location ? '' : this.requiredText);
        let isPhoneValid = this.validatePhone();
        let isEmailValid = this.validateEmail();
        this.isPrivacyPolicyError = this.portalSetting.Privacy_Statement_Required__c && !this.cs.privacyPolicy;
        this.isVolunteerDeclarationError = !this.cs.volunteerDeclaration;

        return this.contact.firstName && this.contact.lastName && isPhoneValid &&
            isEmailValid && !this.isPrivacyPolicyError && (isPartner || (!isPartner && this.cs.location)) &&
            (!isEducation || (isEducation && this.contact.organisation && this.cs.educationType)) &&
            (!isVolunteer || (isVolunteer && this.cs.volunteerDeclaration));
    }

    reportValidity(fieldName, errorMessage) {
        this.template.querySelector('[data-name="' + fieldName + '"]').setCustomValidity(errorMessage);
        this.template.querySelector('[data-name="' + fieldName + '"]').reportValidity();
    }

    reportPicklistValidity(fieldName, hasError) {
        this.template.querySelector('[data-name="' + fieldName + '"]').hasError = hasError;
    }

    validatePhone() {
        if (this.template.querySelector('.phone-input')) {
            let errorMessage = this.contact.phone ? (this.contact.phone.length == 10 && this.contact.phone.startsWith('0') ? '' : 'Phone format is incorrect' + (! this.contact.phone.startsWith('0') ? " It should start with '0'" : ' Phone must be 10 digits in length')) : this.requiredText;
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
                this.template.querySelector('.email-input').setCustomValidity(this.requiredText);
            }
            this.template.querySelector('.email-input').reportValidity();
        }

        return emailValid;
    }
}