import getImage from '@salesforce/apex/ManagedContentService.getImageByContentKey';
import {api, LightningElement, wire} from 'lwc';

export default class RspcaqldSectionEducationResources extends LightningElement {
    @api customClass;
    @api header = 'Education & Resources';
    @api headerLinkLabel = 'Browse our resource centre';
    @api headerLinkUrl = 'resources';
    @api cardOneImage;
    cardOneImageKey;
    @wire(getImage, {contentKey: '$cardOneImageKey'}) cardOneImageContentURL;
    @api cardOneLabel;
    @api cardOneLink;
    @api cardTwoImage;
    cardTwoImageKey;
    @wire(getImage, {contentKey: '$cardTwoImageKey'}) cardTwoImageContentURL;
    @api cardTwoLabel;
    @api cardTwoLink;
    @api cardThreeImage;
    cardThreeImageKey;
    @wire(getImage, {contentKey: '$cardThreeImageKey'}) cardThreeImageContentURL;
    @api cardThreeLabel;
    @api cardThreeLink;

    get mainClass() {
        return 'page-home-resources medium-width' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get imageOneUrl() {
        return this.handleImage(this.cardOneImage, 1);
    }
    get imageTwoUrl() {
        return this.handleImage(this.cardTwoImage, 2);
    }

    get imageThreeUrl() {
        return this.handleImage(this.cardThreeImage, 3);
    }

    handleImage(image, count) {
        if (image) {
            if (!image.includes('http') && !image.includes('jpeg') && !image.includes('jpg') && !image.includes('png')) {
                if (count == 1) {this.cardOneImageKey = image; return this.cardOneImageContentURL.data;}
                if (count == 2) {this.cardTwoImageKey = image; return this.cardTwoImageContentURL.data;}
                if (count == 3) {this.cardThreeImageKey = image; return this.cardThreeImageContentURL.data;}
            } else {
                return image;
            }
        }
        return null;
    }
}