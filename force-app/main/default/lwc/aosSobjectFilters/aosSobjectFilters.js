import {api, track, LightningElement} from 'lwc';
import {execute, showToast,handleFieldChange} from 'c/aosUtils';

export default class AosSobjectFilters extends LightningElement {
    @api sobjectApiName;
    @api title = 'Filters';
    isBusy = false;
    @track searchFields = [{guid: new Date().getTime()}];
    fieldsInfoMap = {};
    selectOptions = {};

    async connectedCallback() {
        this.isBusy = true;
        try {
            let response = await execute('aos_SobjectFilterMetaProc', {
                sobjectApiName: this.sobjectApiName
            });
            this.selectOptions = response.selectOptions;
            //sort fieldOptions alphabetically
            this.selectOptions.fieldOptions.sort((a, b) => a.label.localeCompare(b.label));
            this.fieldsInfoMap = response.dto.fieldsInfoMap;
        } catch (ex) {
            showToast(this, 'Error', Array.isArray(ex) ? ex[0].message : ex.message || ex.body.message, 'error');
        } finally {
            this.isBusy = false;
        }
    }

    handleFieldChange(event) {
        let map = event.target.dataset.map,
            path = event.target.dataset.path,
            index = event.target.dataset.index;
        handleFieldChange(this[map], event);

        switch (map) {
            case 'searchFields':
                switch (path) {
                    case '[data-index].fieldName':
                        let field = this.searchFields[index];
                        field.value = null;
                        field.operator = null;
                        field.fieldInfo = this.fieldsInfoMap[field.fieldName];
                        field.operatorOptions = this.operatorOptions(field.fieldInfo.type);
                        break;
                }
                break;
        }
    }

    handleRemoveSearchFieldClick(event) {
        let index = event.target.dataset.index;
        this.searchFields.splice(index, 1);
    }

    handleAddSearchFieldClick() {
        this.searchFields = [...this.searchFields, {guid: new Date().getTime()}];
    }

    operatorOptions(type) {
        switch (type) {
            case 'BOOLEAN':
            case 'ID':
            case 'REFERENCE':
            case 'PICKLIST':
            case 'MULTIPICKLIST':
                return this.selectOptions.operatorLimitedOptions;
            case 'DATE':
            case 'DATETIME':
            case 'DOUBLE':
            case 'PERCENT':
            case 'INTEGER':
            case 'CURRENCY':
                return this.selectOptions.operatorExtendedOptions;
        }
        return this.selectOptions.operatorAllOptions;
    }

    @api
    get filters() {
        return JSON.parse(JSON.stringify(this.searchFields));
    }
}