import {api, LightningElement} from 'lwc';
import * as constants from 'c/constants';
import {publish} from "lightning/messageService";
import {arrowRightDark} from "c/constants";

export default class RspcaqldSectionRelatedArticles extends LightningElement {
    bottomrightWedge = constants.bottomrightWedge;
    topleftWedge = constants.topleftWedge;
    @api customClass;
    @api header;
    @api headerSize;
    @api headerMobileSize;
    @api description;
    @api linkUrl;
    @api linkLabel;
    @api secondLinkUrl;
    @api secondLinkLabel;
    @api contentType;
    @api contentString;
    @api contentTypeLink;
    @api contentTypes = '';
    articles = { data: [] };
    wireDirectors = { data: [] };
    @api cards;
    events = { data: [] };
    @api isShape = false;
    @api isWhite = false;
    @api isArray = false;
    @api printPawLabel;
    @api secondPrintPawLabel;
    @api isCategory = false;

    get mainClass() {
        return 'section-cta-articles' + (this.isWhite ? ' white' : '') + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get headerClass() {
        return this.desktopSize + ' ' + this.mobileSize;
    }

    get desktopSize() {
        switch (this.headerSize) {
            case 'Huge': return '';
            case 'Large': return 'medium';
            case 'Medium': return 'xmedium';
            case 'Small': return 'small';
            case 'Ultra Small': return 'xsmall';
            default: return '';
        }
    }

    get mobileSize() {
        switch (this.headerMobileSize) {
            case 'Huge': return 'mobile-huge';
            case 'Large': return 'mobile-large';
            case 'Medium': return 'mobile-medium';
            case 'Small': return 'mobile-small';
            case 'Ultra Small': return 'mobile-xsmall';
            default: return '';
        }
    }

    get printPawStyle() {
        return (this.isWhite) ? '-webkit-mask: url(' + this.printPaw + ') center/contain;' : '';
    }

    get isDescription() {
        return this.description ? true : false;
    }

    get isLink() {
        return this.linkUrl && this.linkLabel ? true : false;
    }

    get isSecondLink() {
        return this.secondLinkUrl && this.secondLinkLabel ? true : false;
    }

    get articlesClass() {
        return 'section-cta-articles-articles' + (this.isEvents ? ' section-cta-events' : '');
    }

    get isPaw() {
        return this.printPawLabel ? true : false;
    }

    get isSecondPaw() {
        return this.secondPrintPawLabel ? true : false;
    }

    get isArticles() {return this.contentType && this.contentType == 'Articles';}
    get isDirectors() {return this.contentType && this.contentType == 'Directors';}
    get isEvents() {return this.contentType && this.contentType == 'Events' && this.contentString;}

    get articlesString() {return this.isArticles ? this.contentString : '';}
    get directorsString() {return this.isDirectors ? this.contentString : '';}
    get eventsString() {return this.isEvents ? this.contentString : '';}

    get printPaw() {
        // return this.printPawLabel ? constants[this.printPawLabel.split(' ')[0].toLowerCase() + this.printPawLabel.split(' ')[1] + 'Paw'] : null;
        return this.printPawLabel ? constants.officialRSPCAPaw : null;
    }

    get printPawClass() {
        return 'paw-print' + (this.printPawLabel ? (this.printPawLabel == 'Official RSPCA Left' ? ' paw-right' : '') : null);
    }

    get secondPrintPaw() {
        // return this.secondPrintPawLabel ? constants[this.secondPrintPawLabel.split(' ')[0].toLowerCase() + this.secondPrintPawLabel.split(' ')[1] + 'Paw'] : null;
        return this.secondPrintPawLabel ? constants.officialRSPCAPaw : null;
    }

    get secondPrintPawClass() {
        return 'second-paw-print' + (this.secondPrintPawLabel ? (this.secondPrintPawLabel == 'Official RSPCA Left' ? ' paw-right' : '') : null);
    }

    get isCards() {return this.cards ? true : false;}

    get directors() {
        if (this.wireDirectors && this.wireDirectors.data) {
            let uwd = JSON.parse(JSON.stringify(this.wireDirectors.data));
            uwd.map(item => {
                item.link = '../' + (this.contentTypeLink ? this.contentTypeLink : 'director') + '/' + item.key;
            });
            return uwd;
        }
    }

    get arrowRightIcon() {
        return this.isWhite ? constants.arrowRightDark : constants.arrowRightWhite;
    }

    connectedCallback() {
        if (this.contentType == 'Cards' && this.contentString) {
            this.cards = JSON.parse(this.contentString);
        }
    }
}