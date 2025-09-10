import {api, LightningElement} from 'lwc';

export default class RspcaqldSectionCards extends LightningElement {
    @api header;
    @api customClass;
    @api cardsString;
    @api cardsType = 'Learn More';
    @api isTopMargin = false;

    get mainClass() {
        return 'page-cards medium-width' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get headerClass() {
        return this.isTopMargin ? 'header-top-margin' : '';
    }

    get isLMCards() {return this.cardsType == 'Learn More' ? true : false;}
    get isInfoCards() {return this.cardsType == 'Information' || this.cardsType == 'Information White' ? true : false;}
    get isInfoWhiteCards() {return this.cardsType == 'Information White' ? true : false;}
    get isInfoStepCards() {return this.cardsType == 'Information Step' ? true : false;}
    get isHeader() {return this.header ? true : false;}

    get cards() {
        let cards = this.cardsString ? JSON.parse(this.cardsString) : null;
        if (cards) {return this.handleUpdateCards(cards);}
        return null;
    }

    handleUpdateCards(cards) {
        let keyCount = 0;
        cards.map(item => {
            item.key = keyCount;
            keyCount++;
        });
        return cards;
    }
}