import {api, LightningElement, wire} from 'lwc';
import headerAction from '@salesforce/messageChannel/HeaderAction__c';
import {MessageContext, publish} from "lightning/messageService";
import * as constants from 'c/constants';

export default class RspcaqldSection5050 extends LightningElement {
    @api lr = false;
    @api isQuote = false;
    @api icon;
    @api iconPosition;
    @api imageShape = 'Shape One';
    @api imageClass;
    @api imageUrl;
    @api imageKey;
    imageContentURL = { data: [] };
    @api videoUrl;
    @api subHeader;
    @api header;
    @api description;
    @api quickLinks;
    @api quickLinksString;
    @api buttonLabel;
    @api buttonLink;
    @api buttonScrollClass;
    @api quoteAuthor;
    @api isActionButton = false;
    @api customClass;
    arrowRightWhite = constants.arrowRightWhite;

    messageContext = { data: [] };
    get mainClass() {
        return 'section-5050' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get image(){
        return this.imageContentURL.data ? this.imageContentURL.data : (this.imageUrl ? this.imageUrl : null);
    }

    get iClass() {
        return this.imageClass ? this.imageClass : (this.imageShape == 'Shape One' ? 'shape-1' : 'shape-2') + (this.iconPosition == 'Bottom' ? ' bottom' : '');
    }

    get rl() {
        return !this.lr;
    }

    get rlMainClass() {
        return 'section-5050-image rl-image ' + (this.imageShape == 'Shape One' ? 'shapeone' : 'shapetwo') +
            (this.rl ? ' active' : '');
    }

    get lrMainClass() {
        return 'section-5050-image lr-image ' + (this.imageShape == 'Shape One' ? 'shapeone' : 'shapetwo') +
            (this.lr ? ' active' : '');
    }

    get descriptionClass() {
        return 'medium' + (this.isQuote ? ' quote' : '');
    }

    get isHeader() {
        return this.header ? true : false;
    }

    get isSubheader() {
        return this.subHeader ? true : false;
    }

    get isDescription() {
        return this.description ? true : false;
    }

    get isQuickLinks() {
        return this.qlinks ? true : false;
    }

    get isButton() {
        return this.buttonLabel ? true : false;
    }

    get qlinks() {
        if (this.quickLinks) {
            return this.quickLinks;
        } else if (this.quickLinksString) {
            let linksArray = JSON.parse(this.quickLinksString);
            let links = [];

            for (let i = 0; i < linksArray.length; i++) {
                let link = {label: linksArray[i][0], url: linksArray[i][1]}
                links.push(link);
            }
            return links;
        }
        return null;
    }

    get isButtonScrollClass() {
        return this.buttonScrollClass ? true : false;
    }

    handleClick(evt) {
        publish(this.messageContext, headerAction, {class: this.buttonScrollClass});
    }
}