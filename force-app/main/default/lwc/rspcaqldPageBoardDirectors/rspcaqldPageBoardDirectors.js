import {api, LightningElement, wire} from 'lwc';
import {MessageContext} from 'lightning/messageService';

export default class RspcaqldPageOurPartners extends LightningElement {
    @api contentType;
    @api contentLink;
    directors = [];

    @wire(MessageContext)
    messageContext;

    connectedCallback() {}
}