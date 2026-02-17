import {api, track} from 'lwc';
import LightningModal from "lightning/modal";
import {execute, showToast, handleFieldChange} from "c/aosUtils";

export default class CreateAnimalActionsQAModal extends LightningModal {
    @api
    recordId;
    animalId;
    @api payload = {};
    isBusy = false;
    selectOptions = {};

    @track
    animalActions = [];

    async connectedCallback() {
        this.isBusy = true;

        try {
            const response = await execute(
                'aos_CreateAnimalActionsQAMetaProc',
                {
                    recordId: this.recordId
                }
            );

            this.animalId = response.dto.animalId;
            this.animalActions = response.dto.animalActions || [];
            this.selectOptions = response.selectOptions;

            this.animalActions.forEach(action => {
                action.guid = crypto.randomUUID();
                action.RecordTypeId = this.treatmentRecordTypeId;
            });
        } catch (errors) {
            this.isBusy = false;
            showToast(this.payload.parentCmp, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error');
        }
        this.isBusy = false;
    }

    handleAddActionClick() {
        this.animalActions.push({
            guid: crypto.randomUUID(),
            animalos__Animal__c: this.animalId,
            animalos__Vet_Consult__c: this.recordId,
            animalos__Action_Status__c: 'Scheduled',
            animalos__Date_Time_of_Action__c: new Date().toISOString(),
            RecordTypeId: this.treatmentRecordTypeId
        });
    }

    handleFieldChange(event) {
        let dataMap = event.target.dataset.map;
        handleFieldChange(this[dataMap], event);
    }

    async handleSaveClick() {
        this.isBusy = true;

        try {
            await execute(
                'aos_CreateAnimalActionsQASubmitProc',
                {
                    animalActions: this.animalActions
                }
            );

            showToast(this.payload.parentCmp, 'Success', 'Animal Actions created successfully', 'success');
            this.close();
        } catch (errors) {
            this.isBusy = false;
            showToast(this.payload.parentCmp, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error');
        }
        this.isBusy = false;
    }

    handleCancelClick() {
        this.close();
    }

    get treatmentRecordTypeId() {
        return this.selectOptions.recordTypeOptions.find(option => option.label === 'Treatment').value;
    }
}