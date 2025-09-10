import {api, LightningElement} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldShareBlock extends LightningElement {
    @api facebookLink;
    @api linkedinLink;
    @api twitterLink;

    facebookDark = constants.facebookDark;
    linkedinDark = constants.linkedinDark;
    xDark = constants.xDark;
}