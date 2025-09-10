import {LightningElement} from 'lwc';
import PAGE_FILES from "@salesforce/contentAssetUrl/PortalImageszip";
import * as constants from 'c/constants';

export default class RspcaqldPageLogin extends LightningElement {
    catLeftPaw = constants.catLeftPaw;
    logo = constants.colourLogoURL;
    image = PAGE_FILES + "?pathinarchive=login.jpeg";
}