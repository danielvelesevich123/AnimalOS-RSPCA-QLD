import {api, LightningElement} from 'lwc';

export default class RspcaqldSectionFaq extends LightningElement {
    @api customClass;
    @api header = 'Frequently asked questions';
    @api linkLabel = 'Browse all FAQs';
    @api linkUrl;
    @api accordionSections;
    @api faqsString;
    @api isWhite = false;

    get mainClass() {
        return 'section-faq wide-width' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '')
            + (this.isWhite ? ' white' : '');
    }

    get parentClass() {
        return 'width-100' + (this.isWhite ? ' background-0' : '');
    }

    get isHeader() {
        return this.header ? true : false;
    }

    get faqs() {
        if (this.accordionSections) {
            return this.accordionSections;
        } else if (this.faqsString) {
            return JSON.parse(this.faqsString);
        }

        return null;
    }
}