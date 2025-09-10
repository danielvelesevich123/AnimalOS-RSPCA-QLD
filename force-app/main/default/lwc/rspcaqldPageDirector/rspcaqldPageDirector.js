import getPeople from '@salesforce/apex/ManagedContentService.getDirectorsByContentType';
import getDirector from '@salesforce/apex/ManagedContentService.getAuthorByContentKey';
import {LightningElement, wire, api} from 'lwc';
import {MessageContext, publish} from 'lightning/messageService';
import breadcrumbs from '@salesforce/messageChannel/Breadcrumbs__c';
import {CurrentPageReference} from "lightning/navigation";

export default class RspcaqldPageOurPartners extends LightningElement {
    @api parentsString;
    @api otherHeader = 'Meet the rest of the board';
    @api headerSize;
    @api headerMobileSize;
    @api viewLinkLabel = 'View all';
    @api viewLinkUrl = 'our-board';
    @api contentLink = 'director';
    contentKey = null;
    director = {};
    otherDirectorsString = '';

    @wire(CurrentPageReference)
    getContentType(currentPageReference) {
        if (currentPageReference) {
            this.contentKey = currentPageReference.attributes?.contentKey;
        }
    }

    @wire(getDirector, {contentKey: '$contentKey'})
    director({ error, data }) {
        if (data) {
            this.director = data;
            publish(this.messageContext, breadcrumbs,
                {parents: this.parents, current: this.director.name});

            getPeople({ contentType: this.director.type})
                .then(result => {
                    let allDirectors = result;


                    if (allDirectors.length > 1) {
                        let otherDirectors = [];

                        if (allDirectors.length > 4) {
                            do {
                                let randomElement = allDirectors[Math.floor(Math.random() * allDirectors.length)];

                                if (randomElement.key !== this.director.key) {
                                    if (! otherDirectors.includes(randomElement.key)) {
                                        otherDirectors.push(randomElement.key);
                                    }
                                }
                            } while (otherDirectors.length < 3);
                        } else {
                            for (let i = 0; i < allDirectors.length; i++) {
                                if (allDirectors[i].key !== this.director.key) {
                                    otherDirectors.push(allDirectors[i].key);
                                }
                            }
                        }

                        if (otherDirectors) this.otherDirectorsString = otherDirectors.join(',');
                    }
                })
                .catch(error => {
                    console.log(error);
                })
        }
    };

    get isOtherDirectors() {
        return this.otherDirectorsString ? true : false;
    }

    get parents() {
        let _parents = []
        if (this.parentsString) _parents = JSON.parse(this.parentsString);
        return _parents;
    }

    @wire(MessageContext)
    messageContext;
}