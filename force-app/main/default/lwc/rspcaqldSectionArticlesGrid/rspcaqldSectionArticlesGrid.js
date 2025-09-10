import getManagedContent from '@salesforce/apex/ManagedContentService.getManagedContentByContentType';
import {LightningElement, api, wire} from 'lwc';
import {CurrentPageReference} from "lightning/navigation";
import * as constants from 'c/constants';

export default class RspcaqldSectionArticlesGrid extends LightningElement {
    @api contentType;
    @api isCategories = false;
    @api isCardCategory = false;
    @api firstItemTwoColumns = false;
    orderOption = 'date';
    orderDirection = 'desc';
    currentPage = 1;
    pageCount = 1;
    searchFilter;
    categoryFilter = '';
    articles = [];
    viewCount = 0;
    allCount = 0;

    orderOptions = [
        { label: 'date', value: 'date' },
        { label: 'name', value: 'name' }
    ];

    closeDark = constants.closeDark;

    @wire(CurrentPageReference)
    pageReference({state}) {
        if (state && state.page) {this.currentPage = state.page} else {
            this.currentPage = 1;
            this.updateUrl();
        }
    }

    connectedCallback() {
        getManagedContent({contentType: this.contentType})
            .then(result => {
                this.articles = result;
            })
            .catch(error => {
                console.log(error);
            })
    }

    get categories() {
        let categoryOptions = [];
        if (this.isCategories && this.articles.length > 0) {
            let categories = [];
            for (let i = 0; i < this.articles.length; i++) {
                if (this.articles[i].category) {
                    if (this.articles[i].category.includes(',')) {
                        let articleCategories = this.articles[i].category.split(',');
                        for (let i = 0; i < articleCategories.length; i++) {
                            categories.push(articleCategories[i].trim());
                        }
                    } else {
                        categories.push(this.articles[i].category);
                    }
                }
            }
            categories = [...new Set(categories)].sort();

            for (let i = 0; i < categories.length; i++) {
                categoryOptions.push({ label: categories[i], value: categories[i]});
            }
        }

        return categoryOptions;
    }

    get filteredCards() {
        if (this.orderOption == 'name') {
            return this.sortCards('title');
        }
        if (this.orderOption == 'date') {
            return this.sortCards('publishedDatetime');
        }
        return this.articles;
    }

    sortCards(fieldName) {
        let cards = [];
        let fieldSet = [];
        for (let i = 0; i < this.articles.length; i++) {
            fieldSet.push(this.articles[i][fieldName]);
        }
        fieldSet = [...new Set(fieldSet)].sort();

        if (this.orderDirection == 'asc') {
            for (let i = 0; i < fieldSet.length; i++) {
                for (let j = 0; j < this.articles.length; j++) {
                    if (this.articles[j][fieldName] === fieldSet[i]) cards.push(this.articles[j]);
                }
            }
        } else {
            for (let i = (fieldSet.length - 1); i >= 0; i--) {
                for (let j = 0; j < this.articles.length; j++) {
                    if (this.articles[j][fieldName] === fieldSet[i]) cards.push(this.articles[j]);
                }
            }
        }
        return cards;
    }

    get pages() {
        let pageSize = this.firstItemTwoColumns ? 15 : 16;
        let pages = [];
        let page = [];

        let _filteredCards = this.filteredCards;
        for (let i = 0; i < _filteredCards.length; i++) {
            let ufilteredCard = JSON.parse(JSON.stringify(_filteredCards[i]));

            if (this.filterCard(ufilteredCard)) {
                ufilteredCard.isLarge = pages.length == 0 && page.length == 0 ? this.firstItemTwoColumns : false;
                page.push(ufilteredCard);
            }

            if (page.length == pageSize || _filteredCards.length == (i + 1)) {
                let pageNumber = pages.length + 1;
                pages.push({cards: page, pageNumber: pageNumber, displayed: pageNumber == this.currentPage});
                page = [];
                if (pageSize == 15) pageSize = 16;
            }
        }

        setTimeout(() => this.calculateViewCount(pages, _filteredCards), 1);
        this.pageCount = pages.length;

        return pages;
    }

    calculateViewCount(pages, fCards) {
        if (pages !== undefined && pages.length > 0) {
            for (let i = 0; i <= pages.length; i++) {
                if (pages[i] && pages[i].displayed) this.viewCount = pages[i].cards.length;
            }
        } else {
            this.viewCount = 0;
        }
        this.allCount = fCards ? fCards.length : 0;
    }

    handlePageChange(evt) {
        this.currentPage = evt.detail.pageNumber;
        this.updateUrl();
        this.scrollToTop();
    }

    handleOrderChange(evt) {
        this.orderOption = evt.detail.value;
        this.orderDirection = 'asc';
        this.currentPage = 1;
        this.updateUrl();
    }

    handleOrderDirectionChange(evt) {
        this.orderDirection = evt.detail.value;
        this.currentPage = 1;
        this.updateUrl();
    }

    updateUrl() {
        let currentUrl = window.location.href.split('?')[0];
        history.pushState(null, '', currentUrl + '?page=' + this.currentPage);
    }

    scrollToTop() {
        let that = this;
        setTimeout(() => {
            that.template.querySelector(".page-filters").scrollIntoView({ block: 'start',  behavior: 'smooth' });
        }, 100);
    }

    filterCard(card) {
        let isFilter = true;

        if (this.searchFilter) {
            if (! card.title.toLowerCase().includes(this.searchFilter.toLowerCase())) isFilter = false;
        }

        let isCategory = true;
        if (this.categoryFilter) {
            let categories = this.categoryFilter.split('; ');
            isCategory = false;

            if (card.category) {
                let cardCategories = card.category.split(',');
                for (let j = 0; j < cardCategories.length; j++) {
                    for (let i = 0; i < categories.length; i++) {
                        if (categories[i] == cardCategories[j].trim()) isCategory = true; break;
                    }
                }
            }
        }

        return isFilter && isCategory;
    }

    handleSearchChange(evt) {
        this.currentPage = 1;
        this.searchFilter = evt.target.value;
        this.updateUrl();
    }

    handleCategoryChange(evt) {
        this.currentPage = 1;
        this.categoryFilter = evt.target.value;
    }

    handleReset(evt) {
        this.currentPage = 1;
        this.searchFilter = '';
        this.categoryFilter = '';
        this.template.querySelector('[data-name="category"]').clear();
    }
}