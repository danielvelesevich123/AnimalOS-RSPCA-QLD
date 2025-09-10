import {LightningElement, wire} from 'lwc';
import {MessageContext, publish} from "lightning/messageService";
import breadcrumbs from '@salesforce/messageChannel/Breadcrumbs__c';
import * as constants from 'c/constants';

export default class RspcaqldPageSearchFoundPets extends LightningElement {
    arrowRightWhite = constants.arrowRightWhite;

    options = [
        { label: 'Option A', value: 'Option A' },
        { label: 'Option B', value: 'Option B' },
        { label: 'Option C', value: 'Option C' },
        { label: 'Option D', value: 'Option D' },
        { label: 'Option E', value: 'Option E' }
    ];

    radioOptions = [
        { label: 'Shelter', value: 'Shelter' },
        { label: 'All found pets', value: 'All found pets' },
        { label: 'All pets found within a postcode', value: 'All pets found within a postcode' }
    ];

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        // publish(this.messageContext, breadcrumbs,
        //     {parents: [{label: 'Services', url: 'service'}, {label: 'Lost & Found Pets', url: 'pet-service'}], current: 'Search Found Pets', isBlack: true});
    }
}