import {api, LightningElement, wire} from 'lwc';

export default class RspcaqldSectionAdvertisement extends LightningElement {
    @api customClass;
    @api imageUrl;
    imageKey;
    imageContentURL = { data: null };
    @api header;
    @api description;
    @api linkLabel = 'Learn more';
    @api linkUrl;
    @api logoOneKey;
    @api logoTwoKey;
    logoOne = { data: null };
    logoTwo = { data: null };
    get mainClass() {
        return 'section-avertisement' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get backgroundStyle() {
        return 'background: lightgray 50% / cover url(' + this.image + ');';
    }

    get isLogoOne() {
        return this.logoOne && this.logoOne.data;
    }

    get isLogoTwo() {
        return this.logoTwo && this.logoTwo.data;
    }

    get image() {
        return this.imageUrl || null;
    }
}