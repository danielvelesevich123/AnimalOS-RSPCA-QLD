import {api, LightningElement} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldImageGenerator extends LightningElement {
    @api className;
    @api imageUrl;
    imageKey;
    imageContentURL = { data: null };
    iconImageContentURL = { data: null };
    @api iconKey;
    @api iconImageUrl;
    @api isVideoOpen = false;
    @api videoUrl;
    _iconName;
    closeWhite = constants.closeWhite;

    get image() {
        return this.imageUrl || null;
    }

    get iconImage() {
        return this.iconImageUrl || null;
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