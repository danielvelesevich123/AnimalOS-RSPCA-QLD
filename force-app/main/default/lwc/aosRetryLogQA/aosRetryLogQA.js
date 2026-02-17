import {LightningElement, api} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import {execute} from 'c/aosUtils';

export default class AosRetryLogQA extends LightningElement {
    @api recordId;
    isProcessing = false;

    async retry() {
        this.isProcessing = true;
        await execute('aos_RetryLogProc', {recordId : this.recordId});
        this.isProcessing = false;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async handleConfirm() {
        await this.retry();
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}