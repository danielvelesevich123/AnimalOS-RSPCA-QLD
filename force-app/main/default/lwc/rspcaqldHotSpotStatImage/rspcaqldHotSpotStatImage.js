import {api, LightningElement} from 'lwc';

export default class RspcaqldHotSpotStatImage extends LightningElement {
    @api imageUrl;
    @api statLabel;
    @api statValue;
    @api headerSize = 'huge';
    @api headerMobileSize = 'mobile-huge';

    @api descriptionType = false;

    get mainClass() {
        return 'hot-spot-stat-image' + (this.descriptionType ? ' description' : '');
    }

    get headerClass() {
        return this.desktopSize + ' ' + this.mobileSize;
    }

    get desktopSize() {
        switch (this.headerSize) {
            case 'Huge': return '';
            case 'Large': return 'medium';
            case 'Medium': return 'xmedium';
            case 'Small': return 'small';
            case 'Ultra Small': return 'xsmall';
            default: return '';
        }
    }

    get mobileSize() {
        switch (this.headerMobileSize) {
            case 'Huge': return 'mobile-huge';
            case 'Large': return 'mobile-large';
            case 'Medium': return 'mobile-medium';
            case 'Small': return 'mobile-small';
            case 'Ultra Small': return 'mobile-xsmall';
            default: return '';
        }
    }
}