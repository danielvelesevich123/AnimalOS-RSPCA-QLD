import {api, LightningElement} from 'lwc';

export default class RspcaqldSectionStats extends LightningElement {
    @api customClass;
    @api stats;
    @api descriptionType = false;
    @api blueVersionType = false;
    @api headerType;
    @api header;
    @api linkLabel;
    @api linkUrl;
    @api description;
    @api imageOne;
    imageOneKey;
    @api headerOne;
    @api headerOneSize;
    @api headerOneMobileSize;
    @api descOne;
    @api imageTwo;
    imageTwoKey;
    @api headerTwo;
    @api headerTwoSize;
    @api headerTwoMobileSize;
    @api descTwo;
    @api imageThree;
    imageThreeKey;
    @api headerThree;
    @api headerThreeSize;
    @api headerThreeMobileSize;
    @api descThree;
    @api imageFour;
    imageFourKey;
    @api headerFour;
    @api headerFourSize;
    @api headerFourMobileSize;
    @api descFour;

    get templateClass() {
        return 'width-100' + (this.blueVersionType ? ' background-blue' : '') + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get mainClass() {
        return 'section-stats' + (this.descriptionType ? ' description' : '');
    }

    get isHWL() {
        return this.headerType && this.headerType == 'Header with Link';
    }

    get isHWD() {
        return this.headerType && this.headerType == 'Header with Description';
    }

    get isSingleHeader() {
        return this.headerType && this.headerType == 'Single Header';
    }

    get cards() {
        if (this.stats) {
            return this.stats;
        } else {
            if (this.imageOne && !this.imageOne.includes('http')) this.imageOneKey = this.imageOne;
            if (this.imageTwo && !this.imageTwo.includes('http')) this.imageTwoKey = this.imageTwo;
            if (this.imageThree && !this.imageThree.includes('http')) this.imageThreeKey = this.imageThree;
            if (this.imageFour && !this.imageFour.includes('http')) this.imageFourKey = this.imageFour;
            let cards = [
                {value: this.headerOne, headerSize: this.headerOneSize, headerMobileSize: this.headerOneMobileSize, label: this.descOne, imageUrl: this.imageOne},
                {value: this.headerTwo, headerSize: this.headerTwoSize, headerMobileSize: this.headerTwoMobileSize, label: this.descTwo, imageUrl: this.imageTwo},
                {value: this.headerThree, headerSize: this.headerThreeSize, headerMobileSize: this.headerThreeMobileSize, label: this.descThree, imageUrl: this.imageThree},
                {value: this.headerFour, headerSize: this.headerFourSize, headerMobileSize: this.headerFourMobileSize, label: this.descFour, imageUrl: this.imageFour}
            ];
            return cards;
        }
    }
}