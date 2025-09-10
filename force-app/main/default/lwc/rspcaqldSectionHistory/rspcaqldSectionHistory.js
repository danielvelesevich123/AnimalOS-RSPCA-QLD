import {api, LightningElement} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldSectionHistory extends LightningElement {
    @api customClass;
    @api headerOne;
    @api descOne;
    @api headerTwo;
    @api descTwo;
    @api descTwoString;
    @api buttonsString;
    officialRSPCAPaw = constants.officialRSPCAPaw;

    get mainClass() {
        return 'page-our-pillar-history' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get paragraphs() {
        let paragraphsArray = [];
        if (this.descTwo) {
            paragraphsArray = JSON.parse(JSON.stringify(this.descTwo));
        } else if (this.descTwoString) {
            paragraphsArray = JSON.parse(this.descTwoString);
        }

        let keyCount = 0;
        paragraphsArray.map(item => {
            item.key = keyCount;
            item.isYear = item.year != null;
            item.class = 'year' + (item.green ? ' green' : '');
            keyCount++;
        });
        return paragraphsArray;
    }

    get buttons() {
        let _buttons = [];
        if (this.buttonsString) {
            _buttons = JSON.parse(this.buttonsString);
        }
        return _buttons;
    }

    get isButtons() {
        return this.buttonsString ? true : false;
    }
}