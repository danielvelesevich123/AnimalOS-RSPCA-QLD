import {api, LightningElement} from 'lwc';

export default class RspcaqldCardsPagination extends LightningElement {
    @api pageCount = 1;
    @api currentPage = 1;

    get pages() {
        let _pages = [];
        let startPage = this.currentPage < 4 ? 1 : (this.currentPage > this.pageCount - 3 ? this.pageCount - 3 : this.currentPage - 1);
        let finishPage = this.currentPage > this.pageCount - 3 ? this.pageCount : startPage + 3;

        for (var i = startPage; i <= finishPage; i++) {
            _pages.push(
                { number: i, class: i == this.currentPage ? 'active page-number' : 'page-number'}
            );
        }
        return _pages;
    }

    get leftButtonClass() {
        return 'pagination-button' + (this.currentPage == 1 ? ' disabled' : '');
    }

    get displayLeftButton() {return this.currentPage != 1;}

    get rightButtonClass() {
        return 'pagination-button' + (this.currentPage == this.pageCount ? ' disabled' : '');
    }

    get displayRightButton() {return this.currentPage != this.pageCount;}

    get displayPagination() {return this.pageCount > 1;}

    leftClick(evt) {
        this.currentPage = parseInt(this.currentPage) - 1;
        this.dispatchEvent(new CustomEvent("pagechange", {detail: {pageNumber : this.currentPage}}));
    }

    rightClick(evt) {
        this.currentPage = parseInt(this.currentPage) + 1;
        this.dispatchEvent(new CustomEvent("pagechange", {detail: {pageNumber : this.currentPage}}));
    }

    pageClick(evt) {
        this.currentPage = parseInt(evt.currentTarget.dataset.number);
        this.dispatchEvent(new CustomEvent("pagechange", {detail: {pageNumber : this.currentPage}}));
    }
}