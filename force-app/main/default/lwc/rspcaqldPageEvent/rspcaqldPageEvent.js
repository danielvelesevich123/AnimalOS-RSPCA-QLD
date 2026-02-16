import {LightningElement, wire} from 'lwc';
import PAGE_FILES from "@salesforce/contentAssetUrl/PortalImageszip";
import {MessageContext, publish} from "lightning/messageService";
import breadcrumbs from '@salesforce/messageChannel/Breadcrumbs__c';
import {CurrentPageReference} from "lightning/navigation";
import * as constants from 'c/constants';

export default class RspcaqldPageEvent extends LightningElement {
    calendarWhite = constants.calendarWhite;
    locationWhite = constants.locationWhite;
    arrowRightWhite = constants.arrowRightWhite;
    arrowLeftDark = constants.arrowLeftDark;

    recordId;
    event = {
        record: {}
    };
    headerBackground = PAGE_FILES + '?pathinarchive=header-background.png';

    @wire(CurrentPageReference)
    pageReference(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes?.recordId;
        }
    }

    messageContext = { data: [] };
    get facebookShareLink() {
        return 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href;
    }

    get twitterShareLink() {
        return 'http://www.twitter.com/intent/tweet?url=' + window.location.href + (this.event && this.event.record ? '&text=' + this.event.record.Name : '');
    }

    get linkedinShareLink() {
        return 'https://www.linkedin.com/shareArticle?mini=true&url=' + window.location.href;
    }

    get isAction() {return this.event && this.event.record && this.event.record.Event_URL__c;}
    get isMoreEvents() {return this.event && this.event.relatedEvents;}

    connectedCallback() {}

    handleBack(evt) {
        window.location.replace('events');
    }
}