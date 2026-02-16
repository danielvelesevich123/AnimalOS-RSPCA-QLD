import {LightningElement, wire} from 'lwc';
import {MessageContext} from 'lightning/messageService';
import {CurrentPageReference} from "lightning/navigation";
import * as constants from 'c/constants';

export default class RspcaqldPageOurImpactSingle extends LightningElement {
    contentKey;
    report = [];

    arrowLeftDark = constants.arrowLeftDark;

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    getContentKey(currentPageReference) {
        if (currentPageReference) {
            this.contentKey = currentPageReference.attributes?.contentKey;
            this.report = [];
        }
    }


    get facebookShareLink() {
        return 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href;
    }

    get twitterShareLink() {
        return this.report ? 'http://www.twitter.com/intent/tweet?url=' + window.location.href + '&text=' + this.report.header : '';
    }

    get linkedinShareLink() {
        return 'https://www.linkedin.com/shareArticle?mini=true&url=' + window.location.href;
    }

    get isImpactReport() {
        return this.report && this.report.impactReport ? true : false;
    }

    get isFinancialReport() {
        return this.report && this.report.financialReport ? true : false;
    }

    get isVideoOrImage() {
        return this.report && (this.report.bannerVideo || this.report.bannerImage) ? true : false;
    }

    get isNotVideoOrImage() {
        return !this.report || (!this.report.bannerVideo && !this.report.bannerImage) ? true : false;
    }

    get isVideo() {
        return this.report && this.report.bannerVideo ? true : false;
    }

    get isImage() {
        return this.report && this.report.bannerImage ? true : false;
    }

    get sectionHeaderClass() {
        return 'section-header' + (this.isNotVideoOrImage ? ' without-image-video' : '');
    }

    get bodyClass() {
        return 'page-our-impact-single-body ' + (this.isNotVideoOrImage ? ' without-image-video' : '');
    }

    connectedCallback() {}

    handleImpactDownload(evt) {
        this.downloadFile(this.report.impactReport);
    }

    handleFinancialDownload(evt) {
        this.downloadFile(this.report.financialReport);
    }

    downloadFile(link) {
        this.template.querySelector(".download_iframe").src = link;
    }
}