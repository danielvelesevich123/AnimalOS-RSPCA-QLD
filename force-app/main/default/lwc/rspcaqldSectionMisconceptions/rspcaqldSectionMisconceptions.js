import {api, LightningElement} from 'lwc';

export default class RspcaqldSectionMisconceptions extends LightningElement {
    @api customClass;
    @api leftHeader;
    @api rightHeader;
    @api misconceptionPairs;
    @api pairsString;

    get mainClass() {
        return 'misconceptions-section wide-width' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get pairs() {
        let pairsArray = [];
        if (this.misconceptionPairs) {
            pairsArray = JSON.parse(JSON.stringify(this.misconceptionPairs));
        } else if (this.pairsString) {
            pairsArray = JSON.parse(this.pairsString);
        }

        let keyCount = 0;
        pairsArray.map(item => {
            item.key = keyCount;
            keyCount++;
        });
        return pairsArray;
    }
}