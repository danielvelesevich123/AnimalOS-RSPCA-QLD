import {api, LightningElement, wire} from 'lwc';
import mobileMenu from '@salesforce/messageChannel/MobileMenu__c';
import headerAction from '@salesforce/messageChannel/HeaderAction__c';
import { CurrentPageReference } from 'lightning/navigation';
import {
    subscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';

/**
 * @slot header
 * @slot footer
 * @slot default
 */
export default class RspcaqldThemeLayout extends LightningElement {
    @api showAlert = false;
    @api notificationMessage = '<h6>Seen an animal in distress? Call 1800 ANIMAL</h6>';
    @api alertMessage;

    @api urgentReportCardIcon;
    @api urgentReportCardHeader = 'Urgent';
    @api urgentReportCardDescription = 'If animal is seriously injured or trapped, call us imediatley.';
    @api urgentReportCardLinkLabel = 'Call 1300 264 625';
    @api urgentReportCardLinkPhone = '1300 264 625';
    @api infoReportCardIcon;
    @api infoReportCardHeader = 'Information';
    @api infoReportCardDescription = 'Animal is injured, sick or neglected and requires attention.';
    @api infoReportCardLinkLabel = 'Report to us';
    @api infoReportCardLinkUrl;

    @api donateLinkLabel = 'Donate';
    @api donateLinkURL;

    @api adoptHeader = 'Adopt a Pet';
    @api adoptDescription = 'Looking for a companion? Adopting a pet is a wonderful way of giving an animal in need a second chance! Learn more about adopting a pet and the RSPCA adoption process here.';
    @api adoptHeaderLinkLabel = 'Adoption Overview';
    @api adoptHeaderLinkUrl = 'adopt';
    @api adoptFindPetUrl;
    @api adoptLocationUrl;
    @api adoptArticlesHeader = 'Adoption education';
    @api adoptArticlesKeys;
    @api getInvolvedHeader = 'Get Involved';
    @api getInvolvedDescription = 'Our vital work is supported by animal lovers like you. There are many ways you can help us continue to change lives - from volunteering your time or attending an event, to donating or shopping with us.';
    @api getInvolvedHeaderLinkLabel = 'Learn how you can help';
    @api getInvolvedHeaderLinkUrl;
    @api getInvolvedLeftColumnLinksString = '[{"headerLabel": "Volunteering", "headerUrl": "volunteering", "links": [{"label": "Foster an animal", "url": "#"},{"label": "Volunteer your time", "url": "#"},{"label": "Corporate experience days", "url": "#"},{"label": "Animal welfare advocacy", "url": "#"},{"label": "Volunteer stories", "url": "#"}]}, {"headerLabel": "Events", "headerUrl": "events", "links": [{"label": "Million paws walk", "url": "#"},{"label": "Community days (listing)", "url": "#"},{"label": "Another event here", "url": "#"}]}]';
    @api getInvolvedRightColumnLinksString = '[{"headerLabel": "Donate", "headerUrl": "donate", "links": [{"label": "Make a donation", "url": "#"},{"label": "Leave a gift in your will", "url": "#"},{"label": "Get your business involved", "url": "#"},{"label": "Fundraise", "url": "#"},{"label": "Raffle tickets", "url": "#"}]}, {"headerLabel": "Shop", "headerUrl": "shops", "links": [{"label": "Pet supplies", "url": "#"},{"label": "RSPCA Op-Shops", "url": "#"}]}]';
    @api getInvolvedArticlesHeader = 'Featured reads';
    @api getInvolvedArticlesKeys;
    @api servicesHeader = 'Our Services';
    @api servicesDescription = 'At RSPCA Queensland we support people, pets, and our wildlife. Learn about pet training, finding lost pets, services in the community, how to report animal welfare concerns, and our vital work helping wildlife.';
    @api servicesHeaderLinkLabel = 'Browse all services';
    @api servicesHeaderLinkUrl;
    @api servicesLeftColumnLinksString = '[{"headerLabel": "Welfare Services", "headerUrl": "welfare-services", "links": [{"label": "Animal welfare complaint", "url": "welfare-complaint"},{"label": "Animal rescue units", "url": "#"}]},{"headerLabel": "Wildlife Services", "headerUrl": "wildlife-services", "links": [{"label": "Injured wildlife", "url": "#"},{"label": "Wildlife Hospital", "url": "#"},{"label": "Wildlife Education", "url": "#"}]},{"headerLabel": "Community", "headerUrl": "community-services", "links": [{"label": "Working with community", "url": "#"},{"label": "Working with youth", "url": "#"}]}]';
    @api servicesRightColumnLinksString = '[{"headerLabel": "Pet Services", "headerUrl": "pet-services", "links": [{"label": "Pet Surrender", "url": "#"},{"label": "Pets in Crisis", "url": "#"},{"label": "Lost and Found Pets", "url": "#"},{"label": "Pet Training", "url": "#"},{"label": "Pet Boarding and Grooming", "url": "#"},{"label": "Pet Sitting and Home Alone", "url": "#"},{"label": "Pet Insurance", "url": "#"},{"label": "Pet Cremation", "url": "#"}]}]';
    @api servicesArticlesHeader = 'Featured reads';
    @api servicesArticlesKeys;
    @api resourcesHeader = 'Resources, Education & Advice';
    @api resourcesDescription = 'Have a question about animals? Here you can learn the latest animal news, pet care and tips you can apply at home, advice about living with wildlife, and much more!';
    @api resourcesHeaderLinkLabel = 'Browse all resources';
    @api resourcesHeaderLinkUrl;
    @api resourcesLeftColumnLinksString = '[{"headerLabel": "Pet care advice", "headerUrl": "pet-care", "links": [{"label": "Pet care advice category", "url": "#"},{"label": "View all Pet care", "url": "pet-care"}]},{"headerLabel": "Community advice", "headerUrl": "community-stories", "links": [{"label": "Community advice category", "url": "#"},{"label": "View all Community", "url": "community-stories"}]}]';
    @api resourcesRightColumnLinksString = '[{"headerLabel": "Wildlife advice", "headerUrl": "wildlife-advice", "links": [{"label": "Wildlife Advice category", "url": "#"},{"label": "View all Wildlife", "url": "wildlife-advice"}]},{"headerLabel": "Research & Industry", "headerUrl": "industry-research", "links": [{"label": "Research category", "url": "#"},{"label": "View all Research", "url": "industry-research"}]}]';
    @api resourcesArticlesHeader = 'Featured reads';
    @api resourcesArticlesKeys;
    @api aboutHeader = 'What We do';
    @api aboutDescription = 'Formed in 1883, RSPCA Queensland is a non-government, community-based charity dedicated to improving the lives of all animals. Learn about how the impact of your support helps to change lives.';
    @api aboutHeaderLinkLabel = 'About us';
    @api aboutHeaderLinkUrl;
    @api aboutLeftColumnLinksString = '[{"headerLabel": "Our Pillars", "headerUrl": "our-pillars", "links": [{"label": "Socially Conscious Animal Communities", "url": "#"},{"label": "Save Animals", "url": "#"},{"label": "Care for Wildlife", "url": "#"},{"label": "Animal Welfare Advocacy", "url": "#"}]},{"headerLabel": "News", "headerUrl": "news", "links": [{"label": "Latest News", "url": "#"},{"label": "Meet our Ambassadors", "url": "#"},{"label": "Partners", "url": "our-partners"}]}]';
    @api aboutRightColumnLinksString = '[{"headerLabel": "Our Charity", "headerUrl": "#", "links": [{"label": "About Us", "url": "#"},{"label": "Contact us", "url": "contact-us"},{"label": "RSPCA Locations", "url": "locations"},{"label": "Common misconceptions", "url": "misconceptions"},{"label": "Impact reports", "url": "our-impact"},{"label": "Our Board", "url": "directors"},{"label": "Careers", "url": "careers"}]}]';
    @api aboutArticlesHeader = 'Featured reads';
    @api aboutArticlesKeys;

    @api searchPlaceholder = 'Type your keywords and hit enter to search the site…';
    @api searchQuickLinksString;

    @api ourPromiseHeader = 'Our Promise';
    @api ourPromiseDescription = 'We will transition from being reactive to proactive as we seek to address the root cause of animal welfare issues; and by building Socially Conscious Animal Communities. Learn how';
    @api ourPromiseLocationLink = '{"label": "RSPCA Locations", "link": "locations"}';
    @api ourPromisePhone = '{"label": "07 3426 9999<br>(General enquiries)", "link": "07 3426 9999"}';
    @api ourPromiseEmail = '{"label": "Send us an email", "link": "rspcaadmin@rspcaqld.org.au"}';
    @api adoptFooterLinksString = '{"headerLabel": "Adopt", "headerUrl": "adopt", "links": [{"label": "Dogs", "url": "find-pet?type=dog"},{"label": "Cats", "url": "find-pet?type=cat"},{"label": "Reptiles", "url": "find-pet?type=reptile"},{"label": "Fish", "url": "find-pet?type=fish"},{"label": "Small Animals", "url": "find-pet?type=smallanimals"},{"label": "Birds", "url": "find-pet?type=birds"}]}';
    @api resourcesFooterLinksString = '{"headerLabel": "Resources", "headerUrl": "resources", "links": [{"label": "Pet Care", "url": "pet-care"},{"label": "In the Community", "url": "community-stories"},{"label": "Wildlife Care", "url": "wildlife-advice"},{"label": "Research & Industry", "url": "industry-research"},{"label": "Browse Blog", "url": "#"}]}';
    @api getinvolvedFooterLinksString = '{"headerLabel": "Get Involved", "headerUrl": "get-involved", "links": [{"label": "Volunteer", "url": "volunteering"},{"label": "Foster", "url": "#"},{"label": "Donate", "url": "donate"},{"label": "Fundraise", "url": "#"},{"label": "Leave a gift in your will", "url": "#"},{"label": "Corporate Experience", "url": "#"},{"label": "Get your business involved", "url": "#"},{"label": "Raffle Tickets", "url": "#"},{"label": "Events", "url": "events"}]}';
    @api welfareFooterLinksString = '{"headerLabel": "Welfare Services", "headerUrl": "welfare-services", "links": [{"label": "Animal welfare complaint", "url": "welfare-complaint"},{"label": "Animal rescue units", "url": "#"}]}';
    @api wildlifeFooterLinksString = '{"headerLabel": "Wildlife Services", "headerUrl": "wildlife-services", "links": [{"label": "Injured wildlife", "url": "#"},{"label": "Wildlife Hospital", "url": "#"},{"label": "Wildlife Education", "url": "#"}]}';
    @api communityFooterLinksString = '{"headerLabel": "Community", "headerUrl": "community-services", "links": [{"label": "Working with community", "url": "#"},{"label": "Working with youth", "url": "#"}]}';
    @api servicesFooterLinksString = '{"headerLabel": "Pet Services", "headerUrl": "pet-services", "links": [{"label": "Pet Surrender", "url": "#"},{"label": "Pets in Crisis", "url": "#"},{"label": "Lost and Found Pets", "url": "#"},{"label": "Pet Training", "url": "#"},{"label": "Pet Boarding and Grooming", "url": "#"},{"label": "Pet Sitting and Home Alone", "url": "#"},{"label": "Pet Insurance", "url": "#"},{"label": "Pet Cremation", "url": "#"}]}';
    @api charityFooterLinksString = '{"headerLabel": "Our Charity", "headerUrl": "#", "links": [{"label": "About Us", "url": "#"},{"label": "RSPCA Locations", "url": "locations"},{"label": "Contact us", "url": "contact-us"},{"label": "Impact Reports", "url": "our-impact"},{"label": "Latest News", "url": "news"},{"label": "Careers", "url": "careers"}]}';
    @api partnersFooterLinksString = '{"headerLabel": "Our Partners", "headerUrl": "our-partners", "links": [{"label": "Black Cat Cafe", "url": "#"},{"label": "RSPCA World for Pets Store", "url": "#"},{"label": "RSPCA Op Shops", "url": "#"},{"label": "RSPCA Wildlife Hospital", "url": "#"},{"label": "RSPCA School for Pets", "url": "#"}]}';
    @api footerAcknowledgement = 'RSPCA respectfully acknowledges and recognises Aboriginal and Torres Strait Islander peoples as the Traditional Owners and Custodians of the lands, waters, animals and plants where we live, learn and work.';
    @api companyABN = '74 851 544 037';
    @api termsConditionsLink = 'terms-and-conditions';
    @api privacyLink = 'privacy-policy';
    @api cookieLink;
    @api isFacebook = false;
    @api facebookLink;
    @api mobileFacebookLink;
    @api isInstagram = false;
    @api instagramLink;
    @api isXTwitter = false;
    @api xtwitterLink;
    @api isLinkedin = false;
    @api linkedinLink;
    @api isYoutube = false;
    @api youtubeLink;
    @api isTiktok = false;
    @api tiktokLink;

    pageName;
    mobileSubscription;
    headerActionSubscription;
    mobileOpen= false;
    headerTopStyle = 'top: -44px;';

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    wiredCurrentPageReference(currentPageReference) {
        this.pageName = currentPageReference?.attributes?.name;
    }

    get mobileClass() {
        return this.mobileOpen ? 'mobile-open-fixed' : '';
    }

    get serviceClass() {
        return 'background-20' + (this.mobileOpen ? ' mobile-open-fixed' : '');
    }

    renderedCallback() {
        window.addEventListener('scroll', (event) => {this.handleScroll(event)});

        let notificationBarHeight = this.pageName && this.pageName == 'Home' ? 0 : this.template.querySelector('c-rspcaqld-header').notificationBarHeight;
        this.headerTopStyle = this.pageName && this.pageName == 'Home' ? 'top: 0px;' : 'top: -' + notificationBarHeight + 'px;';
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.mobileSubscription) {
            this.mobileSubscription = subscribe(
                this.messageContext,
                mobileMenu,
                (message) => this.handleMobileMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }

        if (!this.headerActionSubscription) {
            this.headerActionSubscription = subscribe(
                this.messageContext,
                headerAction,
                (message) => this.handleHeaderActionMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMobileMessage(message) {
        if (message) {
            this.mobileOpen = message.open;
            let header = this.template.querySelector('header');

            if (header) {
                if (this.mobileOpen) {
                    header.classList.add('header-fixed');
                } else {
                    header.classList.remove('header-fixed');
                    let section = this.template.querySelector('section');
                    if (section && section.classList.contains('sticky-section')) section.classList.remove('sticky-section');
                }
            }
        }
    }

    handleHeaderActionMessage(message) {
        this.querySelectorAll('*')[0].querySelector('.' + message.class).scrollIntoView({ block: 'start',  behavior: 'smooth' });
    }

    handleScroll(evt) {
        let header = this.template.querySelector('header');
        let section = this.template.querySelector('section');
        let notificationBarHeight = this.pageName && this.pageName == 'Home' ? 0 : this.template.querySelector('c-rspcaqld-header').notificationBarHeight;
        this.headerTopStyle = this.pageName && this.pageName == 'Home' ? 'top: 0px;' : 'top: -' + notificationBarHeight + 'px;';
        let scrollHeight = window.innerWidth <= 960 ? 60 : 110;

        if (header.getBoundingClientRect().top <= -(notificationBarHeight - 0.01)) {
            header.classList.add('header-fixed');
            section.classList.add('sticky-section');
        }
        if (header.classList.contains('header-fixed') && section.getBoundingClientRect().top >= scrollHeight) {
            header.classList.remove('header-fixed');
            section.classList.remove('sticky-section');
        }
    }

}