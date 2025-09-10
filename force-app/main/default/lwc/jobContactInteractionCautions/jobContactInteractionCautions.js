import {LightningElement, api, track} from 'lwc';
import {execute, showToast} from 'c/verticUtils';

export default class JobContactInteractionCautions extends LightningElement {
    @api contactId;
    @api jobId;
    @api jobContactId;
    @api view;
    @track interactionCautions = [];
    isBusy = false;

    connectedCallback() {
        this.isBusy = true;
        this.refresh()
            .catch(ex => {
                showToast(this, 'Error', Array.isArray(ex) ? ex[0].message : ex.message || ex.body?.message, 'error');
            })
            .finally(() => {
                this.isBusy = false;
            })
    }

    refresh() {
        return execute('JobContactInteractionCautionsMetaProc', {
            contactId: this.contactId,
            jobId: this.jobId,
            jobContactId: this.jobContactId
        })
            .then(response => {
                this.interactionCautions = response.dto.interactionCautions || [];
            });
    }

    get hasInteractionCautions() {
        return this.interactionCautions.length > 0;
    }

    get noRecordsMessage() {
        return 'Contact has no related Interaction Cautions' + (this.jobContactId ? ' within the current Job.' : '.');
    }
}