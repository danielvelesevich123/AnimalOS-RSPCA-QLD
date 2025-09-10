import getAnimalById from '@salesforce/apex/rspcaqldAnimalService.getAnimalById';
import getPicklistValues from '@salesforce/apex/rspcaqldUtils.getPicklistValues';
import doSubmit from '@salesforce/apex/rspcaqldPageAdoptProcessCtrl.doSubmit';
import {LightningElement, track, wire, api} from 'lwc';
import * as constants from 'c/constants';
import {CurrentPageReference, NavigationMixin} from "lightning/navigation";
import deleteDocument from '@salesforce/apex/rspcaqldUtils.deleteDocument';

export default class RspcaqldPageAdoptProcess extends NavigationMixin(LightningElement) {
    @api thankYouPageURL = 'ty-adopt';
    stepNumber = 1;
    isEOI = false;
    isPopup = false;
    isAddressSelected = false;
    isSubmitting = false;
    isPrivacyPolicyError = false;
    isAdoptionDeclarationError = false;
    enclosureFiles = [];
    scrollList = [0, 137, 252, 463, 638, 844];
    requiredText = constants.requiredText;
    closeWhite = constants.closeWhite;
    pawWhite = constants.pawWhite;
    handHoldingPawWhite = constants.handHoldingPawWhite;
    arrowRightWhite = constants.arrowRightWhite;

    hasChildrenError = false;
    underTwoChildren = 0;
    threeSixChildren = 0;
    sevenTenChildren = 0;
    tenFifteenChildren = 0;
    fifteenPlusChildren = 0;
    hasPetError = false;
    dogPet = 0;
    catPet = 0;
    smallPet = 0;
    birdPet = 0;
    reptilePet = 0;
    farmYardPet = 0;
    otherPet = 0;

    picklistRequiredFields = ['adoptionlocation', 'adoptiontypemulti', 'identificationtype', 'adoptiontimeframe','adoptionreason','adoptionalonehours', 'adoptionresidentialstatus', 'adoptionhaschildren', 'adoptionhaspets'];
    inputRequiredFields = ['petnumber', 'petname', 'firstname', 'lastname', 'secondcontactname', 'adoptionhomelifestyle', 'adoptioncompanionimportance', 'adoptionsuggestionsoptions', 'adoptionresidencetype', 'adoptionanimalhousing', 'adoptionvisitingpets', 'adoptionprevioussurrender'];

    @wire(getPicklistValues, {fieldName: 'Adoption__c.Preferred_Animal_Location__c'}) animalLocations;
    @wire(getPicklistValues, {fieldName: 'Adoption__c.Preferred_Animal_Type__c'}) animalTypes;
    @wire(getPicklistValues, {fieldName: 'Adoption__c.ID_Type__c'}) identificationTypes;
    @wire(getPicklistValues, {fieldName: 'Adoption__c.Adoption_Timeframe__c'}) adoptionTimeframes;
    @wire(getPicklistValues, {fieldName: 'Adoption__c.Adoption_Reason__c'}) adoptionReasons;
    @wire(getPicklistValues, {fieldName: 'Adoption__c.Alone_Hours__c'}) aloneHours;
    @wire(getPicklistValues, {fieldName: 'Adoption__c.Open_to_Suggestions__c'}) openSuggestionsOptions;
    @wire(getPicklistValues, {fieldName: 'Adoption__c.Residential_Status__c'}) residentialStatusOptions;
    @wire(getPicklistValues, {fieldName: 'Adoption__c.Has_Visiting_Pets__c'}) hasVisitingPetsOptions;
    @wire(getPicklistValues, {fieldName: 'Adoption__c.Has_Previously_Surrended__c'}) hasPreviouslySurrendedOptions;
    @wire(getPicklistValues, {fieldName: 'Adoption__c.Has_Children__c'}) hasChildrenOptions;
    @wire(getPicklistValues, {fieldName: 'Adoption__c.Has_Other_Pets__c'}) hasPetsOptions;

    pet = {};
    @track adoption = {
        animalId: null,
        generalEnquiry: 'I have a specific animal in mind',
        animalLocation: '',
        animalType: '',
        preferredAnimalType: '',
        shelterbuddyID: '',
        animalName: '',
        identificationType: '',
        secondContactName: '',
        secondContactPhone: '',
        adoptionTimeframe: '',
        adoptionReason: '',
        aloneHours: '',
        hasChildren: '',
        childrenDetails: 'Under 2 (0), 3-6 years (0), 7-10 years (0), 10-15 years (0), 15+ years (0)',
        homeLifestyle: '',
        companionImportance: '',
        openToSuggest: '',
        residentialStatus: '',
        residenceType: '',
        animalHousing: '',
        fencing: '',
        hasOtherPets: '',
        otherPetsDetails: 'Dog (0), Cat (0), Small Pet (0), Bird (0), Reptile (0), Farm Yard (0), Other (0)',
        hasVisitPets: '',
        otherVisitDetails: '',
        previousPets: '',
        previousSurrended: '',
        previouslySurrendedDetails: '',
        adoptionDeclaration: ''
    };

    @track contact = {
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        address: '',
        street: null,
        state: null,
        city: null,
        postalCode: null,
        country: null,
        birthdate: null
    };

    @track cs = {
        marketingOptIn: false,
        privacyPolicy: false
    };

    steps = [
        {number: 0, icon: null, header: null},
        {number: 1, icon: constants.infoWhite, header: 'Basic details'},
        {number: 2, icon: constants.staffWhite, header: 'Your ID'},
        {number: 3, icon: constants.personWhite, header: 'Getting to know you'},
        {number: 4, icon: constants.shelterWindowWhite, header: 'Living situation'},
        {number: 5, icon: constants.shelterPawprintWhite, header: 'Previous ownership'},
        {number: 6, icon: constants.checklistWhite, header: 'Final checks:'}
    ];

    @wire(CurrentPageReference)
    pageReference({state}) {
        if (state && state.id) {
            this.recordId = state.id;
        } else {
            this.isEOI = true;
        }
    }

    @wire(getAnimalById, {recordId: '$recordId'})
    wiredAnimal({ error, data }) {
        if (data) {
            this.pet = data.record;
            if (this.pet.Id == null) this.isEOI = true;
            this.adoption.animalId = this.pet.Id;
            this.adoption.animalType = this.pet.Animal_Type__c;
            this.adoption.shelterbuddyID = this.pet.Shelterbuddy_ID__c;
            this.adoption.animalName = this.pet.Animal_Name__c;
            this.adoption.animalLocation = this.pet.Location__c;
        }
    }

    // get introStep() {
    //     return this.stepNumber == 0;
    // }

    get isNotEOI() {return !this.isEOI;}

    get isUrgentReport() {
        return this.adoption.generalEnquiry && this.adoption.generalEnquiry == 'I have a specific animal in mind';
    }

    get isInformationReport() {
        return this.adoption.generalEnquiry && this.adoption.generalEnquiry == 'I\'m ready to adopt and want to matched with an animal';
    }

    get basicsStep() {
        return this.stepNumber == 1;
    }

    get idStep() {
        return this.stepNumber == 2;
    }

    get availabilityStep() {
        return this.stepNumber == 3;
    }

    get livingStep() {
        return this.stepNumber == 4;
    }

    get ownershipStep() {
        return this.stepNumber == 5;
    }

    get finalStep() {
        return this.stepNumber == 6;
    }

    get isNavButton() {
        return this.stepNumber < 6;
    }

    get nextLabel() {
        return this.stepNumber < 5 ? 'Next' : 'Review';
    }

    get progressSteps() {
        return [
            {type: this.getProgressStepType(1), class: this.getProgressStepClass(1), name: 'The basics', stepNumber: 1},
            {type: this.getProgressStepType(2), class: this.getProgressStepClass(2), name: 'Your ID', stepNumber: 2},
            {type: this.getProgressStepType(3), class: this.getProgressStepClass(3), name: 'Getting to know you', stepNumber: 3},
            {type: this.getProgressStepType(4), class: this.getProgressStepClass(4), name: 'Living situation', stepNumber: 4},
            {type: this.getProgressStepType(5), class: this.getProgressStepClass(5), name: 'Previous ownership', stepNumber: 5}
        ];
    }

    get reviewStep() {
        return {type: this.getProgressStepType(6), class: this.getProgressStepClass(6), name: 'Review', stepNumber: 6};
    }

    get activeStep() {
        return this.steps[this.stepNumber];
    }

    get isPreviousSurrended() {
        return this.adoption.previousSurrended && this.adoption.previousSurrended == 'Yes';
    }

    get isHasVisitPets() {
        return this.adoption.hasVisitPets && this.adoption.hasVisitPets == 'Yes';
    }

    get isPetIdNumber() {
        return this.adoption.shelterbuddyID ? true : false;
    }

    get isPetName() {
        return this.adoption.animalName ? true : false;
    }

    get isHasChildren() {
        return this.adoption.hasChildren && this.adoption.hasChildren == 'Yes' ? true : false;
    }

    get isHasPets() {
        return this.adoption.hasOtherPets && this.adoption.hasOtherPets == 'Yes' ? true : false;
    }

    get submitBtnClass() {
        return 'green-btn with-icon' + (this.isSubmitting ? ' disabled' : '');
    }

    get editLinkClass() {
        return (this.isSubmitting ? 'disabled' : '');
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

    get backdropClass() {return this.isPopup ? 'backdrop open' : 'backdrop';}

    handleSubmit(evt) {
        if (this.validateStep()) {
            this.isSubmitting = true;

            let _enclosureFiles = this.initSubmitFilesArray(this.enclosureFiles);

            doSubmit({ contactString: JSON.stringify(this.contact),
                caseString: JSON.stringify(this.cs),
                adoptionString: JSON.stringify(this.adoption),
                filesString: JSON.stringify(_enclosureFiles)})
                .then(result => {
                    this.isSubmitting = false;

                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: this.thankYouPageURL ? this.thankYouPageURL : 'ty-adopt'
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

    handleBack(evt) {
        if (this.stepNumber > 1) {
            this.stepNumber--;
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

    validateFields(evt, fieldName) {
        if (this.picklistRequiredFields.includes(fieldName)) {
            this.reportPicklistValidity(fieldName, '');
        } else if (this.inputRequiredFields.includes(fieldName)) {
            this.reportValidity(fieldName, '');
        } else if (fieldName == 'adoptiondeclaration') {
            this.isAdoptionDeclarationError = false;
        } else if (fieldName == 'privacypolicy') {
            this.isPrivacyPolicyError = false;
        } else if (fieldName == 'email') {
            this.validateEmail();
        } else if (fieldName == 'phone' || fieldName == 'secondcontactnumber') {
            this.handlePhoneChange(evt);
        } else if (fieldName == 'birthdate') {
            this.validateBirthdate();
        }
    }

    validateStep() {
        switch (this.stepNumber) {
            case 1:
                let eoiValid = true;
                if (this.isEOI) {
                    this.reportPicklistValidity('adoptionlocation', this.adoption.animalLocation ? '' : constants.requiredText);
                    this.reportPicklistValidity('adoptiontypemulti', this.adoption.preferredAnimalType ? '' : constants.requiredText);
                    eoiValid = this.adoption.animalLocation && this.adoption.preferredAnimalType;
                }

                let isSpecificAnimalValid = true;
                if (this.isUrgentReport) {
                    this.reportValidity('petnumber', this.adoption.shelterbuddyID ? '' : constants.requiredText);
                    this.reportValidity('petname', this.adoption.animalName ? '' : constants.requiredText);
                    isSpecificAnimalValid = this.adoption.shelterbuddyID && this.adoption.animalName;
                }

                this.reportValidity('firstname', this.contact.firstName ? '' : constants.requiredText);
                this.reportValidity('lastname', this.contact.lastName ? '' : constants.requiredText);
                let isEmailValid = this.validateEmail();
                let isBirthdateValid = this.validateBirthdate();
                let isPhoneValid = this.validatePhone('phone', this.contact.phone);

                return eoiValid && isSpecificAnimalValid && this.contact.firstName && this.contact.lastName && this.contact.email && isEmailValid && this.contact.phone && isPhoneValid && this.contact.birthdate && isBirthdateValid;
            case 2:
                this.reportPicklistValidity('identificationtype', this.adoption.identificationType ? '' : constants.requiredText);
                this.reportValidity('secondcontactname', this.adoption.secondContactName ? '' : constants.requiredText);
                let isSecondPhoneValid = this.validatePhone('secondcontactnumber', this.adoption.secondContactPhone);
                this.reportPicklistValidity('googlesearch', ! this.isAddressSelected);

                return this.adoption.identificationType && this.adoption.secondContactName && this.adoption.secondContactPhone && isSecondPhoneValid && this.isAddressSelected;
            case 3:
                this.reportPicklistValidity('adoptiontimeframe', this.adoption.adoptionTimeframe ? '' : constants.requiredText);
                this.reportPicklistValidity('adoptionreason', this.adoption.adoptionReason ? '' : constants.requiredText);
                this.reportPicklistValidity('adoptionalonehours', this.adoption.aloneHours ? '' : constants.requiredText);
                this.reportPicklistValidity('adoptionhaschildren', this.adoption.hasChildren ? '' : constants.requiredText);
                this.reportValidity('adoptionhomelifestyle', this.adoption.homeLifestyle ? '' : constants.requiredText);
                this.reportValidity('adoptioncompanionimportance', this.adoption.companionImportance ? '' : constants.requiredText);
                this.reportValidity('adoptionsuggestionsoptions', this.adoption.openToSuggest ? '' : constants.requiredText);
                let isHasChildren = this.adoption.hasChildren && (this.adoption.hasChildren == 'No' || (this.adoption.hasChildren == 'Yes' && (this.underTwoChildren > 0 || this.threeSixChildren > 0 || this.sevenTenChildren > 0 || this.tenFifteenChildren > 0 || this.fifteenPlusChildren > 0)));
                this.hasChildrenError = this.adoption.hasChildren == 'Yes' && this.underTwoChildren == 0 && this.threeSixChildren == 0 && this.sevenTenChildren == 0 && this.tenFifteenChildren == 0 && this.fifteenPlusChildren == 0;

                return this.adoption.adoptionTimeframe && this.adoption.adoptionReason && this.adoption.aloneHours &&
                    isHasChildren && this.adoption.homeLifestyle && this.adoption.companionImportance  && this.adoption.openToSuggest;
            case 4:
                this.reportPicklistValidity('adoptionresidentialstatus', this.adoption.residentialStatus ? '' : constants.requiredText);
                this.reportValidity('adoptionresidencetype', this.adoption.residenceType ? '' : constants.requiredText);
                this.reportValidity('adoptionanimalhousing', this.adoption.animalHousing ? '' : constants.requiredText);
                this.reportPicklistValidity('adoptionhaspets', this.adoption.hasOtherPets ? '' : constants.requiredText);
                this.reportValidity('adoptionvisitingpets', this.adoption.hasVisitPets ? '' : constants.requiredText);
                let isHasPets = this.adoption.hasOtherPets && (this.adoption.hasOtherPets == 'No' || (this.adoption.hasOtherPets == 'Yes' && (this.dogPet > 0 || this.catPet > 0 || this.smallPet > 0 || this.birdPet > 0 || this.reptilePet > 0 || this.farmYardPet > 0 || this.otherPet > 0)));
                this.hasPetError = this.adoption.hasOtherPets == 'Yes' && this.dogPet == 0 && this.catPet == 0 && this.smallPet == 0 && this.birdPet == 0 && this.reptilePet == 0 && this.farmYardPet == 0 && this.otherPet == 0;

                return this.adoption.residentialStatus && this.adoption.residenceType && this.adoption.animalHousing &&
                    this.adoption.hasVisitPets && isHasPets;
            case 5:
                this.reportValidity('adoptionprevioussurrender', this.adoption.previousSurrended ? '' : constants.requiredText);

                return this.adoption.previousSurrended ? true : false;
            case 6:
                this.isAdoptionDeclarationError = !this.adoption.adoptionDeclaration;
                this.isPrivacyPolicyError = !this.cs.privacyPolicy;

                return this.adoption.adoptionDeclaration && this.cs.privacyPolicy;
            default: return true;
        }
    }

    handleCancelReport(evt) {
        if (document.referrer) {
            window.location.replace(document.referrer);
        } else {
            window.location.reload();
        }

        this.isPopup = false;
    }

    handleContinueReport(evt) {
        this.isPopup = false;
    }

    handlePopupClick(evt) {
        if (evt.target.className == 'pop-up') this.isPopup = false;
    }

    handleAddEnclosureFile(evt) {
        let files = evt.detail.files;
        if (files) {
            this.enclosureFiles = this.enclosureFiles.concat(files);
            this.enclosureFiles = [...this.enclosureFiles];
        }
    }

    handleRemoveEnclosureFile(evt) {
        let fileIndex= evt.currentTarget.dataset.index;

        deleteDocument({ documentId: this.enclosureFiles[fileIndex].contentVersionId});
        this.enclosureFiles.splice(fileIndex, 1);
        this.enclosureFiles = [...this.enclosureFiles];
    }

    handleFieldChange(evt) {
        let fieldName= evt.currentTarget.dataset.name;
        let fieldValue = evt.detail.value;

        if (fieldName == 'petnumber') this.adoption.shelterbuddyID = fieldValue;
        if (fieldName == 'petname') this.adoption.animalName = fieldValue;
        if (fieldName == 'adoptionlocation') this.adoption.animalLocation = fieldValue;
        if (fieldName == 'adoptiontype') this.adoption.animalType = fieldValue;
        if (fieldName == 'adoptiontypemulti') this.adoption.preferredAnimalType = fieldValue;

        if (fieldName == 'firstname') this.contact.firstName = fieldValue;
        if (fieldName == 'lastname') this.contact.lastName = fieldValue;
        if (fieldName == 'email') this.contact.email = fieldValue;
        if (fieldName == 'phone') this.contact.phone = fieldValue;
        if (fieldName == 'birthdate') this.contact.birthdate = fieldValue;

        if (fieldName == 'identificationtype') this.adoption.identificationType = fieldValue;
        if (fieldName == 'secondcontactname') this.adoption.secondContactName = fieldValue;
        if (fieldName == 'secondcontactnumber') this.adoption.secondContactPhone = fieldValue;

        if (fieldName == 'adoptiontimeframe') this.adoption.adoptionTimeframe = fieldValue;
        if (fieldName == 'adoptionreason') this.adoption.adoptionReason = fieldValue;
        if (fieldName == 'adoptionalonehours') this.adoption.aloneHours = fieldValue;
        if (fieldName == 'adoptionhaschildren') this.adoption.hasChildren = fieldValue;
        if (fieldName == 'adoptionhomelifestyle') this.adoption.homeLifestyle = fieldValue;
        if (fieldName == 'adoptioncompanionimportance') this.adoption.companionImportance = fieldValue;
        if (fieldName == 'adoptionsuggestionsoptions') this.adoption.openToSuggest = fieldValue;

        if (fieldName == 'adoptionresidentialstatus') this.adoption.residentialStatus = fieldValue;
        if (fieldName == 'adoptionresidencetype') this.adoption.residenceType = fieldValue;
        if (fieldName == 'adoptionanimalhousing') this.adoption.animalHousing = fieldValue;
        if (fieldName == 'adoptionfencing') this.adoption.fencing = fieldValue;
        if (fieldName == 'adoptionhaspets') this.adoption.hasOtherPets = fieldValue;
        if (fieldName == 'adoptionvisitingpets') {
            this.adoption.hasVisitPets = fieldValue;
            this.adoption.otherVisitDetails = '';
        }
        if (fieldName == 'adoptionvisitpetsdetails') this.adoption.otherVisitDetails = fieldValue;

        if (fieldName == 'previouspets') this.adoption.previousPets = fieldValue;
        if (fieldName == 'adoptionprevioussurrender') {
            this.adoption.previousSurrended = fieldValue;
            this.adoption.previouslySurrendedDetails = '';
        }
        if (fieldName == 'adoptionsurrenderdetails') this.adoption.previouslySurrendedDetails = fieldValue;

        if (fieldName == 'adoptiondeclaration') this.adoption.adoptionDeclaration = fieldValue;
        if (fieldName == 'marketingoptin') this.cs.marketingOptIn = fieldValue;
        if (fieldName == 'privacypolicy') this.cs.privacyPolicy = fieldValue;

        this.validateFields(evt, fieldName);
    }

    handleChildrenChange(evt) {
        this.hasChildrenError = false;
        let fieldName= evt.currentTarget.dataset.name;
        let fieldValue = evt.detail.value;

        if (fieldName == 'under-two') this.underTwoChildren = fieldValue;
        if (fieldName == 'three-six-years') this.threeSixChildren = fieldValue;
        if (fieldName == 'seven-ten-years') this.sevenTenChildren = fieldValue;
        if (fieldName == 'ten-fifteen-years') this.tenFifteenChildren = fieldValue;
        if (fieldName == 'fifteen-plus-years') this.fifteenPlusChildren = fieldValue;

        this.adoption.childrenDetails = 'Under 2 (' + this.underTwoChildren + '), 3-6 years (' + this.threeSixChildren + '), 7-10 years (' + this.sevenTenChildren + '), 10-15 years (' + this.tenFifteenChildren + '), 15+ years (' + this.fifteenPlusChildren + ')';
    }

    handlePetsChange(evt) {
        this.hasPetError = false;
        let fieldName= evt.currentTarget.dataset.name;
        let fieldValue = evt.detail.value;

        if (fieldName == 'dog') this.dogPet = fieldValue;
        if (fieldName == 'cat') this.catPet = fieldValue;
        if (fieldName == 'small-pet') this.smallPet = fieldValue;
        if (fieldName == 'bird') this.birdPet = fieldValue;
        if (fieldName == 'reptile') this.reptilePet = fieldValue;
        if (fieldName == 'farm-yard') this.farmYardPet = fieldValue;
        if (fieldName == 'other-pet') this.otherPet = fieldValue;

        this.adoption.otherPetsDetails = 'Dog (' + this.dogPet + '), Cat (' + this.catPet + '), Small Pet (' + this.smallPet + '), Bird (' + this.birdPet + '), Reptile (' + this.reptilePet + '), Farm Yard (' + this.farmYardPet + '), Other (' + this.otherPet + ')';
    }

    handleReportSelect(evt) {
        this.adoption.generalEnquiry = evt.detail.type == 'urgent' ? 'I have a specific animal in mind' : 'I\'m ready to adopt and want to matched with an animal';
        this.adoption.shelterbuddyID = '';
        this.adoption.animalName = '';
    }

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
            this.isAddressSelected = false;
            this.reportPicklistValidity('googlesearch', true);
        }
    }

    handleAddressSelect(evt) {this.isAddressSelected = true; this.reportPicklistValidity('googlesearch', false);}

    handleAddressType(evt) {this.contact.address = evt.detail.value;}

    handlePhoneChange(evt) {
        this.validatePhone(evt.currentTarget.dataset.name, evt.currentTarget.dataset.name == 'phone' ? this.contact.phone : this.adoption.secondContactPhone);
    }

    validatePhone(fieldName, fieldValue) {
        let errorMessage = fieldValue ? (fieldValue.length == 10 && fieldValue.startsWith('0') ? '' : 'Phone format is incorrect' + (! fieldValue.startsWith('0') ? " It should start with '0'" : ' Phone must be 10 digits in length')) : constants.requiredText;
        this.reportValidity(fieldName, errorMessage);
        return fieldValue && fieldValue.length == 10 && fieldValue.startsWith('0');
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
                errorMessage = 'The field is required';
            }
            this.reportValidity('email', errorMessage);
        }

        return emailValid;
    }

    validateBirthdate() {
        let errorMessage;
        let birthdateValid = false;

        this.reportValidity('birthdate', '');
        let isDateValid = this.template.querySelector('[data-name="birthdate"]').checkValidity();

        if (isDateValid) {
            let today = new Date();
            let birthdate = new Date(this.contact.birthdate);
            let yearDifference = today.getFullYear() - birthdate.getFullYear();
            let monthDifference = today.getMonth() - birthdate.getMonth();
            let dayDifference = today.getDate() - birthdate.getDate();

            birthdateValid = yearDifference > 18 || (yearDifference == 18 && (monthDifference > 0 || (monthDifference == 0 && dayDifference >= 0)));
            errorMessage = birthdateValid ? '' : 'You must be 18 years old to adopt, ID is required';
            this.reportValidity('birthdate', errorMessage);
        }

        return birthdateValid;
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