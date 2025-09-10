import {LightningElement} from 'lwc';
import PAGE_FILES from "@salesforce/contentAssetUrl/PortalImageszip";
import * as constants from 'c/constants';

export default class RspcaqldPageNewsletterSubscribed extends LightningElement {
    imageUrl = PAGE_FILES + "?pathinarchive=newsletter.png";
    pawPrintUrl = constants.tigerLeftPaw;
    arrowRightWhite = constants.arrowRightWhite;
    arrowLeftWhite = constants.arrowLeftWhite;
}