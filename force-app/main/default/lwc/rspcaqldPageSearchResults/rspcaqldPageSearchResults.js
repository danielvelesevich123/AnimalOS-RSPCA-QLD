import {LightningElement, wire} from 'lwc';
import {MessageContext, publish} from "lightning/messageService";
import {CurrentPageReference} from "lightning/navigation";
import * as constants from 'c/constants';

export default class RspcaqldPagePrivacyPolicy extends LightningElement {
    orderOption = 'name';
    orderDirection = 'asc';
    methodsCount = 0;
    currentPage = 1;
    pageCount = 1;
    searchValue;
    results = [];
    isSearching = false;

    magnifingGlassWhite = constants.magnifingGlassWhite;

    orderOptions = [
        { label: 'type', value: 'type' },
        { label: 'name', value: 'name' }
    ];

    messageContext = { data: [] };
    @wire(CurrentPageReference)
    getValue({state}) {
        if (state && state.val) {
            if (!this.searchValue || this.searchValue != state.val) {
                this.searchValue = state.val; this.handleSearch();
            }
        }
    }

    connectedCallback() {}

    get filteredCards() {
        if (this.orderOption == 'name') {
            return this.sortCards('title');
        }
        if (this.orderOption == 'type') {
            return this.sortCards('type');
        }

        return this.results;
    }

    get pages() {
        let pages = [];
        let page = [];

        if (this.results) {
            let _filteredCards = this.filteredCards;
            for (let i = 0; i < _filteredCards.length; i++) {
                page.push(_filteredCards[i]);

                if (page.length == 5 || _filteredCards.length == (i + 1)) {
                    let pageNumber = pages.length + 1;
                    pages.push({cards: page, pageNumber: pageNumber, displayed: pageNumber == this.currentPage});
                    page = [];
                }
            }

            this.pageCount = pages.length;
        }

        return pages;
    }

    get allCount() {
        return this.results ? this.filteredCards.length : 0;
    }

    get viewCount() {
        let _pages = this.pages;
        if (_pages && _pages.length > 0) {
            for (let i = 0; i <= this.pages.length; i++) {
                if (this.pages[i].displayed) return this.pages[i].cards.length;
            }
        }
        return 0;
    }

    sortCards(fieldName) {
        let cards = [];
        let fieldSet = [];
        for (let i = 0; i < this.results.length; i++) {
            fieldSet.push(this.results[i][fieldName]);
        }
        fieldSet = [...new Set(fieldSet)].sort();
        if (this.orderDirection == 'asc') {
            for (let i = 0; i < fieldSet.length; i++) {
                for (let j = 0; j < this.results.length; j++) {
                    if (this.results[j][fieldName] === fieldSet[i]) cards.push(this.results[j]);
                }
            }
        } else {
            for (let i = (fieldSet.length - 1); i >= 0; i--) {
                for (let j = 0; j < this.results.length; j++) {
                    if (this.results[j][fieldName] === fieldSet[i]) cards.push(this.results[j]);
                }
            }
        }

        return cards;
    }

    handlePageChange(evt) {
        this.currentPage = evt.detail.pageNumber;
    }

    handleSearchChange(evt) {
        this.searchValue = evt.detail.value;
    }

    handleOrderChange(evt) {
        this.orderOption = evt.detail.value;
        this.orderDirection = 'asc';
        this.currentPage = 1;
    }

    handleOrderDirectionChange(evt) {
        this.orderDirection = evt.detail.value;
        this.currentPage = 1;
    }

    handleSearchKeydown(evt) {
        let keyCode = evt.which || evt.keyCode || 0;
        if (keyCode == 13) {
            this.handleSearch();
        }
    }

    handleSearch(evt) {
        this.methodsCount = 0;
        this.isSearching = true;
        this.results = [];
        let tempResults = [];

        let currentUrl = window.location.href.split('?')[0];
        let oldValue = window.location.href.split('?').length > 1 ? window.location.href.split('?')[1] : null;
        if (oldValue != this.searchValue) history.pushState(null, '', currentUrl + '?val=' + this.searchValue);

        initLocationResults({searchValue: this.searchValue}).then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initEventResults({searchValue: this.searchValue}).then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initAnimalResults({searchValue: this.searchValue}).then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initCampaignResults({searchValue: this.searchValue}).then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initPositionResults({searchValue: this.searchValue}).then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initPartnerResults({searchValue: this.searchValue}).then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initReportResults({searchValue: this.searchValue}).then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initDirectorResults({searchValue: this.searchValue}).then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initPageResults({searchValue: this.searchValue}).then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initContentResults({searchValue: this.searchValue, type: 'Pet Care', contentType: 'pet_care', link: '/resources/pet-care/'})
            .then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initContentResults({searchValue: this.searchValue, type: 'Wildlife Advice', contentType: 'wildlife_advice', link: '/resources/wildlife/'})
            .then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initContentResults({searchValue: this.searchValue, type: 'Community', contentType: 'community_stories', link: '/resources/community/'})
            .then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initContentResults({searchValue: this.searchValue, type: 'Research and Industry', contentType: 'industry_research', link: '/resources/industry-research/'})
            .then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
        initContentResults({searchValue: this.searchValue, type: 'News', contentType: 'portal_news', link: '/about-us/news/'})
            .then(result => {tempResults = this.checkMethodsCount(tempResults, result);});
    }

    checkMethodsCount(tempResults, result) {
        tempResults.push(...result);
        this.methodsCount++;
        if (this.methodsCount == 14) {
            this.results = tempResults;
            this.isSearching = false;
        }
        return tempResults;
    }
}