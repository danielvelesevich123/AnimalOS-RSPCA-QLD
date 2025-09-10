import {api, LightningElement} from 'lwc';

export default class RspcaqldSectionVideo extends LightningElement {
    @api customClass;
    @api videoUrl;
    @api videoSize = 'Medium';
    @api previewImage;
    @api isPopup = false;

    get mainClass() {
        return 'page-video' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '') + (this.videoSize ? ' ' + this.videoSize.toLowerCase() : '');
    }
}