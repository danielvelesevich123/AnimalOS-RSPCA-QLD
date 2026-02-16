import {LightningElement, wire} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldSectionEvents extends LightningElement {
    filters = {};
    orderOption = 'date';
    currentPage = 1;
    pageCount = 1;
    searchFilter;
    categoryFilter = '';
    locationFilter = '';
    dateFilter = '';
    _dateFilter;

    closeDark = constants.closeDark;

    eventCategoryOptions = { data: [] };
    events = { data: [] };
    orderOptions = [
        { label: 'date', value: 'date' },
        { label: 'name', value: 'name' }
    ];
    orderDirection = 'asc';

    connectedCallback() {}

    get filteredCards() {
        if (this.orderOption == 'name') {
            return this.sortCards('Name');
        }
        if (this.orderOption == 'date') {
            return this.sortCards('EndDate');
        }
        return this.events.data;
    }

    sortCards(fieldName) {
        let cards = [];
        let fieldSet = [];
        for (let i = 0; i < this.events.data.length; i++) {
            fieldSet.push(this.events.data[i].record[fieldName]);
        }
        fieldSet = [...new Set(fieldSet)].sort();
        if (this.orderDirection == 'asc') {
            for (let i = 0; i < fieldSet.length; i++) {
                for (let j = 0; j < this.events.data.length; j++) {
                    if (this.events.data[j].record[fieldName] === fieldSet[i]) cards.push(this.events.data[j]);
                }
            }
        } else {
            for (let i = (fieldSet.length - 1); i >= 0; i--) {
                for (let j = 0; j < this.events.data.length; j++) {
                    if (this.events.data[j].record[fieldName] === fieldSet[i]) cards.push(this.events.data[j]);
                }
            }
        }

        let featured = [];
        let unfeatured = [];
        for (let i = 0; i < cards.length; i++) {
            if (cards[i].record.Featured_Event__c) featured.push(cards[i]);
            if (!cards[i].record.Featured_Event__c) unfeatured.push(cards[i]);
        }
        let featuredCards = featured.concat(unfeatured);

        return featuredCards;
    }

    get pages() {
        let pages = [];
        let page = [];

        if (this.events && this.events.data) {
            for (let i = 0; i < this.filteredCards.length; i++) {
                if (this.filterCard(this.filteredCards[i])) page.push(this.filteredCards[i]);

                if (page.length == 5 || this.filteredCards.length == (i + 1)) {
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
        return this.events && this.events.data ? this.filteredCards.length : 0;
    }

    get viewCount() {
        let _pages = this.pages;
        if (_pages && _pages.length > 0) {
            for (let i = 0; i <= _pages.length; i++) {
                if (_pages[i].displayed) return _pages[i].cards.length;
            }
        }
        return null;
    }

    get locationOptions() {
        let _locationOptions = [];
        let _locations = [];
        if (this.events && this.events.data) {
            for (let i = 0; i < this.events.data.length; i++) {
                if (this.events.data[i].filterAddress) _locations.push(this.events.data[i].filterAddress);
            }
        }
        _locations = [...new Set(_locations)].sort();

        for (let i = 0; i < _locations.length; i++) {
            _locationOptions.push({label: _locations[i], value: _locations[i]});
        }
        return _locationOptions;
    }

    handlePageChange(evt) {
        this.currentPage = evt.detail.pageNumber;
        window.scrollTo({
            top: 0,
            behavior: 'smooth',
        });
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

    filterCard(card) {
        let isFilter = true;

        if (this.searchFilter) {
            if (!card.record.Name.toLowerCase().includes(this.searchFilter.toLowerCase()) &&
                !card.address.toLowerCase().includes(this.searchFilter.toLowerCase()) &&
                !card.eventDate.toLowerCase().includes(this.searchFilter.toLowerCase())) isFilter = false;
        }

        if (this.categoryFilter) {
            let categories = this.categoryFilter.split('; ');
            if (! categories.includes(card.record.Event_Category__c)) isFilter = false;
        }

        if (this.locationFilter) {
            let locations = this.locationFilter.split('; ');
            if (! locations.includes(card.filterAddress)) isFilter = false;
        }

        return isFilter;
    }

    handleSearchChange(evt) {
        this.searchFilter = evt.target.value;
    }

    handleCategoryChange(evt) {
        this.categoryFilter = evt.target.value;
    }

    handleLocationChange(evt) {
        this.locationFilter = evt.target.value;
    }

    // handleDateChange(evt) {
    //     if (evt.target.value) {
    //         this._dateFilter = new Date(evt.target.value);
    //     } else {
    //         this._dateFilter = null;
    //     }
    // }

    handleReset(evt) {
        this.searchFilter = '';
        this.categoryFilter = '';
        this.locationFilter = '';
        // this.dateFilter = '';
        // this._dateFilter = null;
    }
}