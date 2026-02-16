import {api, LightningElement} from 'lwc';
import {showToast, execute} from "c/verticUtils";

export default class AnimalWelfareViolenceHistories extends LightningElement {
    @api jobContact = {};
    @api job = {};
    locationId;
    contactId;
    jobLocationId;
    isBusy = false;

    connectedCallback() {
        this.refresh();
    }

    @api
    refresh() {
        this.isBusy = true;
        this.contactId = this.jobContact?.animalos__Contact__r?.Id;
        return execute('aos_AnimalWelfareFindExistingRecords', {jobContact: this.jobContact, job: this.job})
            .then(response => {
                this.locationId = response.dto.locationId;
                this.jobLocationId = response.dto.jobLocationId;
                this.contactId = response.dto.contact?.Id || this.contactId;
                this.dispatchEvent(new CustomEvent('searchcompleted', {
                    detail: {
                        payload: response.dto,
                        index: this.index
                    },
                    bubbles: false,
                    composed: false
                }));
            })
            .catch(errors => {
                showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error')
            })
            .finally(() => {
                this.isBusy = false;
            })
    }

    handleManageSelected(event) {
        let selectedJobContacts = event.detail.selectedJobContacts || [];
        if (selectedJobContacts.length !== 0) {
            this.dispatchEvent(new CustomEvent('addjobcontacts', {
                bubbles: false,
                composed: false,
                detail: {
                    selectedJobContacts: selectedJobContacts
                }
            }));
        }
    }
}