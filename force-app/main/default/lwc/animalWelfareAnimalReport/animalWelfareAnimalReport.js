import {api, LightningElement } from 'lwc';

export default class AnimalWelfareAnimalReport extends LightningElement {
    @api animalReport;
    @api index;
    @api hideActions = false;

    connectedCallback() {
    }

    get showActions() {
        return this.hideActions !== true;
    }

    handleDeleteClick() {
        this.dispatchEvent(new CustomEvent('action', {
            detail: {
                action: 'delete',
                index: this.index
            },
            bubbles: false,
            composed: false
        }));
    }

    handleEditClick() {
        this.dispatchEvent(new CustomEvent('action', {
            detail: {
                action: 'edit',
                index: this.index
            },
            bubbles: false,
            composed: false
        }));
    }

}