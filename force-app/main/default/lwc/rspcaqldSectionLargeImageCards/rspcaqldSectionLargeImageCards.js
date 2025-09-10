import getImage from '@salesforce/apex/ManagedContentService.getImageByContentKey';
import {api, LightningElement, wire} from 'lwc';

export default class RspcaqldSectionLargeImageCards extends LightningElement {
    @api customClass;
    @api cardPosition = 'Vertical';
    @api imageOne;
    imageOneKey;
    @wire(getImage, {contentKey: '$imageOneKey'}) imageOneContentURL;
    @api headerOne;
    @api descOne;
    @api linkLabelOne;
    @api linkUrlOne;
    @api imageTwo;
    imageTwoKey;
    @wire(getImage, {contentKey: '$imageTwoKey'}) imageTwoContentURL;
    @api headerTwo;
    @api descTwo;
    @api linkLabelTwo;
    @api linkUrlTwo;

    get mainClass() {
        return 'page-image-articles medium-width' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '') + (this.cardPosition == 'Horizontal' ? ' horizontal' : '');
    }

    get isVertical() {
        return this.cardPosition == 'Vertical';
    }

    get imageOneUrl() {
        return this.handleImage(this.imageOne, 1);
    }
    get imageTwoUrl() {
        return this.handleImage(this.imageTwo, 2);
    }

    handleImage(image, count) {
        if (image) {
            if (!image.includes('http') && !image.includes('jpeg') && !image.includes('jpg') && !image.includes('png')) {
                if (count == 1) {this.imageOneKey = image;} else {this.imageTwoKey = image;}
                return count == 1 ? this.imageOneContentURL.data : this.imageTwoContentURL.data;
            } else {
                return image;
            }
        }
        return null;
    }
}