import getManagedContent from '@salesforce/apex/ManagedContentService.getManagedContentByContentKey';
import getLastKeys from '@salesforce/apex/ManagedContentService.getLastKeysByType';
import {LightningElement, wire, api} from 'lwc';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import PAGE_FILES from "@salesforce/contentAssetUrl/PortalImageszip";
import {MessageContext, publish} from "lightning/messageService";
import breadcrumbs from '@salesforce/messageChannel/Breadcrumbs__c';
import * as constants from 'c/constants';

export default class RspcaqldPageArticle extends NavigationMixin(LightningElement) {
    @api customMetadata = 'Main';
    @api hotspotSubscribeHeader;
    @api hotspotSubscribeTCAndPP;
    @api hotspotSubscribeButtonHeader;
    @api hotspotSubscribeThankYouMessage;
    @api subscribeHeader;
    @api subscribeTCAndPP;
    @api subscribeButtonHeader;
    @api relatedArticlesHeader = 'Related Articles';
    @api relatedArticlesDescription = 'Caring for your pet - get tips and advice about being a responsible pet owner.';
    @api relatedArticlesLinkLabel = 'Pet care & advice';
    @api relatedArticlesLinkURL;
    contentKey;
    article = {};
    relatedArticles = '';
    author = {};
    officialRSPCAPaw = constants.officialRSPCAPaw;
    arrowLeftDark = constants.arrowLeftDark;
    isActive = false;

    cta = {
        image: PAGE_FILES + "?pathinarchive=cta.jpeg",
        header: 'Have you thought of adopting an animal?',
        linkLabel: 'Learn about adoption',
        linkUrl: '#'
    };

    get backLink() {
        if (this.article && this.article.type) return '/' + (this.article.type == 'portal_news' ? 'news' : this.article.type.replaceAll('_', '-'));
        return null;
    }

    get facebookShareLink() {
        return 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href;
    }

    get twitterShareLink() {
        return this.article && this.article.title ? 'http://www.twitter.com/intent/tweet?url=' + window.location.href + '&text=' + this.article.title : '';
    }

    get linkedinShareLink() {
        return 'https://www.linkedin.com/shareArticle?mini=true&url=' + window.location.href;
    }

    @wire(CurrentPageReference)
    getContentType(currentPageReference) {
        if (currentPageReference) {
            if (currentPageReference.attributes?.contentKey) {
                this.contentKey = currentPageReference.attributes?.contentKey;
            } else {
                let urlAlias = currentPageReference?.attributes.urlAlias;
                if (urlAlias && urlAlias != ':urlAlias') {
                    window.location.reload();
                }
            }
        }
    }

    @wire(getManagedContent, {contentKey: '$contentKey'})
    wiredArticle({ error, data }) {
        if (data) {
            this.article = data.content;
            this.author = data.author;

            if (!this.article || !this.article.title) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/error'
                    },
                });
            } else {
                this.isActive = true;
            }

            publish(this.messageContext, breadcrumbs,
                {parents: [{label: this.article.typeLabel == 'News' ? 'About Us' : 'Resources', url: this.article.typeLabel == 'News' ? 'about-us' : '/resources'}, {label: (this.article.typeLabel + (this.article.typeLabel == 'News' ? '' : ' Blog')), url: ('/' + (this.article.type == 'portal_news' ? 'about-us/news' : 'resources/' + this.article.type.replaceAll('_', '-')))}], current: this.article.title});

            getLastKeys({contentType: this.article.type, contentKey: this.article.key})
                .then(result => {
                    this.relatedArticles = result;
                })
                .catch(error => {
                    console.log(error);
                })
        }
        if (error) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/error'
                },
            });
        }
    };

    @wire(MessageContext)
    messageContext;

    connectedCallback() {}
}