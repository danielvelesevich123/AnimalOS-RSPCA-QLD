import {LightningElement} from 'lwc';
import PAGE_FILES from "@salesforce/contentAssetUrl/PortalImageszip";
import * as constants from 'c/constants';

export default class RspcaqldPageAdoptProcessIntro extends LightningElement {
    imageUrl = PAGE_FILES + "?pathinarchive=adopt-process-header-image.png";
    tigerLeftPaw = constants.tigerLeftPaw;
    arrowRightWhite = constants.arrowRightWhite;

    handleClick(evt) {
        this.dispatchEvent(new CustomEvent("stepchange"));
    }
}