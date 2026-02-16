import {LightningElement, wire, api} from 'lwc';

export default class RspcaqldSectionFeaturedArticles extends LightningElement {
    @api customClass;
    @api header = 'Featured articles';
    @api isCategory = false;
    @api contentKeys;
    @api contentTypes;

    @api cardOne;
    @api cardTwo;
    @api cardThree;

    get mainClass() {
        return 'medium-width featured-articles' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get isCardOne() {return this.cardOne ? true : false;}
    get isCardTwo() {return this.cardTwo ? true : false;}
    get isCardThree() {return this.cardThree ? true : false;}

    connectedCallback() {
        this.initContent();
    }

    initContent() {
        getManagedContent({keysString: this.contentKeys, contentTypesString: this.contentTypes})
            .then(result => {
                if (result && result.length > 0) {
                    this.cardOne = result[0];
                    if (result.length > 1) this.cardTwo = result[1];
                    if (result.length > 2) this.cardThree = result[2];
                }
            })
            .catch(error => {
                console.log(error);
            })
    }
}