import {api, LightningElement} from 'lwc';

export default class RspcaqldIframe extends LightningElement {
    @api iframeSrc;
    @api iframeWidth;
    @api iframeHeight;
    @api marginTop;

    get iframeStyle() {
        return (this.iframeWidth ? 'width:' + this.iframeWidth + ';' : '') +
               (this.iframeHeight ? 'height:' + this.iframeHeight + ';' : '') +
               (this.marginTop ? 'margin-top:' + this.marginTop + ';' : '');
    }
}