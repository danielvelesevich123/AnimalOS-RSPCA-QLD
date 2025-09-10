import {LightningElement} from 'lwc';
import PORTAL_RESOURCE from '@salesforce/resourceUrl/PortalResource';
import * as constants from 'c/constants';

export default class RspcaqldPageAdoptError extends LightningElement {
    imageUrl = PORTAL_RESOURCE + '/img/adopt-error-img.png';
    officialRSPCAPaw = constants.officialRSPCAPaw;
}