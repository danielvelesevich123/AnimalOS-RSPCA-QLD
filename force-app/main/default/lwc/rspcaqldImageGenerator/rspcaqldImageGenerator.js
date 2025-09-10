import getImage from '@salesforce/apex/ManagedContentService.getImageByContentKey';
import {api, LightningElement, wire} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldImageGenerator extends LightningElement {
    @api className;
    @api imageUrl;
    imageKey;
    @wire(getImage, {contentKey: '$imageKey'}) imageContentURL;
    @wire(getImage, {contentKey: '$iconKey'}) iconImageContentURL;
    @api iconKey;
    @api iconImageUrl;
    @api isVideoOpen = false;
    @api videoUrl;
    _iconName;
    closeWhite = constants.closeWhite;

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

    get iconImage() {
        if (this.iconImageUrl) {
            return this.iconImageUrl;
        } else if (this.iconKey) {
            return this.iconImageContentURL.data;
        } else {
            return null;
        }
    }

    get isIconKey() {
        return this.iconKey || this.iconImageUrl ? true : false;
    }

    get isVideo() {
        return this.videoUrl ? true : false;
    }

    @api
    set iconName(value) {
        this._iconName = value;
    }

    get iconName() {
        return 'default ' + this._iconName;
    }

    get iconBlockClass() {
        return 'icon-block ' + this.className;
    }

    get videoClass() {return this.isVideoOpen ? 'pop-up-container active' : 'pop-up-container';}

    get backdropClass() {return this.isVideoOpen ? 'backdrop open' : 'backdrop';}

    handleVideo(evt) {
        this.isVideoOpen = true;
    }

    handleVideoClose(evt) {
        this.isVideoOpen = false;
    }

    handleVideoPopupClick(evt) {
        let tagName = evt.target.tagName.toLowerCase();
        if (tagName == 'div') {
            this.handleVideoClose(evt);
        }
    }
}