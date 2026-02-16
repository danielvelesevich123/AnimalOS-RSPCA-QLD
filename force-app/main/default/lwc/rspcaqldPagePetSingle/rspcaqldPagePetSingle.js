import {api, LightningElement, wire} from 'lwc';
import PORTAL_RESOURCE from '@salesforce/resourceUrl/PortalResource';
import {MessageContext} from 'lightning/messageService';
import * as constants from 'c/constants';
import {CurrentPageReference, NavigationMixin} from "lightning/navigation";
import ToastContainer from 'lightning/toastContainer';
import Toast from 'lightning/toast';

export default class RspcaqldPagePetSingle extends NavigationMixin(LightningElement) {
    @api adoptLinkUrl = 'adopt-process';
    @api faqsString;
    @api faqsLinkUrl;
    @api dogFaqsString;
    @api dogFaqsLinkUrl;
    @api puppyFaqsString;
    @api puppyFaqsLinkUrl;
    @api catFaqsString;
    @api catFaqsLinkUrl;
    @api kittenFaqsString;
    @api kittenFaqsLinkUrl;
    @api farmyardFaqsString;
    @api farmyardFaqsLinkUrl;
    @api reptileFaqsString;
    @api reptileFaqsLinkUrl;
    @api smallanimalFaqsString;
    @api smallanimalFaqsLinkUrl;
    @api birdFaqsString;
    @api birdFaqsLinkUrl;
    @api howApplicationHeader = 'How your application works';
    @api howApplicationDescription = '*If you are interested in any animals that are located at PetBarn, World For Pets or RSPCA Op Shops you can visit the store direct.';
    @api howApplicationCards = '[{ "icon": "fa-solid fa-quote-right", "header": "If you match", "description": "You will be shortlisted and contacted via phone to discuss the animal in detail.", "subdescription": "This may include exchange of additional photos, a video link and/or live stream conversation.", "link": "#" },{ "icon": "fa-solid fa-hourglass-clock", "header": "Decision timeframe", "description": "This will be a timeline to make your decision.", "subdescription": "This may include exchange of additional photos, a video link and/or live stream conversation.", "link": "#" },{ "icon": "fa-solid fa-credit-card", "header": "If you’re happy to proceed", "description": "The adoption will be processed and payment will be taken over the phone.", "subdescription": "This may include exchange of additional photos, a video link and/or live stream conversation.", "link": "#" },{ "icon": "fa-solid fa-calendar-heart", "header": "Collection time", "description": "A meeting and collection time and date will be decided upon.", "subdescription": "This may include exchange of additional photos, a video link and/or live stream conversation.", "link": "#" }]';
    @api relatedArticlesKeys;
    @api relatedArticlesHeader = 'Adopting a pet';
    @api relatedArticlesDescription = 'Caring for your pet - get tips and advice about being a responsible pet owner.';
    @api relatedArticlesLinkLabel = 'View all articles';
    @api relatedArticlesLinkUrl = 'pet-care';
    @api catBonusOfferString;
    @api dogBonusOfferString;
    @api upsellString;
    @api puppyUpsellString;
    @api catUpsellString;
    @api kittenUpsellString;
    @api farmyardUpsellString;
    @api smallanimalUpsellString;
    @api birdUpsellString;

    @wire(CurrentPageReference)
    pageReference({state}) {if (state && state.id) this.recordId = state.id;}

    recordId;
    animal = {};
    otherAnimals = [];
    privateImages;
    selectedHeaderIndex;
    selectedHeaderImage;
    selectedLighboxHeaderIndex = 0;
    selectedLighboxHeaderImage;
    selectedNavTab = 'overview';
    isShareOpen = false;
    isSupplyID = false;
    // selectedDiaryIndex = 0;
    // selectedDiaryImage;

    dnaWhite = constants.dnaWhite;
    genderWhite = constants.genderWhite;
    birthdayCakeWhite = constants.birthdayCakeWhite;
    sizeWhite = constants.sizeWhite;
    locationWhite = constants.locationWhite;
    priceTagWhite = constants.priceTagWhite;
    shelterHeartWhite = constants.shelterHeartWhite;
    bottomrightWedge = constants.bottomrightWedge;
    officialRSPCAPaw = constants.officialRSPCAPaw;
    arrowRightWhite = constants.arrowRightWhite;
    arrowRightBlue = constants.arrowRightBlue;
    closeWhite = constants.closeWhite;
    envelopeWhite = constants.envelopeWhite;
    messengerWhite = constants.messengerWhite;
    shareImageURL = PORTAL_RESOURCE + '/img/share.png';

    get adoptBackgroundStyle() {
        return 'background: lightgray 50% / cover url(' + this.animal.Web_Hero_Image_URL__c + ');';
    }

    get checks() {
        return [
            {label: 'Vet checked', value: true},
            {label: 'Vaccinations are up-to-date', value: this.animal.Vaccinated__c},
            {label: 'Worming is up-to-date', value: true},
            {label: 'Desexed', value: this.animal.Spayed_Neutered__c && this.animal.Spayed_Neutered__c === 'Yes'},
            {label: 'Microchipped', value: this.animal.Spayed_Neutered__c && this.animal.Microchipped__c === 'Yes'}
        ];
    }

    get ids() {
        let _ids = [];
        if (this.animal.Shelterbuddy_ID__c) _ids.push('My ID: ' + this.animal.Shelterbuddy_ID__c);
        if (this.isSupplyID && this.animal.Breeder_Registration_Number__c) _ids.push('Supply ID: ' + this.animal.Breeder_Registration_Number__c);
        return _ids;
    }

    get images() {
        let _images = [];
        if (this.privateImages) {
            for (let i = 0; i < this.privateImages.length; i++) {
                _images.push({url: this.privateImages[i], key: i, class: this.selectedHeaderIndex == i ? 'active' : ''});
            }
        }

        return _images;
    }

    get isImageArrows() {
        return this.privateImages && this.privateImages.length > 1;
    }

    get facebookShareLink() {
        // return 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href;
        return 'http://m.me';
    }

    get emailLink() {
        return 'mailto:?subject=Give ' + this.animal.Animal_Name__c + ' a home&body=' + window.location.href;
    }

    get adoptLink() {return '../../' + this.adoptLinkUrl + '?id=' + this.animal.Id;}

    get overviewTabClass() {return 'sticky-tab' + (this.selectedNavTab == 'overview' ? ' active' : '');}
    get storyTabClass() {return 'sticky-tab' + (this.selectedNavTab == 'story' ? ' active' : '');}
    get faqTabClass() {return 'sticky-tab' + (this.selectedNavTab == 'faq' ? ' active' : '');}
    get resourceTabClass() {return 'sticky-tab' + (this.selectedNavTab == 'resource' ? ' active' : '');}
    get isFosterStatus() {return this.animal.Status__c && this.animal.Status__c == 'Available for Adoption - In Foster';}
    get isNotCatAdoptionLocationType() {return !this.animal.Location__c || !this.animal.Location__r.Location_Type__c || this.animal.Location__r.Location_Type__c != 'Cat Adoption';}

    get shareClass() {return this.isShareOpen ? 'pet-share active' : 'pet-share';}

    get backdropClass() {return this.isShareOpen ? 'backdrop open' : 'backdrop';}

    get bonusOffers() {
        let _bonusOffers = [];
        if ((this.animal.Animal_Category__c == 'Dog' || this.animal.Animal_Category__c == 'Puppy') && this.dogBonusOfferString) _bonusOffers = JSON.parse(this.dogBonusOfferString);
        if ((this.animal.Animal_Category__c == 'Cat' || this.animal.Animal_Category__c == 'Kitten') && this.catBonusOfferString) _bonusOffers = JSON.parse(this.catBonusOfferString);
        return _bonusOffers;
    }

    get upsell() {
        let _upsell = {};
        let animalCategory = this.animal && this.animal.Animal_Category__c ? this.animal.Animal_Category__c.replaceAll(' ', '').toLowerCase() : null;
        if (animalCategory) {
            let _upsellString = this.animal.Animal_Category__c == 'Dog' ? this.upsellString : this[animalCategory + 'UpsellString'];
            if (_upsellString) _upsell = JSON.parse(_upsellString);
        }

        return _upsell;
    }

    get multipleAnimalCategory() {return this.animal && this.animal.Animal_Category__c ? (this.animal.Animal_Category__c == 'Farmyard' ? 'farm animals' : this.animal.Animal_Category__c.toLowerCase() + 's') : ''};

    messageContext = { data: [] };
    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxToasts = 1;
        toastContainer.toastPosition = 'top-center';
    }

    renderedCallback() {
        window.addEventListener('scroll', (event) => {
            this.handleScroll(event)
        });
    }

    initFaqs() {
        let animalCategory = this.animal && this.animal.Animal_Category__c ? this.animal.Animal_Category__c.replaceAll(' ', '').toLowerCase() : null;
        if (animalCategory) {
            this.faqsString = this[animalCategory + 'FaqsString'];
            this.faqsLinkUrl = this[animalCategory + 'FaqsLinkUrl'];
        }
    }

    handleNavTabClick(evt) {
        this.selectedNavTab = evt.currentTarget.dataset.value;
        if (this.selectedNavTab == 'overview') window.scrollTo({left: 0, top: 0, behavior: 'smooth'});
        if (this.selectedNavTab == 'story') this.template.querySelector(".page-pet-body").scrollIntoView({ block: 'start',  behavior: 'smooth' });
        if (this.selectedNavTab == 'faq') this.template.querySelector("c-rspcaqld-section-faq").scrollIntoView({ block: 'start',  behavior: 'smooth' });
        if (this.selectedNavTab == 'resource') this.template.querySelector(".page-related-articles").scrollIntoView({ block: 'start',  behavior: 'smooth' });
    }

    // handleDiaryImageClick(evt) {
    //     this.selectedDiaryIndex = parseInt(evt.target.dataset.index);
    //     this.selectedDiaryImage = evt.target.src;
    // }
    //
    // handleDiaryClickLeft(evt) {
    //     this.template.querySelector(".page-pet-diary-images").scrollLeft -= 100;
    // }
    //
    // handleDiaryClickRight(evt) {
    //     this.template.querySelector(".page-pet-diary-images").scrollLeft += 100;
    // }

    handleHeaderImageClick(evt) {
        this.selectedHeaderIndex = parseInt(evt.target.dataset.index);
        this.selectedHeaderImage = evt.target.src;
    }

    handleSelectedHeaderImageClick(evt) {
        this.selectedLighboxHeaderIndex = this.selectedHeaderIndex;
        this.selectedLighboxHeaderImage = this.selectedHeaderImage;
    }

    handleCloseLightbox(evt) {
        this.selectedLighboxHeaderIndex = null;
        this.selectedLighboxHeaderImage = null;
    }

    handleHeaderImageClickLeft(evt) {
        this.template.querySelector(".page-pet-header-images-block").scrollLeft -= 465;
    }

    handleHeaderImageClickRight(evt) {
        this.template.querySelector(".page-pet-header-images-block").scrollLeft += 465;
    }

    handleShare(evt) {
        this.isShareOpen = true;
    }

    handleShareClose(evt) {
        this.isShareOpen = false;
    }

    handleSharePopupClick(evt) {
        if (evt.target.className == 'share-pop-up' || evt.target.className == 'share-pop-up-close-block') this.handleShareClose();
    }

    handleAdopt(evt) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '../../' + this.adoptLinkUrl + '?id=' + this.animal.Id
            },
        });
    }

    handleCopyURL(evt) {
        Toast.show({
            label: 'URL link copied!',
            mode: 'dismissible',
            variant: 'success'
        }, this);

        navigator.clipboard.writeText(window.location.href);
    }

    handleScroll(evt) {
        let nav = this.template.querySelector('.page-pet-nav');
        let scrollHeight = window.innerWidth <= 960 ? 60 : 110;

        if (nav.getBoundingClientRect().top <= scrollHeight) {
            nav.classList.add('is-sticked');
        }
        if (nav.classList.contains('is-sticked') && nav.getBoundingClientRect().top > scrollHeight) {
            nav.classList.remove('is-sticked');
        }
    }
}