import getLocationAccount from '@salesforce/apex/rspcaqldAccountService.getLocationAccount';
import getLocationAnimals from '@salesforce/apex/rspcaqldAnimalService.getLocationAnimals';
import {api, LightningElement, wire} from 'lwc';
import breadcrumbs from '@salesforce/messageChannel/Breadcrumbs__c';
import {MessageContext, publish} from 'lightning/messageService';
import * as constants from 'c/constants';
import {CurrentPageReference} from "lightning/navigation";

export default class RspcaqldPageLocation extends LightningElement {
    @api adoptionBoxImage;
    @api adoptionBoxHeader;
    @api adoptionBoxLinkLabel;
    @api adoptionBoxLinkUrl;
    @api browsePetsLinkUrl;
    @api faqsString;
    @api faqsLinkUrl;
    location = {
        record: {}
    };
    recordId;
    bottomrightWedge = constants.bottomrightWedge;
    officialRSPCAPaw = constants.officialRSPCAPaw;

    selectedLighboxHeaderIndex = 0;
    selectedLighboxHeaderImage;
    selectedHeaderIndex = 0;
    selectedHeaderImage;
    selectedNavTab = 'overview';

    envelopeWhite = constants.envelopeWhite;
    locationWhite = constants.locationWhite;
    phoneWhite = constants.phoneWhite;
    clockWhite = constants.clockWhite;

    @wire(CurrentPageReference)
    pageReference({state}) {if (state && state.id) this.recordId = state.id;}

    @wire(getLocationAnimals, {recordId: '$recordId'}) otherDogs;

    @wire(getLocationAccount, {recordId: '$recordId'})
    wiredLocation({ error, data }) {
        if (data) {
            this.location = data;
            this.privateImages = data.imagesUrls;

            for (let i = 0; i < this.privateImages.length; i++) {
                if (this.privateImages[i] === this.location.record.Location_Image__c) {
                    this.selectedHeaderIndex = i;
                    this.selectedHeaderImage = this.privateImages[i];
                }
            }

            publish(this.messageContext, breadcrumbs,
                {parents: [{label: 'RSPCA Locations', url: '/locations'}], current: this.location.record.Name});
        }
        if (error) {console.log(error);}
    };

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

    get overviewTabClass() {return 'sticky-tab' + (this.selectedNavTab == 'overview' ? ' active' : '');}
    get petsTabClass() {return 'sticky-tab' + (this.selectedNavTab == 'pets' ? ' active' : '');}
    get faqTabClass() {return 'sticky-tab' + (this.selectedNavTab == 'faq' ? ' active' : '');}

    get emailLink() {return this.location && this.location.record ? 'mailto:' + this.location.record.Email__c : '#';}
    get phoneLink() {return this.location && this.location.record ? 'tel:' + this.location.record.Phone : '#';}

    @wire(MessageContext)
    messageContext;

    connectedCallback() {}

    renderedCallback() {
        window.addEventListener('scroll', (event) => {
            this.handleScroll(event)
        });
    }

    handleNavTabClick(evt) {
        this.selectedNavTab = evt.currentTarget.dataset.value;
        if (this.selectedNavTab == 'overview') this.template.querySelector(".page-location-body").scrollIntoView({ block: 'start',  behavior: 'smooth' });
        if (this.selectedNavTab == 'pets') this.template.querySelector(".white-container").scrollIntoView({ block: 'start',  behavior: 'smooth' });
        if (this.selectedNavTab == 'faq') this.template.querySelector("c-rspcaqld-section-faq").scrollIntoView({ block: 'start',  behavior: 'smooth' });
    }

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
        this.template.querySelector(".page-location-header-images-block").scrollLeft -= 465;
    }

    handleHeaderImageClickRight(evt) {
        this.template.querySelector(".page-location-header-images-block").scrollLeft += 465;
    }

    handleScroll(evt) {
        let nav = this.template.querySelector('.page-location-nav');
        let scrollHeight = window.innerWidth <= 960 ? 60 : 110;

        if (nav.getBoundingClientRect().top <= scrollHeight) {
            nav.classList.add('is-sticked');
        }
        if (nav.classList.contains('is-sticked') && nav.getBoundingClientRect().top > scrollHeight) {
            nav.classList.remove('is-sticked');
        }
    }
}