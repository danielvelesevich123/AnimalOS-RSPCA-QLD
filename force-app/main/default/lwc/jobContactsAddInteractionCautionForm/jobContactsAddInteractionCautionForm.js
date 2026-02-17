import {api, track, LightningElement} from 'lwc';
import {validate, execute, showToast} from 'c/verticUtils';

export default class JobContactsAddInteractionCautionForm extends LightningElement {
    @api jobContactId;
    @api isInspector = false;
    @api isContactCentreUser = false;
    @track selectOptions = {};
    @track interactionCaution = {};
    isBusy = false;

    connectedCallback() {
        if (this.isContactCentreUser === true) {
            this.interactionCaution.animalos__Caution_Source__c = 'Reported';
        }
        if (this.isInspector === true) {
            this.interactionCaution.animalos__Caution_Source__c = 'Observed';
        }
        this.interactionCaution.animalos__Caution_Date_Time__c = Date.now();
        this.refresh();
    }

    refresh() {
        this.isBusy = true;
        return execute('aos_JobContactsAddIntCautionMetaProc', {jobContactId: this.jobContactId})
            .then(response => {
                this.interactionCaution = response.dto.interactionCaution || {};
                this.selectOptions = response.selectOptions;
            })
            .catch(errors => {
                showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error');
            })
            .finally(() => {
                this.isBusy = false;
            });
    }


    handleSourceChange(event) {
        this.interactionCaution.animalos__Caution_Source__c = event.target.value;
    }

    handleTypeChange(event) {
        this.interactionCaution.animalos__Caution_Type__c = event.target.value;
    }

    handleDateTimeChange(event) {
        this.interactionCaution.animalos__Caution_Date_Time__c = event.target.value;
    }

    handleDetailsChange(event) {
        this.interactionCaution.animalos__Caution_Details__c = event.target.value;
    }

    handleSubmitClick() {
        debugger;
        let addInteractionCautionForm = this.refs.addInteractionCautionForm;

        if (validate(addInteractionCautionForm, {}).allValid !== true) {
            return;
        }

        this.dispatchEvent(new CustomEvent('submit', {
            bubbles: false,
            composed: false,
            detail: {
                interactionCaution: this.interactionCaution
            }
        }));
    }

    handleCancelClick() {
        this.dispatchEvent(new CustomEvent('cancel', {}));
    }
}