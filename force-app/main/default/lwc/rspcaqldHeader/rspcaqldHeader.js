import getArticles from '@salesforce/apex/ManagedContentService.getManagedContentByContentKeys';
import {api, wire, LightningElement} from 'lwc';
import * as constants from 'c/constants';
import {
    subscribe,
    publish,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import breadcrumbs from '@salesforce/messageChannel/Breadcrumbs__c';
import mobileMenu from '@salesforce/messageChannel/MobileMenu__c';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';

export default class RspcaqldHeader extends NavigationMixin(LightningElement) {
    @api donateLinkLabel = 'Donate';
    @api donateLinkURL;
    @api adoptHeader;
    @api adoptDescription;
    @api adoptHeaderLinkLabel;
    @api adoptHeaderLinkUrl;
    @api adoptFindPetUrl;
    @api adoptLocationUrl;
    @api adoptArticlesHeader;
    @api adoptArticlesKeys;
    @wire(getArticles, {contentKeysString: '$adoptArticlesKeys'}) adoptArticles;
    @api getInvolvedHeader;
    @api getInvolvedDescription;
    @api getInvolvedHeaderLinkLabel;
    @api getInvolvedHeaderLinkUrl;
    @api getInvolvedLeftColumnLinksString;
    @api getInvolvedRightColumnLinksString;
    @api getInvolvedArticlesHeader;
    @api getInvolvedArticlesKeys;
    @wire(getArticles, {contentKeysString: '$getInvolvedArticlesKeys'}) getInvolvedArticles;
    @api servicesHeader;
    @api servicesDescription;
    @api servicesHeaderLinkLabel;
    @api servicesHeaderLinkUrl;
    @api servicesLeftColumnLinksString;
    @api servicesRightColumnLinksString;
    @api servicesArticlesHeader;
    @api servicesArticlesKeys;
    @wire(getArticles, {contentKeysString: '$servicesArticlesKeys'}) servicesArticles;
    @api resourcesHeader;
    @api resourcesDescription;
    @api resourcesHeaderLinkLabel;
    @api resourcesHeaderLinkUrl;
    @api resourcesLeftColumnLinksString;
    @api resourcesRightColumnLinksString;
    @api resourcesArticlesHeader;
    @api resourcesArticlesKeys;
    @wire(getArticles, {contentKeysString: '$resourcesArticlesKeys'}) resourcesArticles;
    @api aboutHeader;
    @api aboutDescription;
    @api aboutHeaderLinkLabel;
    @api aboutHeaderLinkUrl;
    @api aboutLeftColumnLinksString;
    @api aboutRightColumnLinksString;
    @api aboutArticlesHeader;
    @api aboutArticlesKeys;
    @api showAlert = false;
    @api searchPlaceholder;
    @api searchQuickLinksString;
    @api notificationMessage;
    @api alertMessage;
    @wire(getArticles, {contentKeysString: '$aboutArticlesKeys'}) aboutArticles;

    @api urgentReportCardIcon;
    @api urgentReportCardHeader;
    @api urgentReportCardDescription;
    @api urgentReportCardLinkLabel;
    @api urgentReportCardLinkPhone;
    @api infoReportCardIcon;
    @api infoReportCardHeader;
    @api infoReportCardDescription;
    @api infoReportCardLinkLabel;
    @api infoReportCardLinkUrl;
    @api reportType;

    notificationType = 'warning';
    isOpen = false;
    isSearchOpen = false;
    isReportOpen = false;
    searchValue;
    selectedMenu;
    breadcrumbsSubscription = null;
    parents;
    current;
    breadcrumbBlack = false;
    submenuTopStyle = 'top: 154px;';

    whiteLogoURL = constants.whiteLogoURL;
    colourLogoURL = constants.colourLogoURL;
    dogSitBlue = constants.dogSitBlue;
    dogFaceBlue = constants.dogFaceBlue;
    catSitBlue = constants.catSitBlue;
    catFaceBlue = constants.catFaceBlue;
    snakeBlue = constants.snakeBlue;
    mouseBlue = constants.mouseBlue;
    pigBlue = constants.pigBlue;
    bigBirdBlue = constants.bigBirdBlue;
    magnifingGlassWhite = constants.magnifingGlassWhite;
    magnifingGlassBlue = constants.magnifingGlassBlue;
    closeWhite = constants.closeWhite;
    arrowRightBlue = constants.arrowRightBlue;

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    wiredCurrentPageReference(currentPageReference) {
        this.parents = null;
        this.current = null;
        this.closeMenu();
        publish(this.messageContext, mobileMenu, {open: false});
    }

    @api
    get notificationBarHeight() {
        let notificationBar = this.template.querySelector('.notification-bar');
        return notificationBar.offsetHeight;
    }

    get mainClass() {
        return this.isOpen ? 'site-header open' : 'site-header';
    }

    get mobileMenuIconClass() {
        return this.isOpen ? 'utility:close' : 'utility:rows';
    }

    get backdropClass() {
        return this.isOpen ? 'backdrop open' : 'backdrop';
    }

    get whiteLogoStyle() {
        return this.isOpen ? '' : 'display: none;';
    }

    get colourLogoStyle() {
        return this.isOpen ? 'display: none;' : '';
    }

    get adoptClass() {
        return this.getBasicClass('adopt');
    }

    get adoptSubmenuClass() {
        return this.getBasicSubmenuClass('adopt');
    }

    get involvedClass() {
        return this.getBasicClass('involved');
    }

    get involvedSubmenuClass() {
        return this.getBasicSubmenuClass('involved');
    }

    get servicesClass() {
        return this.getBasicClass('services');
    }

    get servicesSubmenuClass() {
        return this.getBasicSubmenuClass('services');
    }

    get resourcesClass() {
        return this.getBasicClass('resources');
    }

    get resourcesSubmenuClass() {
        return this.getBasicSubmenuClass('resources');
    }

    get aboutClass() {
        return this.getBasicClass('about');
    }

    get aboutSubmenuClass() {
        return this.getBasicSubmenuClass('about');
    }

    get mobileMenuClass() {
        return this.getBasicSubmenuClass('mobile');
    }

    get notificationIcon() {
        if (this.showAlert) {
            return this.notificationType == 'information' ? 'xdefault fa-solid fa-circle-info' : 'xdefault fa-solid fa-triangle-exclamation';
        } else {
            return null;
        }
    }

    get notificationClass() {
        let className = 'notification-bar';
        if (this.showAlert) {
            className = className + ' ' + this.notificationType;
        }
        return className;
    }

    get searchSubmenuClass() {
        return this.isSearchOpen ? 'search-submenu active' : 'search-submenu';
    }

    get searchIcon() {
        return this.isSearchOpen ? 'large fa-solid fa-magnifying-glass' : 'large fa-regular fa-magnifying-glass';
    }

    get searchCloseStyle() {return this.isSearchOpen ? 'display: none;' : '';}
    get searchOpenStyle() {return this.isSearchOpen ? '' : 'display: none;';}

    get reportClass() {
        return this.isReportOpen ? 'header-report active' : 'header-report';
    }

    get isCurrent() {
        return this.current ? true : false;
    }

    get adoptDogsLink() {return this.adoptFindPetUrl + '?type=dog';}
    get adoptPuppiesLink() {return this.adoptFindPetUrl + '?type=puppy';}
    get adoptCatsLink() {return this.adoptFindPetUrl + '?type=cat';}
    get adoptKittensLink() {return this.adoptFindPetUrl + '?type=kitten';}
    get adoptReptilesLink() {return this.adoptFindPetUrl + '?type=reptile';}
    get adoptSmallerAnimalsLink() {return this.adoptFindPetUrl + '?type=smallanimal';}
    get adoptFarmYardLink() {return this.adoptFindPetUrl + '?type=farmyard';}
    get adoptBirdsLink() {return this.adoptFindPetUrl + '?type=bird';}

    get getInvolvedLeftColumnLinks() {
        let _getInvolvedLeftColumnLinks = this.getInvolvedLeftColumnLinksString ? JSON.parse(this.getInvolvedLeftColumnLinksString) : [];
        return this.updateColumnLinks(_getInvolvedLeftColumnLinks);
    }

    get getInvolvedRightColumnLinks() {
        let _getInvolvedRightColumnLinks = this.getInvolvedRightColumnLinksString ? JSON.parse(this.getInvolvedRightColumnLinksString) : [];
        return this.updateColumnLinks(_getInvolvedRightColumnLinks);
    }

    get servicesLeftColumnLinks() {
        let _getServicesLeftColumnLinks = this.servicesLeftColumnLinksString ? JSON.parse(this.servicesLeftColumnLinksString) : [];
        return this.updateColumnLinks(_getServicesLeftColumnLinks);
    }

    get servicesRightColumnLinks() {
        let _getServicesRightColumnLinks = this.servicesRightColumnLinksString ? JSON.parse(this.servicesRightColumnLinksString) : [];
        return this.updateColumnLinks(_getServicesRightColumnLinks);
    }

    get resourcesLeftColumnLinks() {
        let _getResourcesLeftColumnLinks = this.resourcesLeftColumnLinksString ? JSON.parse(this.resourcesLeftColumnLinksString) : [];
        return this.updateColumnLinks(_getResourcesLeftColumnLinks);
    }

    get resourcesRightColumnLinks() {
        let _getResourcesRightColumnLinks = this.resourcesRightColumnLinksString ? JSON.parse(this.resourcesRightColumnLinksString) : [];
        return this.updateColumnLinks(_getResourcesRightColumnLinks);
    }

    get aboutLeftColumnLinks() {
        let _getAboutLeftColumnLinks = this.aboutLeftColumnLinksString ? JSON.parse(this.aboutLeftColumnLinksString) : [];
        return this.updateColumnLinks(_getAboutLeftColumnLinks);
    }

    get aboutRightColumnLinks() {
        let _getAboutRightColumnLinks = this.aboutRightColumnLinksString ? JSON.parse(this.aboutRightColumnLinksString) : [];
        return this.updateColumnLinks(_getAboutRightColumnLinks);
    }

    get searchInputLink() {
        let link = '../../search-results';
        if (this.searchValue) link += '?val=' + this.searchValue;
        return link;
    }

    get searchQuickLinks() {
        let quickLinks = [];
        if (this.searchQuickLinksString) {
            quickLinks = JSON.parse(this.searchQuickLinksString);
            for (let i = 0; i < quickLinks.length; i++) {
                quickLinks[i].url = '/' + quickLinks[i].url;
            }
        }
        return quickLinks;
    }

    get isUrgentReport() {
        return this.reportType && this.reportType == 'urgent';
    }

    get isInformationReport() {
        return this.reportType && this.reportType == 'information';
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    renderedCallback() {
        this.template.querySelector('.site-header').addEventListener('focusout',
            this.handleBlur);
        window.addEventListener('resize', (event) => {this.handleResize(event)});
        this.handleResize();
    }

    updateColumnLinks(columns) {
        for (let i = 0; i < columns.length; i++) {
            columns[i].headerUrl = this.updateColumnLink(columns[i].headerUrl);

            for (let j = 0; j < columns[i].links.length; j++) {
                columns[i].links[j].url = this.updateColumnLink(columns[i].links[j].url);
            }
        }
        return columns;
    }

    updateColumnLink(link) {
        return link && link != '#' && !link.startsWith('/') && !link.startsWith('https') ? '/' + link : link;
    }

    subscribeToMessageChannel() {
        if (!this.breadcrumbsSubscription) {
            this.breadcrumbsSubscription = subscribe(
                this.messageContext,
                breadcrumbs,
                (message) => this.handleBreadcrumbsMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleBreadcrumbsMessage(message) {
        if (message) {
            this.parents = message.parents;
            this.current = message.current;
            if (message.isBlack) this.breadcrumbBlack = true;
        }
    }

    handleBlur = (evt) => {
        setTimeout(() => this.handleClose(evt), 100);
    }

    handleClose(evt) {
        if (!this.template.activeElement ||
            (this.template.activeElement &&
                (this.template.activeElement.nodeName.toLowerCase() != 'lightning-input' &&
                    this.template.activeElement.nodeName.toLowerCase() != 'div' &&
                    this.template.activeElement.nodeName.toLowerCase() != 'button' &&
                    this.template.activeElement.nodeName.toLowerCase() != 'a' &&
                    this.template.activeElement.nodeName.toLowerCase() != 'c-rspcaqld-header-sub-nav'))) {
            this.closeMenu();
        }
    }

    closeMenu() {
        this.selectedMenu = null;
        this.isOpen = false;
        this.isSearchOpen = false;
        this.searchValue = null;
    }

    handleMenuClick(evt) {
        if (this.selectedMenu != evt.currentTarget.dataset.value) {
            this.selectedMenu = evt.currentTarget.dataset.value;
            this.isOpen = true;
            this.isSearchOpen = false;
            this.searchValue = null;
            this.template.querySelector('.site-header').focus();
        } else {
            this.closeMenu();
        }
    }

    handleMobileMenuClick(evt) {
        if (this.isOpen) {
            this.closeMenu();
            publish(this.messageContext, mobileMenu, {open: false});
        } else {
            this.handleMenuClick(evt);
            publish(this.messageContext, mobileMenu, {open: true});
        }
    }

    handleSearchClick(evt) {
        this.selectedMenu = null;
        this.isOpen = true;
        this.isSearchOpen = true;
        this.template.querySelector('.site-header').focus();
    }

    handleReportClick(evt) {
        this.isReportOpen = true;
    }

    handleReportClose(evt) {
        this.isReportOpen = false;
    }

    handleReportSelect(evt) {
        this.reportType = evt.detail.type;
    }

    getBasicClass(menuName) {
        let basicClass = 'navigation-link';
        if (! this.isOpen) basicClass += ' black';
        if (this.selectedMenu && this.selectedMenu == menuName) basicClass += ' active';
        return basicClass;
    }

    getBasicSubmenuClass(menuName) {
        let basicClass = 'subnav';
        if (this.selectedMenu && this.selectedMenu == menuName) basicClass += ' active';
        return basicClass;
    }

    handleReportPopupClick(evt) {
        if (evt.target.className.includes('report-pop-up')) this.handleReportClose();
    }

    handleDonate(evt) {
        window.location.replace('donation-form');
    }

    // handleBrowsePets(evt) {
    //     window.location.replace('find-pet');
    // }

    handleResize(evt) {
        let navHeight = 110 + this.notificationBarHeight;
        this.submenuTopStyle = 'top: ' + navHeight + 'px';
    }

    handleSearchChange(evt) {
        this.searchValue = evt.detail.value;
    }

    handleSearchKeydown(evt) {
        let keyCode = evt.which || evt.keyCode || 0;
        if (keyCode == 13) {
            this.selectedMenu = null;
            this.isOpen = false;
            this.isSearchOpen = false;
            publish(this.messageContext, mobileMenu, {open: false});

            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.searchInputLink
                },
            });
        }
    }
}