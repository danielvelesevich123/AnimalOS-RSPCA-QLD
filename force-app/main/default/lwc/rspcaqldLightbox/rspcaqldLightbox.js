import {api, LightningElement} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldLightbox extends LightningElement {
    @api selectedIndex = 0;
    @api selectedImage;
    privateImages;

    closeWhite = constants.closeWhite;

    @api
    set images(items) {
        this.privateImages = JSON.parse(JSON.stringify(items));
    }

    get images() {
        this.privateImages.map((item, index) => {
            if (this.selectedIndex != null) {
                if (index == this.selectedIndex) {
                    item.class = 'active';
                } else if (index < this.selectedIndex) {
                    item.class = 'left';
                } else if (index > this.selectedIndex) {
                    item.class = 'right';
                }
            } else {
                item.class = '';
            }
        });
        return this.privateImages;
    }

    get isSelected() {
        return this.selectedImage != null ? true : false;
    }

    get lightboxClass() {
        return 'lightbox' + (this.isSelected ? ' active' : '');
    }

    handleLightboxClick(evt) {
        let tagName = evt.target.tagName.toLowerCase();
        if (tagName != 'img' && tagName != 'i' && tagName != 'lightning-icon') {
            this.handleClose(evt);
        }
    }

    handleChevronLeft(evt) {
        this.selectedIndex = this.selectedIndex == 0 ? this.images.length - 1 : this.selectedIndex - 1;
    }

    handleChevronRight(evt) {
        this.selectedIndex = this.selectedIndex == (this.images.length - 1) ? 0 : this.selectedIndex + 1;
    }

    handleClose(evt) {
        this.selectedImage = null;
        this.dispatchEvent(new CustomEvent("closelightbox"));
    }
}