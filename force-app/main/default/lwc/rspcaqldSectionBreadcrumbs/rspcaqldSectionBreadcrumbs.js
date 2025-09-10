import {LightningElement, wire, api} from 'lwc';
import {MessageContext, publish} from 'lightning/messageService';
import breadcrumbs from '@salesforce/messageChannel/Breadcrumbs__c';

export default class RspcaqldSectionBreadcrumbs extends LightningElement {
    @api currentPage;
    @api parentsString;
    @api isBlack = false;

    @wire(MessageContext)
    messageContext;

    get parents() {
        let _parents = []
        if (this.parentsString) _parents = JSON.parse(this.parentsString);
        return _parents;
    }

    connectedCallback() {
        publish(this.messageContext, breadcrumbs,
            {parents: this.parents, current: this.currentPage, isBlack: this.isBlack});
    }
}