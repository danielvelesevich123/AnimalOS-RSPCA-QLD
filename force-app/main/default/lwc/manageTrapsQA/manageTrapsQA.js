import {api, LightningElement} from 'lwc';
import ManageTrapsQAModal from 'c/manageTrapsQAModal';
import {CloseActionScreenEvent} from "lightning/actions";


export default class ManageTrapsQA extends LightningElement {

    @api recordId;

    async connectedCallback() {
        this.recordId = this.recordId || new URLSearchParams(window.location.search).get('recordId');
        await ManageTrapsQAModal.open({
            size: 'medium',
            payload: {
                parentCmp: this
            },
            recordId: this.recordId
        });
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}