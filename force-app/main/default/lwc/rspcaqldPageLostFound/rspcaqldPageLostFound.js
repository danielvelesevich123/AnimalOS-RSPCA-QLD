import {LightningElement, wire} from 'lwc';
import {MessageContext, publish} from "lightning/messageService";
import breadcrumbs from '@salesforce/messageChannel/Breadcrumbs__c';
import * as constants from 'c/constants';

export default class RspcaqldPageLostFound extends LightningElement {
    @wire(MessageContext)
    messageContext;

    arrowRightWhite = constants.arrowRightWhite;

    connectedCallback() {
        // publish(this.messageContext, breadcrumbs,
        //     {parents: [{label: 'Services', url: 'service'}, {label: 'Lost & Found Pets', url: 'pet-service'}], current: 'Expression of interest', isBlack: true});
    }
}