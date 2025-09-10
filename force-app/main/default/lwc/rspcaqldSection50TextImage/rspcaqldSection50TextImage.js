import {api, LightningElement} from 'lwc';

export default class RspcaqldSection50TextImage extends LightningElement {
    @api vertical = false;
    @api lr = false;
    @api imageUrl;
    @api header;
    @api description;
    @api buttonLabel;
    @api buttonLink;

    handleClick(evt) {
        if (this.buttonLink) window.location.replace(this.buttonLink);
    }
}