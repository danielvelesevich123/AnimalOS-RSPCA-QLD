import {LightningElement, api} from 'lwc';
import {execute, showToast, validate} from 'c/verticUtils';

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
        fieldName: 'matchedBlock',
        type: 'text',
        sortable: true,
        cellAttributes: {
            alignment: 'left'
        }
    },
    {
        label: 'Unit Vicinity',
        fieldName: 'unitReference',
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

    isLoading = false;
    error;
    animalRecord;
    startDate;
    endDate;
    movementData = [];
    hasResults = false;

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
            this.error = undefined;
        } catch (ex) {
            this.error = Array.isArray(ex) ? ex[0].message : ex.message || ex.body?.message;
            showToast(this, 'Error', 'Error loading animal record: ' + this.error, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }

    async handleSearch() {
        // Validate inputs using verticUtils
        const validationResult = validate(this.template);
        if (!validationResult.allValid) {
            showToast(this, 'Validation Error', validationResult.getErrorMessages().join(', '), 'error');
            return;
        }

        // Additional date range validation
        if (new Date(this.startDate) > new Date(this.endDate)) {
            showToast(this, 'Validation Error', 'Start date must be before or equal to end date.', 'error');
            return;
        }

        this.isLoading = true;
        this.error = undefined;

        try {
            let response = await execute('MovementTrackerSearchProc', {
                animalId: this.recordId,
                startDate: this.startDate,
                endDate: this.endDate
            });

            this.movementData = AnimalMovementTracker.processMovementData(response.dto.results || []);
            this.hasResults = this.movementData.length > 0;

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
                matchedMovementUrl: location.hostname + '/' + record.matchedMovementId
            };
        });
    }

    handleClear() {
        this.startDate = '';
        this.endDate = '';
        this.movementData = [];
        this.hasResults = false;
        this.error = undefined;
    }

    get isSearchDisabled() {
        return this.isLoading || !this.recordId;
    }

    get currentAnimalName() {
        return this.animalRecord?.Name || 'Unknown Animal';
    }
}