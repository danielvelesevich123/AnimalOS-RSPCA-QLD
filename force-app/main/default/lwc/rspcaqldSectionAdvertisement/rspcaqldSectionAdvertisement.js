import getImage from '@salesforce/apex/ManagedContentService.getImageByContentKey';
import {api, LightningElement, wire} from 'lwc';

export default class RspcaqldSectionAdvertisement extends LightningElement {
    @api customClass;
    @api imageUrl;
    imageKey;
    @wire(getImage, {contentKey: '$imageKey'}) imageContentURL;
    @api header;
    @api description;
    @api linkLabel = 'Learn more';
    @api linkUrl;
    @api logoOneKey;
    @api logoTwoKey;
    @wire(getImage, {contentKey: '$logoOneKey'}) logoOne;
    @wire(getImage, {contentKey: '$logoTwoKey'}) logoTwo;

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
        if (this.imageUrl) {
            if (!this.imageUrl.includes('http') && !this.imageUrl.includes('jpeg') && !this.imageUrl.includes('jpg') && !this.imageUrl.includes('png')) {
                this.imageKey = this.imageUrl;
                return this.imageContentURL.data;
            } else {
                return this.imageUrl;
            }
        }
        return null;
    }
}