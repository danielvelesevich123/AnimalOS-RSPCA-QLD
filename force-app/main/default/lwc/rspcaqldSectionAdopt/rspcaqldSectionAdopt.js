import {api, LightningElement, wire} from 'lwc';

export default class RspcaqldSectionAdopt extends LightningElement {
    @api customClass;
    @api header;
    @api buttonLabel;
    @api buttonLink;
    @api imageUrl;
    @api imageKey;
    @api disableBorderCurvatures = false;
    imageContentURL = { data: [] };
    get mainClass() {
        return 'page-pet-adopt' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '') + (this.disableBorderCurvatures ? ' disable-border-curvatures' : '');
    }

    get image(){
        return this.imageContentURL.data ? this.imageContentURL.data : (this.imageUrl ? this.imageUrl : null);
    }

    get backgroundStyle(){
        return 'background: lightgray 50% / cover url(' + this.image + ');';
    }

    handleClick(evt) {
        window.location.replace(this.buttonLink);
    }
}