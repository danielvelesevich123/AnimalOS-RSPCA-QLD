import {api, LightningElement, wire} from 'lwc';
import * as constants from 'c/constants';
export default class RspcaqldPageWelfareComplaintIntro extends LightningElement {
    @api header;
    @api headerHeight;
    @api description;
    @api buttonColor;
    @api buttonLabel;
    @api buttonLabelColor;
    @api imageUrl;
    @api imageKey;
    @api imageHeight;
    @api pawPrintLabel;
    imageContentURL = { data: [] };
    arrowRightWhite = constants.arrowRightWhite;

    get isHeader() {return this.header ? true : false;}
    get isDescription() {return this.description ? true : false;}

    get image(){
        return this.imageContentURL.data ? this.imageContentURL.data : (this.imageUrl ? this.imageUrl : null);
    }
    get pawPrint() {
        return this.pawPrintLabel ? constants.officialRSPCAPaw : null;
    }
    get pawPrintClass() {
        return 'paw-print' + (this.pawPrintLabel ? (this.pawPrintLabel == 'Official RSPCA Left' ? '' : ' paw-right') : null);
    }

    get imageStyle() {
        return this.imageHeight ? 'height: ' + this.imageHeight + 'px' : '';
    }

    get headerStyle() {
        return this.headerHeight ? 'height: ' + this.headerHeight + 'px' : '';
    }

    get buttonStyle() {
        return (this.buttonColor ? 'background: ' + this.buttonColor  + '; ' : '') + (this.buttonLabelColor ? 'color: ' + this.buttonLabelColor + ';' : '');
    }

    handleClick(evt) {
        this.dispatchEvent(new CustomEvent("stepchange"));
    }
}