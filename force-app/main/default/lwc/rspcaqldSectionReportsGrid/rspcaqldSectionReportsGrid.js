import {api, LightningElement} from 'lwc';

export default class RspcaqldSectionReportsGrid extends LightningElement {
    @api customClass;
    @api header = 'Browse our index of annual reports here';
    currentPage = 1;
    pageCount = 1;
    reports = { data: [] };

    get mainClass() {
        return 'page-our-impact background-20 ' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get pages() {
        let pages = [];
        let page = [];

        if (this.reports && this.reports.data) {
            let sortedReports = this.sortCards(this.reports.data, 'title');
            sortedReports = this.sortCards(sortedReports, 'publishedDate');

            for (let i = sortedReports.length - 1; i >= 0; i--) {
                page.push(sortedReports[i]);

                if (page.length == 8 || i == 0) {
                    let pageNumber = pages.length + 1;
                    pages.push({cards: page, pageNumber: pageNumber, displayed: pageNumber == this.currentPage});
                    page = [];
                }
            }

            this.pageCount = pages.length;
        }

        return pages;
    }

    sortCards(cards, fieldName) {
        let filteredCards = [];
        let fieldSet = [];

        for (let i = 0; i < cards.length; i++) {
            fieldSet.push(cards[i][fieldName]);
        }
        fieldSet = [...new Set(fieldSet)].sort();

        for (let i = 0; i < fieldSet.length; i++) {
            for (let j = 0; j < cards.length; j++) {
                if (cards[j][fieldName] === fieldSet[i]) filteredCards.push(cards[j]);
            }
        }
        return filteredCards;
    }

    handlePageChange(evt) {
        this.currentPage = evt.detail.pageNumber;
        this.template.querySelector(".page-results").scrollIntoView({ block: 'start',  behavior: 'smooth' });
    }
}