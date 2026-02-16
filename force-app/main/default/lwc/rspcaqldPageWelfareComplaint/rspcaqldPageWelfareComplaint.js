import {api, LightningElement, track, wire} from 'lwc';
import * as constants from 'c/constants';
import {NavigationMixin} from "lightning/navigation";
export default class RspcaqldPageWelfareComplaint extends NavigationMixin(LightningElement) {
    @api header;
    @api headerHeight;
    @api description;
    @api buttonColor;
    @api buttonLabel;
    @api buttonLabelColor;
    @api imageUrl;
    @api imageKey;
    @api imageHeight;
    @api pawPrintLabel;
    @api thankYouPageURL = 'ty-report';

    stepNumber = 0;
    parentId = '';
    locationFiles = [];
    files = [];
    isPopup = false;
    isUrgentPopup = false;
    isAgePopup = false;
    isPrivacyPolicyError = false;
    isWelfareDeclarationError = false;
    isSubmitting = false;
    isTimeExists = false;
    isLastSeenTimeExists = false;

    closeWhite = constants.closeWhite;
    triangleExclamationWhite = constants.triangleExclamationWhite;
    triangleExclamationRed = constants.triangleExclamationRed;
    flagWhite = constants.flagWhite;
    requiredText = constants.requiredText;

    picklistRequiredFields = ['poiagedeclaration', 'locationstate'];
    inputRequiredFields = ['firstname','lastname','locationstreet','locationcity','directions','observations','animaldescription','animalsnumber'];

    poiAgeDeclarations = { data: [] };
    personInterestOptions = { data: [] };
    locationStates = { data: [] };
    @track contact = {
        title: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        alternatePhone: '',
        address: '',
        street: null,
        state: null,
        city: null,
        postalCode: null,
        country: null
    };

    @track cs = {
        priority: 'information',
        marketingOptIn: false,
        privacyPolicy: false
    };

    @track welfareReport = {
        welfareDeclaration: false,
        poiAgeDeclaration: '',
        firstName: '',
        lastName: '',
        establishmentName: '',
        personOfInterest: '',
        locationHouseNumber: '',
        locationStreet: '',
        locationCity: '',
        locationState: '',
        locationPostcode: '',
        geolocation: '',
        poiDescription: '',
        inspectorHazard: '',
        date: '',
        time: '',
        directions: '',
        observations: '',
        animalsNumber: null,
        animalDescription: '',
        injuries: '',
        lastSeenDate: '',
        lastSeenTime: ''
    };

    steps = [
        {number: 0, icon: null, header: null},
        {number: 1, icon: constants.infoWhite, header: 'Type of complaint'},
        {number: 2, icon: constants.personWhite, header: 'Your contact details'},
        {number: 3, icon: constants.locationWhite, header: 'Who and where'},
        {number: 3, icon: constants.questionMarkWhite, header: 'What and when'},
        {number: 4, icon: constants.pawWhite, header: 'Animal descriptions & photos'},
        {number: 5, icon: constants.checklistWhite, header: 'Review and submit'}
    ];

    scrollList = [0, 193, 400, 583, 765, 1042];

    arrowRightWhite = constants.arrowRightWhite;

    get introStep() {
        return this.stepNumber == 0;
    }
    get basicsStep() {
        return this.stepNumber == 1;
    }

    get personStep() {
        return this.stepNumber == 2;
    }

    get whoWhereStep() {
        return this.stepNumber == 3;
    }

    get whatWhenStep() {
        return this.stepNumber == 4;
    }

    get isUrgentReport() {
        return this.cs.priority && this.cs.priority == 'urgent';
    }

    get isInformationReport() {
        return this.cs.priority && this.cs.priority == 'information';
    }

    get animalStep() {
        return this.stepNumber == 5;
    }

    get reviewStep() {
        return this.stepNumber == 6;
    }

    get isNavButton() {
        return this.stepNumber < 6;
    }

    get isReport() {
        return this.cs.priority ? true : false;
    }

    get progressSteps() {
        return [
            {type: this.getProgressStepType(1), class: this.getProgressStepClass(1), name: 'Type of complaint', stepNumber: 1},
            {type: this.getProgressStepType(2), class: this.getProgressStepClass(2), name: 'Your contact details', stepNumber: 2},
            {type: this.getProgressStepType(3), class: this.getProgressStepClass(3), name: 'Who and where', stepNumber: 3},
            {type: this.getProgressStepType(4), class: this.getProgressStepClass(4), name: 'What and when', stepNumber: 4},
            {type: this.getProgressStepType(5), class: this.getProgressStepClass(5), name: 'Animal descriptions & photos', stepNumber: 5},
            {type: this.getProgressStepType(6), class: this.getProgressStepClass(6), name: 'Review and submit', stepNumber: 6}
       ];
    }

    get activeStep() {
        return this.steps[this.stepNumber];
    }

    getProgressStepType(step) {
        return this.stepNumber < step ? 'Incomplete' : (this.stepNumber == step ? 'Active' : 'Complete');
    }

    getProgressStepClass(step) {
        return 'normal' + (this.stepNumber == step ? ' active' : '');
    }

    get popupClass() {
        return 'page-form-page-popup pop-up-container' + (this.isPopup ? ' active' : '');
    }

    get urgentPopupClass() {
        return 'page-form-page-popup pop-up-container' + (this.isUrgentPopup ? ' active' : '');
    }

    get agePopupClass() {
        return 'page-form-page-popup pop-up-container' + (this.isAgePopup ? ' active' : '');
    }

    get backdropClass() {return this.isPopup || this.isUrgentPopup || this.isAgePopup ? 'backdrop open' : 'backdrop';}

    get nextLabel() {
        return this.stepNumber < 5 ? 'Next' : 'Review details';
    }

    get submitBtnClass() {
        return 'green-btn with-icon' + (this.isSubmitting ? ' disabled' : '');
    }

    get editLinkClass() {
        return (this.isSubmitting ? 'disabled' : '');
    }

    get finalCardIcon() {return this.isUrgentReport ? this.triangleExclamationWhite : this.flagWhite;}

    handleBack(evt) {
        if (this.stepNumber > 1) {
            this.stepNumber--;
            if (this.template.querySelector(".mobile-navigation")) {
                this.template.querySelector(".mobile-navigation").scrollLeft = this.scrollList[this.stepNumber - 1];
            }
            window.scrollTo({
                top: 0,
                behavior: 'smooth',
            });
        } else {
            this.isPopup = true;
        }
    }

    handleNext(evt) {
        if (this.validateStep()) {
            let isNext = false;
            if (this.stepNumber == 1) {
                if (this.cs.priority == 'information') {
                    if (this.welfareReport.poiAgeDeclaration == 'No') {
                        this.isAgePopup = true;
                    } else {
                        isNext = true;
                    }
                } else {
                    this.isUrgentPopup = true;
                }
            } else {
                isNext = true;
            }

            if (isNext) {
                this.stepNumber++;
                if (this.template.querySelector(".mobile-navigation")) {
                    this.template.querySelector(".mobile-navigation").scrollLeft = this.scrollList[this.stepNumber - 1];
                }
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth',
                });
            }
        }
    }

    handleSubmit(evt) {
        if (this.validateStep()) {
            this.isSubmitting = true;

            let _files = this.initSubmitFilesArray(this.files);
            let _locationFiles = this.initSubmitFilesArray(this.locationFiles);

            doSubmit({ contactString: JSON.stringify(this.contact),
                              caseString: JSON.stringify(this.cs),
                              welfareString: JSON.stringify(this.welfareReport),
                              filesString: JSON.stringify(_files),
                              locationFilesString: JSON.stringify(_locationFiles)})
                .then(result => {
                    this.parentId = result;
                    this.isSubmitting = false;

                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: this.thankYouPageURL ? this.thankYouPageURL : 'ty-report'
                        },
                    });
                })
                .catch(error => {
                    this.isSubmitting = false;
                    console.log(error);
                })
        }
    }

    initSubmitFilesArray(submitFiles) {
        let _files = [];
        for (let i = 0; i < submitFiles.length; i++) {
            _files.push({
                name : submitFiles[i].name,
                contentVersionId : submitFiles[i].contentVersionId,
            });
        }
        return _files;
    }

    validateFields(fieldName) {
        if (this.picklistRequiredFields.includes(fieldName)) {
            this.reportPicklistValidity(fieldName, '');
        } else if (this.inputRequiredFields.includes(fieldName)) {
            this.reportValidity(fieldName, '');
        } else if (fieldName == 'privacypolicy') {
            this.isPrivacyPolicyError = false;
        } else if (fieldName == 'email') {
            this.validateEmail();
        } else if (fieldName == 'phone') {
            this.validateMainPhone();
        } else if (fieldName == 'alternatephone') {
            this.validateAlternatePhone();
        } else if (fieldName == 'locationpostcode') {
            this.validatePostcode();
        }
    }

    validateStep() {
        switch (this.stepNumber) {
            case 1:
                this.isWelfareDeclarationError = !this.welfareReport.welfareDeclaration;
                this.reportPicklistValidity('poiagedeclaration', this.welfareReport.poiAgeDeclaration ? '' : constants.requiredText);

                return this.welfareReport.welfareDeclaration && this.welfareReport.poiAgeDeclaration;
            case 2:
                this.reportValidity('firstname', this.contact.firstName ? '' : constants.requiredText);
                this.reportValidity('lastname', this.contact.lastName ? '' : constants.requiredText);
                let isEmailValid = this.validateEmail();
                let isPhoneValid = this.validateMainPhone();
                let isAlternatePhoneValid = this.contact.alternatePhone ? this.validateAlternatePhone() : true;

                return this.contact.firstName && this.contact.lastName && this.contact.email && isEmailValid && this.contact.phone && isPhoneValid && isAlternatePhoneValid;
            case 3:
                this.reportValidity('locationstreet', this.welfareReport.locationStreet ? '' : constants.requiredText);
                this.reportValidity('locationcity', this.welfareReport.locationCity ? '' : constants.requiredText);
                this.reportPicklistValidity('locationstate', this.welfareReport.locationState ? '' : constants.requiredText);
                let isPostcodeValid = this.validatePostcode();

                return this.welfareReport.locationStreet && this.welfareReport.locationCity && this.welfareReport.locationState && isPostcodeValid;
            case 4:
                this.reportValidity('directions', this.welfareReport.directions ? '' : constants.requiredText);
                this.reportValidity('observations', this.welfareReport.observations ? '' : constants.requiredText);
                let isDateValid = this.validateDate(this.welfareReport.date, 'date');
                let isTimeValid = this.welfareReport.time ? this.validateTime(this.welfareReport.time, 'time') : true;
                this.isTimeExists = this.welfareReport.time ? true : false;

                return this.welfareReport.date && this.welfareReport.directions && this.welfareReport.directions && this.welfareReport.observations && isDateValid && isTimeValid;
            case 5:
                this.reportValidity('animalsnumber', this.welfareReport.animalsnumber ? '' : constants.requiredText);
                this.reportValidity('animaldescription', this.welfareReport.animalDescription ? '' : constants.requiredText);
                let isLastSeenDateValid = this.validateDate(this.welfareReport.lastSeenDate, 'lastseendate');
                let isLastSeenTimeValid = this.welfareReport.lastSeenTime ? this.validateTime(this.welfareReport.lastSeenTime, 'lastseentime') : true;
                this.isLastSeenTimeExists = this.welfareReport.lastSeenTime ? true : false;

                return this.welfareReport.animalsNumber && this.welfareReport.animalDescription && this.welfareReport.lastSeenDate && isLastSeenDateValid && isLastSeenTimeValid;
            case 6:
                this.isPrivacyPolicyError = !this.cs.privacyPolicy;

                return this.cs.privacyPolicy;
            default: return true;
        }
    }

    handleReportSelect(evt) {
        this.cs.priority = evt.detail.type;
    }

    handleMobileStep(evt) {
        if ((Number(evt.currentTarget.dataset.step) > this.stepNumber && this.validateStep()) || Number(evt.currentTarget.dataset.step) < this.stepNumber) {
            this.stepNumber = Number(evt.currentTarget.dataset.step);
            this.template.querySelector(".mobile-navigation").scrollLeft = this.scrollList[this.stepNumber - 1];
            window.scrollTo({
                top: 0,
                behavior: 'smooth',
            });
        }
    }

    handleEditStep(evt) {
        this.stepNumber = Number(evt.currentTarget.dataset.step);
        if (this.template.querySelector(".mobile-navigation")) {
            this.template.querySelector(".mobile-navigation").scrollLeft = this.scrollList[this.stepNumber - 1];
        }
        window.scrollTo({
            top: 0,
            behavior: 'smooth',
        });
    }

    handleCancelReport(evt) {
        this.stepNumber--;
        window.scrollTo({
            top: 0,
            behavior: 'smooth',
        });
        this.isPopup = false;
        this.files = [];
        this.locationFiles = [];

        this.cs = {
            priority: 'information',
            marketingOptIn: false,
            privacyPolicy: false
        };

        this.welfareReport = {
            welfareDeclaration: false,
            poiAgeDeclaration: '',
            firstName: '',
            lastName: '',
            establishmentName: '',
            personOfInterest: '',
            locationHouseNumber: '',
            locationStreet: '',
            locationCity: '',
            locationState: '',
            locationPostcode: '',
            geolocation: '',
            poiDescription: '',
            inspectorHazard: '',
            date: '',
            time: '',
            directions: '',
            observations: '',
            animalsNumber: null,
            animalDescription: '',
            injuries: '',
            lastSeenDate: '',
            lastSeenTime: ''
        };

        this.contact = {
            title: '',
            firstName: '',
            lastName: '',
            email: '',
            phone: '',
            alternatePhone: '',
            address: '',
            street: null,
            state: null,
            city: null,
            postalCode: null,
            country: null
        };
    }

    handleContinueReport(evt) {
        this.isPopup = false;
        this.isUrgentPopup = false;
        this.isAgePopup = false;
    }

    handlePopupClick(evt) {
        if (evt.target.className == 'pop-up') {
            let popupName= evt.currentTarget.dataset.name;
            if (popupName == 'cancel-popup') this.isPopup = false;
            if (popupName == 'urgent-popup') this.isUrgentPopup = false;
            if (popupName == 'age-popup') this.isAgePopup = false;
        }
    }

    handleAddLocationFile(evt) {
        let files = evt.detail.files;
        if (files) {
            this.locationFiles = this.locationFiles.concat(files);
            this.locationFiles = [...this.locationFiles];
        }
    }

    handleRemoveLocationFile(evt) {
        let fileIndex= evt.currentTarget.dataset.index;

        deleteDocument({ documentId: this.locationFiles[fileIndex].contentVersionId});
        this.locationFiles.splice(fileIndex, 1);
        this.locationFiles = [...this.locationFiles];
    }

    handleAddFile(evt) {
        let files = evt.detail.files;
        if (files) {
            this.files = this.files.concat(files);
            this.files = [...this.files];
        }
    }

    handleRemoveFile(evt) {
        let fileIndex= evt.currentTarget.dataset.index;
        deleteDocument({ documentId: this.files[fileIndex].contentVersionId});
        this.files.splice(fileIndex, 1);
        this.files = [...this.files];
    }

    handleFieldChange(evt) {
        let fieldName= evt.currentTarget.dataset.name;
        let fieldValue = evt.detail.value;

        if (fieldName == 'poiagedeclaration') this.welfareReport.poiAgeDeclaration = fieldValue;
        if (fieldName == 'welfaredeclaration') {
            this.welfareReport.welfareDeclaration = fieldValue;
            this.isWelfareDeclarationError = !this.welfareReport.welfareDeclaration;
        }
        if (fieldName == 'personfirstname') this.welfareReport.firstName = fieldValue;
        if (fieldName == 'personlastname') this.welfareReport.lastName = fieldValue;
        if (fieldName == 'establishmentname') this.welfareReport.establishmentName = fieldValue;
        if (fieldName == 'personofinterest') this.welfareReport.personOfInterest = fieldValue;

        if (fieldName == 'locationhouse') this.welfareReport.locationHouseNumber = fieldValue;
        if (fieldName == 'locationstreet') this.welfareReport.locationStreet = fieldValue;
        if (fieldName == 'locationcity') this.welfareReport.locationCity = fieldValue;
        if (fieldName == 'locationstate') this.welfareReport.locationState = fieldValue;
        if (fieldName == 'locationpostcode') this.welfareReport.locationPostcode = fieldValue;
        if (fieldName == 'geolocation') this.welfareReport.geolocation = fieldValue;
        if (fieldName == 'poidescription') this.welfareReport.poiDescription = fieldValue;
        if (fieldName == 'inspectorhazard') this.welfareReport.inspectorHazard = fieldValue;

        if (fieldName == 'date') {
            this.welfareReport.date = fieldValue;
            this.validateDate(this.welfareReport.date, 'date');
        }
        if (fieldName == 'time') {
            this.welfareReport.time = fieldValue;
            this.validateTime(this.welfareReport.time, 'time');
        }
        if (fieldName == 'directions') this.welfareReport.directions = fieldValue;
        if (fieldName == 'observations') this.welfareReport.observations = fieldValue;

        if (fieldName == 'animalsnumber') this.welfareReport.animalsNumber = fieldValue;
        if (fieldName == 'animaldescription') this.welfareReport.animalDescription = fieldValue;
        if (fieldName == 'injuries') this.welfareReport.injuries = fieldValue;
        if (fieldName == 'lastseendate') {
            this.welfareReport.lastSeenDate = fieldValue;
            this.validateDate(this.welfareReport.lastSeenDate, 'lastseendate');
        }
        if (fieldName == 'lastseentime') {
            this.welfareReport.lastSeenTime = fieldValue;
            this.validateTime(this.welfareReport.lastSeenTime, 'lastseentime');
        }

        if (fieldName == 'firstname') this.contact.firstName = fieldValue;
        if (fieldName == 'lastname') this.contact.lastName = fieldValue;
        if (fieldName == 'email') this.contact.email = fieldValue;
        if (fieldName == 'phone') this.contact.phone = fieldValue;
        if (fieldName == 'alternatephone') this.contact.alternatePhone = fieldValue;

        if (fieldName == 'marketingoptin') this.cs.marketingOptIn = fieldValue;
        if (fieldName == 'privacypolicy') this.cs.privacyPolicy = fieldValue;

        this.validateFields(fieldName)
    }

    // handleAnimalNumberChange(evt) {
    //     this.welfareReport.animalsNumber = evt.detail.value;
    // }

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
            this.contact.address = this.contact.street + ' ' + this.contact.city + ' ' + this.contact.state + ' ' + this.contact.postalCode;
        } else {
            this.contact.street = null;
            this.contact.city = null;
            this.contact.state = null;
            this.contact.postalCode = null;
            this.contact.country = null;
            this.contact.address = '';
        }
    }

    handleAddressSelect(evt) {this.isAddressSelected = true;}

    handleAddressType(evt) {this.contact.address = evt.detail.value;}

    // uploadFiles() {
    //
    //     uploadFiles({prefix: '[Enclosure]', parentId: this.parentId, filesString: JSON.stringify(this.files)}).then(result => {
    //         uploadFiles({prefix: '[Location]', parentId: this.parentId, filesString: JSON.stringify(this.locationFiles)}).then(result => {
    //             this.isSubmitting = false;
    //
    //             this[NavigationMixin.Navigate]({
    //                 type: 'standard__webPage',
    //                 attributes: {
    //                     url: 'ty-report'
    //                 },
    //             });
    //         })
    //         .catch(error => {
    //             this.isSubmitting = false;
    //             console.log(error);
    //         })
    //     })
    //     .catch(error => {
    //         this.isSubmitting = false;
    //         console.log(error);
    //     })
    // }

    validateMainPhone() {
        let fieldValue = this.contact.phone;
        let errorMessage = fieldValue ? (fieldValue.length == 10 && fieldValue.startsWith('0') ? '' : 'Phone format is incorrect' + (! fieldValue.startsWith('0') ? " It should start with '0'" : ' Phone must be 10 digits in length')) : constants.requiredText;
        this.reportValidity('phone', errorMessage);
        return fieldValue && fieldValue.length == 10 && fieldValue.startsWith('0');
    }

    validateAlternatePhone() {
        let fieldValue = this.contact.alternatePhone;
        let errorMessage = fieldValue ? (fieldValue.length == 10 && fieldValue.startsWith('0') ? '' : 'Phone format is incorrect' + (! fieldValue.startsWith('0') ? " It should start with '0'" : ' Phone must be 10 digits in length')) : '';
        this.reportValidity('alternatephone', errorMessage);
        return fieldValue.length == 10 && fieldValue.startsWith('0');
    }

    validateEmail() {
        let emailValid = false;
        let errorMessage;
        if (this.template.querySelector('[data-name="email"]')) {
            if (this.contact.email) {
                const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                emailValid = this.contact.email.match(emailRegex);
                errorMessage = emailValid ? '' : 'The email address is incorrect';
            } else {
                errorMessage = constants.requiredText;
            }
            this.reportValidity('email', errorMessage);
        }

        return emailValid;
    }

    validateDate(dateStr, selector) {
        let errorMessage;
        let dateValid = false;

        this.reportValidity(selector, '');
        let isDateValid = this.template.querySelector('[data-name=' + selector + ']').checkValidity();
        if (isDateValid) {
            let today = new Date();
            let dt = new Date(dateStr);

            dateValid = today.getFullYear() > dt.getFullYear() || (today.getFullYear() == dt.getFullYear() && (today.getMonth() > dt.getMonth() || (today.getMonth() == dt.getMonth() && today.getDate() >= dt.getDate())));
            errorMessage = dateValid ? '' : 'The date is incorrect, the value cannot be in the future';
            this.reportValidity(selector, errorMessage);
        }

        return dateValid;
    }

    validateTime(timeStr, selector) {
        var regex12 = /^([0]\d|[1][0-2]):([0-5]\d)\s?(?:AM|PM)$/i;
        // var regex24 = /^([0-1]?[0-9]|2[0-4]):([0-5][0-9])(:[0-5][0-9])?$/;
        let errorMessage = ''
        if (timeStr && !regex12.test(timeStr)) errorMessage = 'The time format is incorrect';
        this.reportValidity(selector, errorMessage);
        return regex12.test(timeStr);
    }

    validatePostcode() {
        let errorMessage = this.welfareReport.locationPostcode ? (this.welfareReport.locationPostcode.length == 4 ? '' : 'This field must have 4 digits') : constants.requiredText;
        this.reportValidity('locationpostcode', errorMessage);
        return errorMessage.length == 0;
    }

    reportValidity(selector, errorMessage) {
        this.template.querySelector('[data-name="' + selector + '"]').setCustomValidity(errorMessage);
        this.template.querySelector('[data-name="' + selector + '"]').reportValidity();
    }

    reportPicklistValidity(fieldName, hasError) {
        this.template.querySelector('[data-name="' + fieldName + '"]').hasError = hasError;
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
}