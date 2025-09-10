import {api, LightningElement} from 'lwc';
import PORTAL_RESOURCE from '@salesforce/resourceUrl/PortalResource';

export default class RspcaqldHeaderSubNav extends LightningElement {
    @api header;
    @api description;
    @api linkLabel;
    @api linkUrl;
    @api articlesHeader;
    @api articles;

    handleDetailsLink(evt) {
        window.location.replace(this.linkUrl);
    }

    get isArticles() {
        return this.articles && this.articles.data ? true : false;
    }

    get uLinkUrl() {
        return this.linkUrl && this.linkUrl != '#' && !this.linkUrl.startsWith('/') ? '/' + this.linkUrl : this.linkUrl;
    }
}