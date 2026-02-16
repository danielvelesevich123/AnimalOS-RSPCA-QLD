import PORTAL_RESOURCE from '@salesforce/resourceUrl/PortalResource';
import {track, api, wire, LightningElement} from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import * as constants from "c/constants";
import {getRecord} from "lightning/uiRecordApi";
import {
    bankcardBlue,
    bankDark,
    detailsDark,
    dollarBlue,
    dollarDark,
    dollarWhite, locationDark,
    personDark, phoneDark,
    shelterDark
} from "c/constants";

const CAMPAIGN_FIELDS = ["Campaign.Name"];
const PAYMENT_METHODS = {
    'au_becs_debit': 'AU Direct Debit',
    'card': 'Credit Card',
    'google_pay': 'Google Pay',
    'apple_pay': 'Apple Pay'
};

export default class RspcaqldDonationForm extends NavigationMixin(LightningElement) {
    @api customMetadata;
    portalSetting;
    isPrivacyPolicy = false;
    isNewsletterRequired = false;

    @api campaignId;
    campaign = { data: [] };
    @api donationFrequencyPrompt;
    @api donationAmountPrompt;
    @api detailsHeaderPrompt;
    @api individualOrganisationSelector = 'Individual | Organisation';
    @api organisationNamePrompt;
    @api firstNamePrompt;
    @api lastNamePrompt;
    @api emailAddressPrompt;
    @api mobilePrompt;
    @api addressPrompt;
    @api paymentMethodPrompt;
    @api additionalInfoLabel;
    @api additionalInfoPrompt;
    @api termsConditionsText;
    @api newsletterSubscriptionText;
    @api submissionConsentText;
    @api thankYouPageURL = 'ty-donation';

    @api donationFrequency;
    donationImages = { data: [] };
    @api donationOnceString;
    @api donationMonthlyString;
    donationOnce = [];
    donationMonthly = [];
    donationImageKeys = [];

    @api donationButtonColor;
    @api donationButtonFontColor;
    @api donationButtonIcon;
    donationButtonIconURL = { data: [] };
    @api paymentButtonText = 'Payment options';
    @api paymentButtonColor;
    @api paymentButtonFontColor;
    @api paymentButtonIcon;
    paymentButtonIconURL = { data: [] };
    @api confirmButtonText = 'Confirm and Submit';
    @api confirmButtonColor;
    @api confirmButtonFontColor;
    @api confirmButtonIcon;
    confirmButtonIconURL = { data: [] };
    isPrepopulatedValueSelected = false;
    isAddressSelected = false;
    isAgree = false;
    isKeepUpdated = false;
    selectedStep = 'amount';
    detailsType = 'individual';
    individualLabel;
    organisationLabel;

    requiredText = constants.requiredText;
    handsDollarBlue = constants.handsDollarBlue;
    dollarWhite = constants.dollarWhite;
    dollarDark = constants.dollarDark;
    dollarBlue = constants.dollarBlue;
    personBlue = constants.personBlue;
    personDark = constants.personDark;
    bankcardBlue = constants.bankcardBlue;
    detailsDark = constants.detailsDark;
    locationDark = constants.locationDark;
    phoneDark = constants.phoneDark;
    shelterDark = constants.shelterDark;
    bankDark = constants.bankDark;

    stripePublishableKey = { data: [] };
    stripeLogoUrl = constants.stripeLogoUrl;
    stripeClient;
    intents = {};
    selectedIntent;
    stripeElements;
    isPaymentReady = false;
    isSubmitting = false;
    confirmError = null;
    selectedPaymentMethod = 'Credit Card';

    @track donation = {
        type: 'monthly',
        typeLabel: 'monthly',
        typeSecondLabel: 'Monthly',
        amount: null,
        otherAmount: null,
        viewAmount: null,
        comments: ''
    };
    @track contact = {
        organisation: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        address: '',
        street: null,
        state: null,
        city: null,
        postalCode: null,
        country: null
    };

    get containerClass() {return 'donation-form-container ' + this.selectedStep;}

    // -----NAVIGATION BUTTONS----- //

    get donationButtonClass() {
        let isDisabled = !this.donation.type || !this.donation.amount;
        return 'green-btn with-icon' + (isDisabled ? ' disabled' : '');
    }

    get donationButtonStyle() {return (this.donationButtonColor ? 'background: ' + this.donationButtonColor + ';' : '') +
                                      (this.donationButtonFontColor ? 'color: ' + this.donationButtonFontColor + ';' : '');}

    get paymentButtonClass() {
        let isDisabled = !this.contact.firstName || !this.contact.lastName || !this.contact.email || !this.contact.phone || !this.isAddressSelected;
        return 'green-btn with-icon' + (isDisabled ? ' disabled' : '');
    }
    get paymentButtonStyle() {return (this.paymentButtonColor ? 'background: ' + this.paymentButtonColor + ';' : '') +
                                     (this.paymentButtonFontColor ? 'color: ' + this.paymentButtonFontColor + ';' : '');}

    get confirmBackButtonClass() {return 'button-link' + (this.isSubmitting ? ' disabled' : '');}
    get confirmButtonClass() {
        let isDisabled = (this.isPrivacyPolicy && !this.isAgree) || (this.isNewsletterRequired && !this.isKeepUpdated) || !this.isPaymentReady || this.isSubmitting;
        return 'green-btn with-icon' + (isDisabled ? ' disabled' : '');
    }
    get confirmButtonStyle() {return (this.confirmButtonColor ? 'background: ' + this.confirmButtonColor + ';' : '') +
                                     (this.confirmButtonFontColor ? 'color: ' + this.confirmButtonFontColor + ';' : '');}

    get isConfirmError() {return this.confirmError ? true : false;}

    // -----NAVIGATION HEADERS----- //

    get amountNavClass() {
        let isDisabled = this.isSubmitting;
        return this.selectedStep == 'amount' ? 'active' : (isDisabled ? 'disabled' : '');
    }
    get amountStepClass() {return this.getStepClass('amount');}

    get detailsNavClass() {
        let isDisabled = !this.donation.type || !this.donation.amount || this.isSubmitting;
        return this.selectedStep == 'details' ? 'active' : (isDisabled ? 'disabled' : '');
    }
    get detailsStepClass() {return this.getStepClass('details');}

    get paymentNavClass() {
        let isDisabled = !this.donation.type || !this.donation.amount || (!this.contact.organisation && this.detailsType == 'organisation')
                                  || !this.contact.firstName || !this.contact.lastName || !this.contact.email
                                  || !this.contact.phone || !this.isAddressSelected || this.isSubmitting;
        return this.selectedStep == 'payment' ? 'active' : (isDisabled ? 'disabled' : '');
    }
    get paymentStepClass() {return this.getStepClass('payment');}

    // -----AMOUNT CLASSES----- //

    get isMontlhy() {return this.donation.type == 'monthly';}
    get donationAmountDescriptionClass() {return 'donation-amount-description' + (this.isPrepopulatedValueSelected ? ' active' : '');}
    get onceTypeClass() {return this.getPaymentTypeClass('one-off');}
    get monthlyTypeClass() {return this.getPaymentTypeClass('monthly');}

    get donationAmounts() {
        let _isPrepopulatedValueSelected = false;
        let amounts = this.donation.type == 'one-off' ? this.donationOnce : this.donationMonthly;
        for (let i = 0; i < amounts.length; i++) {
            let isAmount = amounts[i].amount && this.donation.amount == amounts[i].amount.toString().replace(/,/g, '');
            amounts[i].class = 'donation-btn' + (isAmount ? ' selected' : '');
            amounts[i].descClass = (isAmount ? 'active' : '');
            if (!_isPrepopulatedValueSelected) _isPrepopulatedValueSelected = isAmount;
            if (!amounts[i].imageUrl && this.donationImages.data) {
                if (amounts[i].image in this.donationImages.data) amounts[i].imageUrl = this.donationImages.data[amounts[i].image];
            }
        }

        if (!_isPrepopulatedValueSelected && !this.donation.otherAmount && amounts.length > 2) {
            amounts[1].class = 'donation-btn selected';
            amounts[1].descClass = 'active';
            _isPrepopulatedValueSelected = true;

            this.donation.amount = Number(amounts[1].amount.toString().replace(/,/g, ''));
            this.donation.otherAmount = null;
            this.donation.viewAmount = '$' + amounts[1].amount + ' ';
        }

        this.isPrepopulatedValueSelected = _isPrepopulatedValueSelected;
        return amounts;
    }

    // -----DETAIL CLASSES----- //

    get isOrganisation() {return this.detailsType == 'organisation';}
    get otherAmountIconClass() {return this.getIconClass('material-symbols-outlined', this.donation.otherAmount);}
    get organisationIconClass() {return this.getIconClass('material-symbols-outlined', this.contact.organisation);}
    get firstnameIconClass() {return this.getIconClass('material-symbols-outlined', this.contact.firstName);}
    get emailIconClass() {return this.getIconClass('material-symbols-outlined', this.contact.email);}
    get mobilecodeIconClass() {return this.getIconClass('material-symbols-outlined', this.contact.phone);}
    get addressIconClass() {return this.getIconClass('material-symbols-outlined', this.contact.address);}

    get individualDetailClass() {return this.getDetailClass('individual');}
    get organisationDetailClass() {return this.getDetailClass('organisation');}

    get paymentTypeClass() {
        return 'payment-element' + (this.isSubmitting ? ' disabled' : '');
    }

    connectedCallback() {
        this.initStripe();
        if (this.individualOrganisationSelector) {
            let labels = this.individualOrganisationSelector.split('|');
            if (labels.length > 0) {
                this.individualLabel = labels[0].trim();
                this.organisationLabel = labels.length > 1 ? labels[1].trim() : '';
            }
        }

        this.donationOnce = this.donationOnceString ? JSON.parse(this.donationOnceString) : [];
        for (let i = 0; i < this.donationOnce.length; i++) {
            if (this.donationOnce[i].image) this.donationImageKeys.push(this.donationOnce[i].image);
        }

        this.donationMonthly = this.donationMonthlyString ? JSON.parse(this.donationMonthlyString) : [];
        for (let i = 0; i < this.donationMonthly.length; i++) {
            if (this.donationMonthly[i].image) this.donationImageKeys.push(this.donationMonthly[i].image);
        }

        this.donation.type = this.donationFrequency == 'Monthly' ? 'monthly' : 'one-off';
        this.donation.typeLabel = this.donationFrequency;
        this.donation.typeSecondLabel = this.donationFrequency == 'Monthly' ? 'Monthly' : 'One-off';
    }

    renderedCallback() {}

    getStepClass(stepName) {
        return 'donation-form-step' + (this.selectedStep == stepName ? ' active' : '');
    }

    getPaymentTypeClass(type) {
        return 'donation-btn' + (this.donation.type == type ? ' selected' : '');
    }

    getDetailClass(detailType) {
        return 'donation-btn' + (this.detailsType == detailType ? ' selected' : '');
    }

    getIconClass(icon, field) {
        return field ? ' active' : '';
    }

    // -----FIELD HANDLERS----- //

    handleDonationType(evt) {
        this.donation.type = evt.currentTarget.dataset.value;
        this.donation.typeLabel = evt.currentTarget.dataset.value == 'monthly' ? 'monthly' : 'once';
        this.donation.typeSecondLabel = evt.currentTarget.dataset.value == 'monthly' ? 'Monthly' : 'One-off';
        this.donation.amount = null;
        this.donation.otherAmount = null;
        this.donation.viewAmount = null;
        this.dispatchEvent(new CustomEvent("typechange", {detail: {value : this.donation.typeLabel}}));
    }

    handleDonationAmount(evt) {
        this.donation.amount = Number(evt.currentTarget.dataset.value.replace(/,/g, ''));
        this.donation.otherAmount = null;
        this.donation.viewAmount = '$' + evt.currentTarget.dataset.value + ' ';
    }

    handleFieldChange(evt) {
        let fieldName= evt.currentTarget.dataset.name;
        let fieldValue = evt.detail.value;

        if (fieldName == 'other-amount') {
            this.donation.amount = fieldValue;
            this.donation.otherAmount = fieldValue;
            this.donation.viewAmount = '$' + this.donation.amount + ' ';
        }

        if (fieldName == 'organisation' || fieldName == 'first-name' || fieldName == 'last-name') this.reportValidity('.' + fieldName + '-input', '');
        if (fieldName == 'organisation') this.contact.organisation = fieldValue;
        if (fieldName == 'first-name') this.contact.firstName = fieldValue;
        if (fieldName == 'last-name') this.contact.lastName = fieldValue;
        if (fieldName == 'email') {
            this.contact.email = fieldValue;
            this.validateEmail();
        }
        if (fieldName == 'phone') {
            this.contact.phone = fieldValue;
            this.validatePhone();
        }

        if (fieldName == 'is-agree') this.isAgree = fieldValue;
        if (fieldName == 'is-keep-updated') this.isKeepUpdated = fieldValue;
        if (fieldName == 'comments') this.donation.comments = fieldValue;
    }

    handleAddressSelect(evt) {this.isAddressSelected = true;}
    handleAddressType(evt) {this.contact.address = evt.detail.value;}

    handleAddressChange(evt) {
        let options = JSON.parse(evt.detail.value);
        if (options) {
            let componentByType = [];
            if (options.result.address_components) {
                for (let i = 0; i < options.result.address_components.length; i++) {
                    let addressType = options.result.address_components[i].types[0];
                    componentByType[addressType] = addressType == 'administrative_area_level_1' ? options.result.address_components[i].short_name :
                        options.result.address_components[i].long_name;
                }
            }

            this.contact.street = (componentByType['subpremise'] ? componentByType['subpremise'] + '/' : '') + [componentByType['street_number'] || '', componentByType['route'] || ''].join(' ');
            this.contact.city = componentByType['locality'] || componentByType['administrative_area_level_2'];
            this.contact.state = componentByType['administrative_area_level_1'];
            this.contact.postalCode = componentByType['postal_code'];
            this.contact.country = componentByType['country'];
        } else {
            this.contact.street = null;
            this.contact.city = null;
            this.contact.state = null;
            this.contact.postalCode = null;
            this.contact.country = null;
            this.contact.address = '';
            this.isAddressSelected = false;
        }
    }

    handleDetailsType(evt) {
        this.detailsType = evt.currentTarget.dataset.value;
        if (this.detailsType == 'individual') {
            this.contact.organisation = '';
        }
        this.dispatchEvent(new CustomEvent("detailstypechange", {detail: {value : this.detailsType}}));
    }

    // -----BUTTON HANDLERS----- //

    handleNavigation(evt) {
        this.template.querySelector(".donation-form").scrollIntoView({ block: 'start',  behavior: 'smooth' });
        let currentStep = this.selectedStep;
        if ((evt.currentTarget.dataset.name == 'payment' && this.validateDetails()) || evt.currentTarget.dataset.name != 'payment') {
            this.selectedStep = evt.currentTarget.dataset.name;
            this.dispatchEvent(new CustomEvent("stepchange", {detail: {value : this.selectedStep}}));
        }
        if (currentStep == 'amount') this.initStripeIntent();
    }

    handleConfirm(evt) {
        this.isSubmitting = true;
        this.confirmError = null;
        let submit = this.isMontlhy ? this.submitMonthly() : this.submitOnce();

        submit.then(() => {
            this.isSubmitting = false;
            let cookie = {
                "email": this.contact.email,
                "phone": this.contact.phone,
                "total": this.donation.amount,
                "payment_method": this.selectedPaymentMethod,
                "donation_type": this.donation.type,
                "full_name": this.contact.firstName + ' ' + this.contact.lastName,
                "organisation": this.contact.organisation,
                "street": this.contact.street,
                "city": this.contact.city,
                "state": this.contact.state,
                "postalCode": this.contact.postalCode
            };
            this.createCookie('ty_donation', JSON.stringify(cookie));
            this.createCookie('thankYouName', this.detailsType == 'organisation' ? this.contact.organisation : this.contact.firstName + ' ' + this.contact.lastName);
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.thankYouPageURL ? this.thankYouPageURL : 'ty-donation'
                },
            });
        }).catch(error => {
            this.isSubmitting = false;
            this.confirmError = error.message;
        })
    }

    // -----VALIDATORS----- //

    handlePhoneKeydown(evt) {
        var keyCode = evt.which || evt.keyCode || 0;
        var regexp = new RegExp(/^[0-9-]+$/);
        var regexpApostrophe = new RegExp("'");

        if (((evt.metaKey || evt.ctrlKey) && keyCode != 65 && keyCode != 67 && keyCode != 86 && keyCode != 88) ||
            (!evt.metaKey && !evt.ctrlKey && keyCode >= 48 && ! regexp.test(evt.key) && ! regexpApostrophe.test(evt.key))) {
            evt.preventDefault();
        }
    }

    validateDetails() {
        let isPhoneValid = this.validatePhone();
        let isEmailValid = this.validateEmail();

        return (this.detailsType == 'individual' || this.contact.organisation)
                && this.contact.firstName && this.contact.lastName && isPhoneValid
                && isEmailValid && this.isAddressSelected;
    }

    validatePhone() {
        if (this.template.querySelector('.phone-input-inline')) {
            let errorMessage = this.contact.phone ? (this.contact.phone.length == 10 && this.contact.phone.startsWith('0') ? '' : 'Phone format is incorrect' + (! this.contact.phone.startsWith('0') ? " It should start with '0'" : ' Phone must be 10 digits in length')) : 'This field is required';
            this.reportValidity('.phone-input-inline', errorMessage);
            return this.contact.phone && this.contact.phone.length == 10 && this.contact.phone.startsWith('0');
        }
        return false;
    }

    validateEmail() {
        let emailValid = false;
        let errorMessage;
        if (this.template.querySelector('.email-input-inline')) {
            if (this.contact.email) {
                const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                emailValid = this.contact.email.match(emailRegex);
                errorMessage = emailValid ? '' : 'The email address is incorrect';
            } else {
                errorMessage = 'The field is required';
            }
            this.reportValidity('.email-input-inline', errorMessage);
        }

        return emailValid;
    }

    reportValidity(selector, errorMessage) {
        this.template.querySelector(selector).setCustomValidity(errorMessage);
        this.template.querySelector(selector).reportValidity();
    }

    // -----STRIPE FUNCTIONS----- //

    initStripe() {
        let stripeUrl = 'https://js.stripe.com/v3/';
        let script = document.createElement('script');
        script.setAttribute('src', stripeUrl);
        document.head.appendChild(script);
    }

    initStripeIntent() {
        if (this.intents[this.donation.type]) {
            this.selectedIntent = this.intents[this.donation.type];
            this.createStripeElements();
        } else {
            let request = {
                amount: this.donation.amount
            };

            execute({processor: this.isMontlhy ? 'StripeSetupIntentCreationProc' : 'StripePaymentIntentCreationProc', requestJSON: JSON.stringify(request)}).then(result => {
                let response = JSON.parse(result);
                if (!response.isValid) {
                    console.log(response.error);
                } else {
                    this.intents[this.donation.type] = response.dto.intent;
                    this.selectedIntent = response.dto.intent;
                    this.createStripeElements();
                }
            })
            .catch(error => {
                console.log(error);
            })
        }
    }

    createStripeElements() {
        if (!this.stripeClient) this.stripeClient = Stripe(this.stripePublishableKey.data);
        let normalFontLink = PORTAL_RESOURCE + '/css/fonts/Gotham-Light.otf';
        let boldFontLink = PORTAL_RESOURCE + '/css/fonts/GothamMedium.otf';

        const fonts = [
                {
                    family: 'Gotham Book',
                    src: 'url(' + normalFontLink + ')',
                    weight: 'normal'
                },
                {
                    family: 'Gotham Book',
                    src: 'url(' + boldFontLink + ')',
                    weight: 'bold'
                }
            ];
        const appearance = {
            variables: {
                colorPrimary: '#0085CA',
                colorBackground: '#ffffff',
                colorText: '#273048',
                colorDanger: '#C25252',
                fontFamily: 'Gotham Book',
                borderRadius: '5px',
                tabIconHoverColor: '#ffffff'
            },
            rules: {
                '.Input': {
                    border: '1px solid #273048',
                    padding: '20px 30px',
                    fontSize: '20px',
                    boxShadow: 'none'
                },
                '.Input:focus': {
                    border: '2px solid #0085CA',
                    boxShadow: 'none'
                },
                '.Input::placeholder': {
                    color: '9497A2',
                    fontSize: '20px'
                },
                '.Input--invalid': {
                    boxShadow: 'none',
                    border: '2px solid #C25252'
                },
                '.Label': {
                    fontWeight: '700',
                    fontSize: '12px',
                    lineHeight: '18px'
                },
                '.Error': {
                    backgroundColor: '#C25252',
                    fontSize: '10px',
                    lineHeight: '18px',
                    color: 'white',
                    fontWeight: 'bold',
                    borderRadius: '6px',
                    padding: '0px 10px'
                },
                '.Tab': {
                    boxShadow: 'none',
                    color: '#0085CA',
                    fontWeight: 'bold',
                    borderRadius: '10px',
                    backgroundColor: 'transparent'
                },
                '.Tab:hover': {
                    color: '#FFFFFF',
                    backgroundColor: '#0085CA'
                },
                '.Tab--selected': {
                    borderRadius: '15px',
                    border: '4px solid #273048',
                    color: '#FFFFFF',
                    backgroundColor: '#0085CA',
                    boxShadow: 'none',
                },
                '.Tab--selected:hover': {
                    color: '#FFFFFF',
                    backgroundColor: '#0085CA'
                },
                '.Tab--selected:focus': {
                    border: '4px solid #273048',
                    boxShadow: 'none'
                },
                '.TabIcon': {
                    fill: '#0085CA'
                },
                '.TabIcon:hover': {
                    fill: '#FFFFFF'
                },
                '.TabIcon--selected': {
                    fill: '#FFFFFF'
                }
            }
        };

        let that = this;
        this.stripeElements = this.stripeClient.elements({
            clientSecret: this.selectedIntent.client_secret,
            fonts: fonts,
            appearance: appearance
        });
        let paymentElement = this.stripeElements.create('payment', {});

        paymentElement.mount(this.template.querySelector('.payment-element'));

        paymentElement.on('ready', function (event) {
            that.isPaymentReady = true;
        });

        paymentElement.on('change', function (event) {
            let value = event.value;
            that.selectedPaymentMethod = value.type ? PAYMENT_METHODS[value.type] : null;
        });
    }

    submitMonthly() {
        return new Promise((resolve, reject) => {
            let confirmSetup = () => {
                return new Promise((resolve, reject) => {
                    this.stripeClient.confirmSetup({
                        elements: this.stripeElements,
                        redirect: 'if_required'
                    }).then(function (result) {
                        if (result.error) {
                            console.log(result.error);
                            return reject(result.error);
                        } else {
                            return resolve(result);
                        }
                    })
                })
            }

            confirmSetup().then(result => {
                if (result && result.setupIntent && result.setupIntent.payment_method) {
                    let paymentMethodId = result.setupIntent.payment_method;
                    let request = {
                        type: 'Monthly',
                        paymentMethodId: paymentMethodId,
                        amount: this.donation.amount,
                        contact: this.contact,
                        campaignName: this.campaign && this.campaign.data ? this.campaign.data.fields.Name.value : null,
                        comments: this.donation.comments,
                        keepUpdated: this.isKeepUpdated
                    };

                    execute({processor: 'rspcaqldDonationFormSubmitProc', requestJSON: JSON.stringify(request)}).then(result => {
                        console.log(JSON.stringify(result));
                        var response = JSON.parse(result);
                        if (!response.isValid) {
                            return reject(response.error);
                        } else {
                            return resolve(result);
                        }
                    })
                    .catch(error => {
                        return reject(error);
                    })
                }
            }).catch(error => {
                return reject(error);
            });
        })
    }

    submitOnce() {
        return new Promise((resolve, reject) => {
            let request = {
                type: 'Once',
                intentId: this.selectedIntent.id,
                amount: this.donation.amount,
                contact: this.contact,
                campaignName: this.campaign && this.campaign.data ? this.campaign.data.fields.Name.value : null,
                comments: this.donation.comments,
                keepUpdated: this.isKeepUpdated
            };

            execute({processor: 'rspcaqldDonationFormSubmitProc', requestJSON: JSON.stringify(request)}).then(result => {
                let response = JSON.parse(result);
                if (!response.isValid) {
                    return reject(response.error);
                } else {
                    this.stripeClient.confirmPayment({
                        elements: this.stripeElements,
                        redirect: 'if_required'
                    }).then(function (result) {
                        if (result.error) {
                            return reject(result.error);
                        } else {
                            return resolve(result);
                        }
                    }).catch((error) => {
                        return reject(error);
                    });
                }
            }, function (error) {
                return reject(error)
            });
        })
    }

    // -----COOKIE----- //

    createCookie(name, value) {
        document.cookie = name + "=" + encodeURI(value) + "; path=/";
    }
}