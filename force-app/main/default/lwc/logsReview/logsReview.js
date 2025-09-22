import {LightningElement, api} from 'lwc';
import {execute} from 'c/verticUtils';
import { RefreshEvent } from 'lightning/refresh';

export default class LogsReview extends LightningElement {
    @api group;
    @api recordId;
    logs = [];
    isBusy = false;
    isProcessing = false;
    errorMessage;
    columns = [
        {label: 'Name', fieldName: 'nameUrl', type: 'url', typeAttributes: {label: {fieldName: 'Name'}}},
        {label: 'Process', fieldName: 'animalos__Process__c'},
        {label: 'Type', fieldName: 'animalos__Type__c'},
        {label: 'Error Message', fieldName: 'errorMessage'},
        {type: 'action', typeAttributes: {rowActions: this.getRowActions}}
    ];

    async connectedCallback() {
        await this.refresh();
    }

    get refreshButtonDisabled() {
        return this.isBusy || this.isProcessing || !this.hasGroupAndRecordId;
    }

    async refresh() {
        if (this.hasGroupAndRecordId) {
            try {
                this.isBusy = true;
                this.errorMessage = null;
                let groupFilter = this.group.indexOf('{recordId}') === -1 ? this.group : this.group.replace('{recordId}', this.recordId);
                let response = await execute('vertic_SOQLProc', {
                    SOQL: 'SELECT Id, Name, animalos__Type__c, animalos__Process__c, animalos__Log_Details__c, animalos__Payload__c ' +
                        'FROM animalos__Log__c ' +
                        'WHERE animalos__Group__c = \'' + groupFilter + '\' ' +
                        'ORDER BY CreatedDate DESC ' +
                        'LIMIT 100'
                });
                this.logs = (response.dto.records || []).map(log => {
                    log.nameUrl = '/' + log.Id;
                    if (log.animalos__Log_Details__c) {
                        log.animalos__Log_Details__c = log.animalos__Log_Details__c.replaceAll('&quot;', '"');
                        let logDetails = JSON.parse(log.animalos__Log_Details__c);
                        log.errorMessage = logDetails['Error Message'];
                    }
                    return log;
                });
            } catch (ex) {
                this.errorMessage = Array.isArray(ex) ? ex[0].message : ex.message || ex.body.message;
            } finally {
                this.isBusy = false;
            }
        }
    }

    async getRowActions(row, doneCallback) {
        const actions = [{
            'label': 'View Details',
            'iconName': 'utility:preview',
            'name': 'viewDetails'
        }];
        if (row.animalos__Type__c === 'Error') {
            actions.push({
                'label': 'Retry',
                'iconName': 'utility:refresh',
                'name': 'retry'
            });
        }
        await Promise.resolve(); // Ensure the function is async
        doneCallback(actions);
    }

    async handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'retry':
                this.isProcessing = true;
                await execute('RetryLogProc', {recordId : row.Id});
                this.isProcessing = false;
                await this.refresh();
                this.dispatchEvent(new RefreshEvent());
                break;
            case 'viewDetails':
                window.open(row.nameUrl, '_blank');
                break;
        }
    }

    get hasGroupAndRecordId() {
        const hasGroup = this.group !== undefined && this.group !== null && this.group !== '';
        const hasRecordId = this.recordId !== undefined && this.recordId !== null && this.recordId !== '';
        return hasGroup && hasRecordId;
    }

    get hasErrorMessage() {
        return this.errorMessage !== undefined && this.errorMessage !== null && this.errorMessage !== '';
    }

    get hasLogs() {
        return this.logs !== undefined && this.logs !== null && this.logs.length > 0;
    }
}