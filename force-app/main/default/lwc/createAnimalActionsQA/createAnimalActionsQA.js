import {api, LightningElement} from 'lwc';
import CreateAnimalActionsQAModal from 'c/createAnimalActionsQAModal';
import {CloseActionScreenEvent} from "lightning/actions";

export default class CreateAnimalActionsQA extends LightningElement {
    @api recordId;

    @api async invoke() {
        this.recordId = this.recordId || new URLSearchParams(window.location.search).get('recordId');
        await CreateAnimalActionsQAModal.open({
            size: 'medium',
            payload: {
                parentCmp: this
            },
            recordId: this.recordId
        });
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}