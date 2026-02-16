import {api, LightningElement, wire} from 'lwc';

export default class RspcaqldSectionOurServices extends LightningElement {
    @api customClass;
    @api header;
    @api cardOneImage;
    cardOneImageKey;
    @api cardOneIcon;
    @api cardOneHeaderLinkLabel;
    @api cardOneHeaderLinkUrl;
    @api cardOneLinksString;
    @api cardTwoImage;
    cardTwoImageKey;
    @api cardTwoIcon;
    @api cardTwoHeaderLinkLabel;
    @api cardTwoHeaderLinkUrl;
    @api cardTwoLinksString;
    @api cardThreeImage;
    cardThreeImageKey;
    @api cardThreeIcon;
    @api cardThreeHeaderLinkLabel;
    @api cardThreeHeaderLinkUrl;
    @api cardThreeLinksString;
    @api cardFourImage;
    cardFourImageKey;
    @api cardFourIcon;
    @api cardFourHeaderLinkLabel;
    @api cardFourHeaderLinkUrl;
    @api cardFourLinksString;

    get mainClass() {
        return 'page-home-services medium-width' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get cards() {
        if (this.cardOneImage && !this.cardOneImage.includes('http')) {this.cardOneImageKey = this.cardOneImage;}
        if (this.cardTwoImage && !this.cardTwoImage.includes('http')) {this.cardTwoImageKey = this.cardTwoImage;}
        if (this.cardThreeImage && !this.cardThreeImage.includes('http')) {this.cardThreeImageKey = this.cardThreeImage;}
        if (this.cardFourImage && !this.cardFourImage.includes('http')) {this.cardFourImageKey = this.cardFourImage;}

        let pCards = [
            {
                image: this.cardOneImage,
                icon: this.cardOneIcon,
                headerLinkLabel: this.cardOneHeaderLinkLabel,
                headerLinkUrl: this.cardOneHeaderLinkUrl,
                links: this.cardOneLinksString ? JSON.parse(this.cardOneLinksString) : []
            },
            {
                image: this.cardTwoImage,
                icon: this.cardTwoIcon,
                headerLinkLabel: this.cardTwoHeaderLinkLabel,
                headerLinkUrl: this.cardTwoHeaderLinkUrl,
                links: this.cardTwoLinksString ? JSON.parse(this.cardTwoLinksString) : []
            },
            {
                image: this.cardThreeImage,
                icon: this.cardThreeIcon,
                headerLinkLabel: this.cardThreeHeaderLinkLabel,
                headerLinkUrl: this.cardThreeHeaderLinkUrl,
                links: this.cardThreeLinksString ? JSON.parse(this.cardThreeLinksString) : []
            },
            {
                image: this.cardFourImage,
                icon: this.cardFourIcon,
                headerLinkLabel: this.cardFourHeaderLinkLabel,
                headerLinkUrl: this.cardFourHeaderLinkUrl,
                links: this.cardFourLinksString ? JSON.parse(this.cardFourLinksString) : []
            }
        ];

        return pCards;
    }
}