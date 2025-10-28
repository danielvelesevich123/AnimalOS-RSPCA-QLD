import {LightningElement, api, track} from 'lwc';
import {execute, showToast, validate, exportCSVFile, sortByField, handleFieldChange} from 'c/verticUtils';

const COLUMNS = [
    {
        label: 'Matched Animal',
        fieldName: 'matchedAnimalUrl',
        type: 'url',
        typeAttributes: {
            label: {fieldName: 'matchedAnimalName'},
            target: '_blank'
        },
        sortable: true,
        cellAttributes: {
            alignment: 'left'
        }
    },
    {
        label: 'Matched Block',
        fieldName: 'matchedBlockUrl',
        type: 'url',
        typeAttributes: {
            label: {fieldName: 'matchedBlockName'},
            target: '_blank'
        },
        sortable: true,
        cellAttributes: {
            alignment: 'left'
        }
    },
    {
        label: 'Unit Vicinity',
        fieldName: 'unitReference',
        initialWidth: 300,
        type: 'text',
        sortable: true,
        cellAttributes: {
            alignment: 'left',
            class: 'unit-reference-cell'
        }
    },
    {
        label: 'Days Exposed',
        fieldName: 'daysExposed',
        initialWidth: 80,
        type: 'number',
        sortable: true,
        cellAttributes: {
            alignment: 'left'
        }
    },
    {
        label: 'Movement',
        fieldName: 'currentMovementUrl',
        type: 'url',
        typeAttributes: {
            label: {fieldName: 'currentMovementName'},
            target: '_blank'
        },
        sortable: true,
        cellAttributes: {
            alignment: 'left'
        }
    },
    {
        label: 'Matched Movement',
        fieldName: 'matchedMovementUrl',
        type: 'url',
        typeAttributes: {
            label: {fieldName: 'matchedMovementName'},
            target: '_blank'
        },
        sortable: true,
        cellAttributes: {
            alignment: 'left'
        }
    }
];

export default class AnimalMovementTracker extends LightningElement {
    @api recordId;
    @track filter = {};

    isLoading = false;
    error;
    animalRecord;
    selectOptions = {};
    dependentOptions = {};
    animalStatusOptions = [];
    movementData = [];
    sortedBy = 'matchedAnimalName';
    sortedDirection = 'asc';
    columns = COLUMNS;

    connectedCallback() {
        if (this.recordId) {
            this.loadAnimalData();
        }
    }

    async loadAnimalData() {
        this.isLoading = true;
        try {
            let response = await execute('MovementTrackerMetaProc', {
                recordId: this.recordId
            });
            this.animalRecord = response.dto.animal;
            this.selectOptions = response.selectOptions;
            this.dependentOptions = response.dependentOptions;
            this.error = undefined;
        } catch (ex) {
            this.error = Array.isArray(ex) ? ex[0].message : ex.message || ex.body?.message;
            showToast(this, 'Error', 'Error loading animal record: ' + this.error, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleFieldChange(event) {
        let map = event.target.dataset.map,
            path = event.target.dataset.path,
            index = event.target.dataset.index;
        handleFieldChange(this[map], event);
    }

    handleAnimalStageChange(event) {
        this.filter.animalStatus = '';
        const selectedStage = event.target.value;
        this.animalStatusOptions = this.dependentOptions.animalosStatusOptions[selectedStage];
        handleFieldChange(this.filter, event);
    }

    async handleSearch() {
        // Validate inputs using verticUtils
        const validationResult = validate(this.template);
        if (!validationResult.allValid) {
            showToast(this, 'Validation Error', validationResult.getErrorMessages().join(', '), 'error');
            return;
        }

        // Additional date range validation
        if (new Date(this.filter.startDate) > new Date(this.filter.endDate)) {
            showToast(this, 'Validation Error', 'Start date must be before or equal to end date.', 'error');
            return;
        }

        this.isLoading = true;
        this.error = undefined;

        try {
            let response = await execute('MovementTrackerSearchProc', {
                animalId: this.recordId,
                startDate: this.filter.startDate,
                endDate: this.filter.endDate,
                animalStatus: this.filter.animalStatus,
                animalStage: this.filter.animalStage
            });

            this.movementData = AnimalMovementTracker.processMovementData(response.dto.results || []);

            // Apply current sort after loading new data
            if (this.hasResults) {
                this.sortData();
            }

            if (this.hasResults) {
                showToast(this, 'Analysis Complete', `Found ${this.movementData.length} movement overlap(s) where animals shared blocks during the specified period.`, 'success');
            } else {
                showToast(this, 'No Results', 'No movement overlaps found for the specified date range.', 'info');
            }
        } catch (ex) {
            this.error = Array.isArray(ex) ? ex[0].message : ex.message || ex.body?.message;
            showToast(this, 'Error', 'Error performing analysis: ' + this.error, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    static processMovementData(data) {
        return data.map(record => {
            return {
                ...record,
                // URLs for clickable links
                matchedAnimalUrl: location.hostname + '/' + record.matchedAnimalId,
                currentMovementUrl: location.hostname + '/' + record.currentMovementId,
                matchedMovementUrl: location.hostname + '/' + record.matchedMovementId,
                matchedBlockUrl: location.hostname + '/' + record.matchedBlockId
            };
        });
    }

    handleClear() {
        this.filter.startDate = {};
        this.movementData = [];
        this.error = undefined;
        this.sortedBy = 'matchedAnimalName';
        this.sortedDirection = 'asc';
    }

    handleSort(event) {
        const {fieldName, sortDirection} = event.detail;
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        this.sortData();
    }

    sortData() {
        this.movementData = sortByField(this.movementData, this.sortedBy, this.sortedDirection);
    }

    handleDownloadCSVClick(){
        exportCSVFile({
            matchedAnimalName: 'Matched Animal',
            matchedAnimalCurrentSiteName: 'Matched Animal Current Site',
            matchedAnimalCurrentBlockName: 'Matched Animal Current Block',
            matchedAnimalCurrentUnitName: 'Matched Animal Current Unit',
            matchedAnimalStage: 'Matched Animal Stage',
            matchedAnimalStatus: 'Matched Animal Status',
            matchedBlock: 'Matched Block',
            unitReference: 'Unit Vicinity',
            daysExposed: 'Days Exposed',
            currentMovementName: 'Movement',
            matchedMovementName: 'Matched Movement'
        }, this.movementData, this.animalRecord.Name + '_Movement_Overlap_Report' + (this.filter.startDate ? '_From_' + this.filter.startDate : '') + (this.filter.endDate ? '_To_' + this.filter.endDate : ''));
    }

    get isSearchDisabled() {
        return this.isLoading || !this.recordId;
    }

    get currentAnimalName() {
        return this.animalRecord?.Name || 'Unknown Animal';
    }

    get hasResults() {
        return this.movementData.length > 0;
    }

    get isAnimalStatusDisabled() {
        return this.isLoading === true || !this.filter.animalStage || this.filter.animalStage === '';
    }
}