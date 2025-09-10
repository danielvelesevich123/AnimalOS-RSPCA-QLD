import getImage from '@salesforce/apex/ManagedContentService.getImageByContentKey';
import {api, LightningElement, wire} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldSectionDonate extends LightningElement {
    @api customMetadata = 'Main';
    @api customClass;
    @api isHeader = false;
    @api headerType = 'First';
    @api headerImage;
    @api header;
    @api description;
    @api icon;
    @wire(getImage, {contentKey: '$icon'}) iconURL;
    @api pawPrintLabel;
    @wire(getImage, {contentKey: '$imageKey'}) imageContentURL;
    @api underHeaderText;
    @api underHeaderInformationString;

    @api donationStep = 'amount';
    @api donationType = 'monthly';
    @api donationDetailsType = 'individual';
    @api campaignId;
    @api donationFrequencyPrompt = 'I’d like to make this donation:';
    @api donationAmountPrompt = 'Please select a donation amount';
    @api detailsHeaderPrompt = 'Your details';
    @api individualOrganisationSelector = 'Individual | Organisation';
    @api organisationNamePrompt = 'Select';
    @api firstNamePrompt = 'Select';
    @api lastNamePrompt = 'Select';
    @api emailAddressPrompt = 'Select';
    @api mobilePrompt = 'Select';
    @api addressPrompt = 'Please enter your street address';
    @api paymentMethodPrompt = 'Payment method:';
    @api additionalInfoLabel = 'Additional Info';
    @api additionalInfoPrompt= 'You can leave us a personal message, or any instructions here (optional).'
    @api termsConditionsText;
    @api newsletterSubscriptionText;
    @api submissionConsentText = 'By submitting this form, you agree to RSPCA Queensland’s <b>Privacy Policy</b> & <b>Terms & Conditions</b>';
    @api thankYouPageURL = 'ty-donation';

    @api donationFrequency = 'Monthly';
    @api donationOnceString;
    @api donationMonthlyString;

    @api donationButtonColor;
    @api donationButtonFontColor;
    @api donationButtonIcon;
    @api paymentButtonText = 'Payment options';
    @api paymentButtonColor;
    @api paymentButtonFontColor;
    @api paymentButtonIcon;
    @api confirmButtonText = 'Confirm and Submit';
    @api confirmButtonColor;
    @api confirmButtonFontColor;
    @api confirmButtonIcon;

    imageKey;
    topleftWedge = constants.topleftWedge;
    bottomrightWedge = constants.bottomrightWedge;

    get containerClass() {return 'section-donate ' + (this.isHeader ? 'header-type ' : 'form-type ') + this.donationStep + ' ' + this.donationType + ' ' + this.donationDetailsType;}

    get pageHeaderClass() {
        return 'page-header ' + (this.headerType == 'First' ? 'first-type' : 'second-type');
    }

    get sectionClass() {
        return 'page-cta-form' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get pawPrint() {
        return this.pawPrintLabel ? constants[this.pawPrintLabel.split(' ')[0].toLowerCase() + this.pawPrintLabel.split(' ')[1] + 'Paw'] : null;
    }
    get pawPrintClass() {
        return 'paw-print' + (this.pawPrintLabel ? (this.pawPrintLabel == 'Official RSPCA Left' ? '' : ' paw-right') : null);
    }
    get isHidePawPrint() {return this.pawPrint ? false : true;}

    get isSecondHeaderType() {return this.headerType == 'Second' ? true : false;}

    get underHeaderInformationClass() {
        return 'underheader-info' + (this.underHeaderText || this.underHeaderInformationString ? '' : ' empty-underheader');
    }

    get backgroundStyle() {
        return 'background: lightgray 50% / cover url(' + this.image + ');';
    }

    get underHeaderInformationLines() {
        return this.underHeaderInformationString ? JSON.parse(this.underHeaderInformationString) : null;
    }

    get image() {
        if (this.headerImage) {
            if (!this.headerImage.includes('http') && !this.headerImage.includes('jpeg') && !this.headerImage.includes('jpg') && !this.headerImage.includes('png')) {
                this.imageKey = this.headerImage;
                return this.imageContentURL.data;
            } else {
                return this.image;
            }
        }
        return '';
    }

    handleStepChange(evt) {
        this.donationStep = evt.detail.value;
    }

    handleTypeChange(evt) {
        this.donationType = evt.detail.value;
    }

    handleDetailsTypeChange(evt) {
        this.donationDetailsType = evt.detail.value;
    }
}