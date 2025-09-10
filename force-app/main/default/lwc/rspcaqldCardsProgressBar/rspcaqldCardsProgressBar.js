import {api, LightningElement} from 'lwc';

export default class RspcaqldCardsProgressBar extends LightningElement {
    @api header;
    @api currentAmount = 0;
    @api fullAmount = 0;

    renderedCallback() {
        this.template.querySelector('.cards-progress-current-bar').style.width = (this.currentAmount/this.fullAmount*100) + '%';
    }
}