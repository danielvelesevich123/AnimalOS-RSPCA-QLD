import getDirectors from '@salesforce/apex/ManagedContentService.getDirectorsByContentType';
import {api, LightningElement, wire} from 'lwc';
import {MessageContext, publish} from 'lightning/messageService';

export default class RspcaqldPageOurPartners extends LightningElement {
    @api contentType;
    @api contentLink;
    directors;

    @wire(getDirectors, {contentType: '$contentType'}) wiredArticles({ error, data }) {
        if (data) {
            let uwd = JSON.parse(JSON.stringify(data));
            uwd.map(item => {
                item.link = '../../' + this.contentLink + '/' + item.key;
            });
            this.directors = uwd;
        }
    };

    @wire(MessageContext)
    messageContext;

    connectedCallback() {}
}