import {api, LightningElement, wire} from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import * as constants from 'c/constants';

export default class RspcaqldSectionHomeHeader extends NavigationMixin(LightningElement) {
    @api imageUrl;
    @api imageKey;
    imageContentURL = { data: [] };
    @api header;
    @api adoptPetUrl = 'adopt';
    @api donateToRSPCAUrl = 'donate';
    @api findRSPCALocationUrl = 'rspca-locations';
    @api reportInjuredAnimalUrl = 'pet-service';
    @api findReportLostPetUrl = 'lost-found';
    @api makeAnimalWelfareComplaintUrl = 'welfare-complaint';
    @api searchSiteUrl = 'search-results';
    searchValue;
    isSupportOpen = false;
    closeDark = constants.closeDark;

    get image(){
        return this.imageContentURL.data ? this.imageContentURL.data : (this.imageUrl ? this.imageUrl : null);
    }
    get isImage() {return this.image ? true : false;}

    get searchInputLink() {
        let link = '../../' + this.searchSiteUrl;
        if (this.searchValue) link += '?val=' + this.searchValue;
        return link;
    }

    handleSupportOpen(evt) {
        this.isSupportOpen = true;
        document.body.style.overflow = 'hidden';
    }

    handleSupportClose(evt) {
        this.isSupportOpen = false;
        document.body.style.overflow = 'auto';
    }

    handleSupportPopupClick(evt) {
        if (evt.target.className == 'pop-up') this.handleSupportClose();
    }

    handleSearchChange(evt) {
        this.searchValue = evt.detail.value;
    }

    handleSearchKeydown(evt) {
        let keyCode = evt.which || evt.keyCode || 0;
        if (keyCode == 13) {
            this.isSupportOpen = false;
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.searchInputLink
                },
            });
        }
    }

    get supportClass() {return this.isSupportOpen ? 'pop-up-home pop-up-container active' : 'pop-up-home pop-up-container';}

    get backdropClass() {return this.isSupportOpen ? 'backdrop open' : 'backdrop';}
}