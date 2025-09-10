import getArticles from '@salesforce/apex/ManagedContentService.getContentByMixedKeys';
import {api, LightningElement, wire} from 'lwc';

export default class RspcaqldSectionFeaturedArticlesScroll extends LightningElement {
    @api customClass;
    @api header;
    @api contentKeys;
    @api cmsKeys = '';
    @api locationIds = [];
    @api eventIds = [];
    @wire(getArticles, {keysString: '$contentKeys'}) articles;

    get mainClass() {
        return 'page-home-articles medium-width' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    handleClickLeft(evt) {
        let scrollValue = window.innerWidth >= 1530 ? 1400 : (window.innerWidth > 688 ? 970 : 350);
        this.template.querySelector(".page-home-articles-body").scrollLeft -= scrollValue;
    }

    handleClickRight(evt) {
        let scrollValue = window.innerWidth >= 1530 ? 1400 : (window.innerWidth > 688 ? 970 : 350);
        this.template.querySelector(".page-home-articles-body").scrollLeft += scrollValue;
    }
}