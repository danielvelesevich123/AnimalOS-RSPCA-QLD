import {LightningElement, api} from 'lwc';
import {execute} from 'c/aosUtils';
import {RefreshEvent} from 'lightning/refresh';

export default class AosLogsReview extends LightningElement {
    @api group;
    @api recordId;
    @api objectApiName;
    @api condition;
    logs = [];
    isBusy = false;
    isProcessing = false;
    errorMessage;
    columns = [
        {label: 'Name', fieldName: 'nameUrl', type: 'url', typeAttributes: {label: {fieldName: 'Name'}}},
        {label: 'Process', fieldName: 'animalos__Process__c'},
        {label: 'Type', fieldName: 'animalos__Type__c'},
        {label: 'Created Date', fieldName: 'CreatedDate'},
        {label: 'Error Message', fieldName: 'animalos__Message_Body__c'},
        {type: 'action', typeAttributes: {rowActions: this.getRowActions}}
    ];

    async connectedCallback() {
        await this.refresh();
    }

    get refreshButtonDisabled() {
        return this.isBusy || this.isProcessing || !this.hasCondition;
    }

    @api
    async refresh() {
        if (this.hasCondition) {
            try {
                this.isBusy = true;
                this.errorMessage = null;

                let whereCondition = '';

                // If condition is not provided but hasGroupAndRecordId is true, build condition
                if (!this.condition || this.condition.trim() === '') {
                    if (this.hasGroupAndRecordId) {
                        let fieldsToSOQL = this.group.match(/\{([^}]+)}/g).map(field => field.replace('{', '').replace('}', ''));
                        let responseRecord = await execute('aos_SOQLProc', {
                            recordId: this.recordId,
                            SOQL: 'SELECT ' + (fieldsToSOQL.length > 0 ? fieldsToSOQL.join(', ') : 'Id') + ' FROM ' + this.objectApiName + ' WHERE Id = \'' + this.recordId + '\''
                        });

                        let record = responseRecord.dto.records[0];

                        //groupFilter should be comma separated values in quotes like 'value1', 'value2', 'value3'
                        let groupFilter = '(' + this.group.split(';').map(groupValue => {
                            fieldsToSOQL.forEach(field => {
                                groupValue = groupValue.replaceAll('{' + field + '}', record[field]);
                            });
                            return '\'' + groupValue + '\'';
                        }).join(',') + ')';

                        whereCondition = 'animalos__Group__c IN ' + groupFilter;
                        this.condition = whereCondition;
                    }
                } else {
                    whereCondition = this.condition;
                }

                // Run SOQL query with the condition
                let response = await execute('aos_SOQLProc', {
                    SOQL: 'SELECT Id, Name, animalos__Type__c, animalos__Process__c, animalos__Log_Details__c, animalos__Payload__c,animalos__Message_Body__c, CreatedDate ' +
                        'FROM animalos__Log__c ' +
                        'WHERE ' + whereCondition +
                        ' ORDER BY CreatedDate DESC ' +
                        'LIMIT 100'
                });
                this.logs = (response.dto.records || []).map(log => {
                    log.nameUrl = '/' + log.Id;
                    log.CreatedDate = new Date(log.CreatedDate).toLocaleString();
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
                await execute('aos_RetryLogProc', {recordId: row.Id});
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

    get hasCondition() {
        const hasConditionValue = this.condition !== undefined && this.condition !== null && this.condition.trim() !== '';
        return hasConditionValue || this.hasGroupAndRecordId;
    }

    get hasErrorMessage() {
        return this.errorMessage !== undefined && this.errorMessage !== null && this.errorMessage !== '';
    }

    get hasLogs() {
        return this.logs !== undefined && this.logs !== null && this.logs.length > 0;
    }
}