import {LightningElement, wire} from 'lwc';
import {MessageContext, publish} from 'lightning/messageService';
import breadcrumbs from '@salesforce/messageChannel/Breadcrumbs__c';
import {CurrentPageReference} from "lightning/navigation";
import * as constants from 'c/constants';

export default class RspcaqldPageOurImpactSingle extends LightningElement {
    position = [];
    allPositions;

    arrowRightWhite = constants.arrowRightWhite;

    messageContext = { data: [] };
    @wire(CurrentPageReference)
    getContentKey(currentPageReference) {
        if (currentPageReference) {
            this.contentKey = currentPageReference.attributes?.contentKey;
        }
    }

    allPositions = { data: [] };
    get postedLine() {
        return 'Posted' + (this.position.formatPublishedDate ? ' on ' + this.position.formatPublishedDate : '')
                        + (this.position.category ? ' in ' + this.position.category : '')
                        + (this.position.location ? ' for ' + this.position.location : '');
    }

    get otherPositions() {
        let positions = []
        if (this.position && this.allPositions && this.allPositions.data) {
            for (let i = 0; i < this.allPositions.data.length; i++) {
                if (this.allPositions.data[i].key != this.position.key && this.allPositions.data[i].category == this.position.category) {
                    positions.push(this.allPositions.data[i]);
                }
                if (positions.length == 3) break;
            }
        }
        return positions;
    }

    get isOtherPositions() {
        let _positions = this.otherPositions;
        return _positions && _positions.length;
    }

    get facebookShareLink() {
        return 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href;
    }

    get twitterShareLink() {
        return this.position ? 'http://www.twitter.com/intent/tweet?url=' + window.location.href + '&text=' + this.position.title : '';
    }

    get linkedinShareLink() {
        return 'https://www.linkedin.com/shareArticle?mini=true&url=' + window.location.href;
    }

    get isVideoOrImage() {
        return this.position && (this.position.video || this.position.image) ? true : false;
    }

    get isNotVideoOrImage() {
        return !this.position || (!this.position.video && !this.position.image) ? true : false;
    }

    get isVideo() {
        return this.position && this.position.video ? true : false;
    }

    get isImage() {
        return this.position && this.position.image ? true : false;
    }

    get sectionHeaderClass() {
        return 'section-header' + (this.isNotVideoOrImage ? ' without-image-video' : '');
    }

    get bodyClass() {
        return 'page-our-career-single-body ' + (this.isNotVideoOrImage ? ' without-image-video' : '');
    }

    connectedCallback() {}
}