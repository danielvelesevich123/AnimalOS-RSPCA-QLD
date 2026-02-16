import {LightningElement, wire} from 'lwc';
import {CurrentPageReference} from "lightning/navigation";
import * as constants from 'c/constants';

export default class RspcaqldSectionCareers extends LightningElement {
    orderOption = 'name';
    orderDirection = 'asc';
    currentPage = 1;
    pageCount = 1;
    // filter = 'All';
    categoryFilter = '';
    locationFilter = '';
    isLoaded = false;
    isFilterFound = true;

    orderOptions = [
        { label: 'category', value: 'category'},
        { label: 'location', value: 'location'},
        { label: 'name', value: 'name'}
    ];

    closeDark = constants.closeDark;


    positions = [];

    @wire(CurrentPageReference)
    pageReference({state}) {
        if (state && state.page) {this.currentPage = state.page} else {
            this.currentPage = 1;
            this.updateUrl();
        }
    }

    // get categories() {
    //     let categoryFilters = [{label: 'All', class: this.filter == 'All' ? 'green-btn' : 'button-link'}];
    //     let categoriesSet = [];
    //     for (let i = 0; i < this.positions.data.length; i++) {
    //         categoriesSet.push(this.positions.data[i].category);
    //     }
    //     categoriesSet = [...new Set(categoriesSet)].sort();
    //
    //     for (let i = 0; i < categoriesSet.length; i++) {
    //         categoryFilters.push({label: categoriesSet[i], class: this.filter == categoriesSet[i] ? 'green-btn' : 'button-link'});
    //     }
    //     return categoryFilters;
    // }

    get categories() {
        if (this.positions) return this.getFilters('category');
    }

    get locations() {
        if (this.positions) return this.getFilters('location');
    }

    get filteredCards() {
        let cards = [];

        if (this.positions && this.positions.length > 0) {
            if (this.orderOption == 'category') {return this.sortCards('category');}
            if (this.orderOption == 'name') {return this.sortCards('title');}
            if (this.orderOption == 'location') {return this.sortCards('location');}

            return this.positions;
        }
        return cards;
    }

    sortCards(fieldName) {
        let cards = [];
        let fieldSet = [];
        for (let i = 0; i < this.positions.length; i++) {
            fieldSet.push(this.positions[i][fieldName]);
        }
        fieldSet = [...new Set(fieldSet)].sort();

        if (this.orderDirection == 'asc') {
            for (let i = 0; i < fieldSet.length; i++) {
                for (let j = 0; j < this.positions.length; j++) {
                    if (this.positions[j][fieldName] === fieldSet[i]) cards.push(this.positions[j]);
                }
            }
        } else {
            for (let i = (fieldSet.length - 1); i >= 0; i--) {
                for (let j = 0; j < this.positions.length; j++) {
                    if (this.positions[j][fieldName] === fieldSet[i]) cards.push(this.positions[j]);
                }
            }
        }
        return cards;
    }

    get pages() {
        let pages = [];
        let page = [];

        for (let i = 0; i < this.filteredCards.length; i++) {
            if (this.filterCard(this.filteredCards[i])) page.push(this.filteredCards[i]);

            if (page.length == 5 || this.filteredCards.length == (i + 1)) {
                let pageNumber = pages.length + 1;
                pages.push({cards: page, pageNumber: pageNumber, displayed: pageNumber == this.currentPage});
                page = [];
            }
        }

        this.pageCount = pages.length;
        this.isFilterFound = this.pageCount > 0 && pages[0].cards.length > 0;

        return pages;
    }

    get allCount() {
        return this.filteredCards.length;
    }

    get viewCount() {
        let _pages = this.pages;
        if (_pages !== undefined && _pages.length > 0) {
            for (let i = 0; i <= _pages.length; i++) {
                if (_pages[i].displayed) return _pages[i].cards.length;
            }
        }
        return 0;
    }

    scrollToTop() {
        let that = this;
        setTimeout(() => {
            that.template.querySelector(".page-careers-positions").scrollIntoView({ block: 'start',  behavior: 'smooth' });
        }, 100);
    }

    updateUrl() {
        let currentUrl = window.location.href.split('?')[0];
        history.pushState(null, '', currentUrl + '?page=' + this.currentPage);
    }

    handlePageChange(evt) {
        this.currentPage = evt.detail.pageNumber;
        this.scrollToTop();
        this.updateUrl();
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

    filterCard(card) {
        let categoriesList = this.categoryFilter ? this.categoryFilter.split('; ') : [];
        let locationsList = this.locationFilter ? this.locationFilter.split('; ') : [];
        return (!this.categoryFilter || categoriesList.includes(card.category)) && (!this.locationFilter || locationsList.includes(card.location));
    }

    handleFilterChange(evt) {
        this.currentPage = 1;
        this.updateUrl();
        let fieldName= evt.currentTarget.dataset.name;
        let fieldValue = evt.detail.value;

        if (fieldName == 'category') this.categoryFilter = fieldValue;
        if (fieldName == 'location') this.locationFilter = fieldValue;
    }

    handleReset() {
        this.currentPage = 1;
        this.updateUrl();
        this.categoryFilter = '';
        this.locationFilter = '';
        this.template.querySelector('[data-name="category"]').clear();
        this.template.querySelector('[data-name="location"]').clear();
    }

    getFilters(fieldName) {
        let filters = [];
        let filtersSet = [];
        for (let i = 0; i < this.positions.length; i++) {
            filtersSet.push(this.positions[i][fieldName]);
        }
        filtersSet = [...new Set(filtersSet)].sort();

        for (let i = 0; i < filtersSet.length; i++) {
            filters.push({label: filtersSet[i], value: filtersSet[i]});
        }
        return filters;
    }
}