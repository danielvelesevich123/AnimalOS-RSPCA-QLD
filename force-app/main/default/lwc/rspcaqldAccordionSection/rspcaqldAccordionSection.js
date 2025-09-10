import {api, LightningElement} from 'lwc';

export default class RspcaAccordionSection extends LightningElement {
    @api label;
    @api body;
    @api linkUrl;
    @api linkLabel;
    @api isOpen = false;

    get mainClass() {
        return (this.isOpen ? 'accordion-section' : 'accordion-section closed');
    }
    get iconClass() {
        return this.isOpen ? 'utility:chevronup' : 'utility:chevrondown';
    }

    get isLink() {return this.linkLabel && this.linkUrl;}

    get linkTarget() {
        return this.linkUrl && this.linkUrl.startsWith('http') ? '_blank' : '_self';
    }

    handleOpen(evt) {
        this.isOpen = !this.isOpen;
    }
}