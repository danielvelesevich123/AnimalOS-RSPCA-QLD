import {api, track} from 'lwc';
import LightningModal from 'lightning/modal';
import {showToast, execute, handleFieldChange, validate} from "c/verticUtils";

export default class ManageTrapsQAModal extends LightningModal {
    @api
    recordId;
    @api payload = {};
    isBusy = false;
    selectOptions = {};

    locationOfInterestId;
    locationOfInterest = {};
    @track
    resources;

    async connectedCallback() {
        this.isBusy = true;

        try {
            const response = await execute(
                'aos_ManageTrapsQAMetaProc',
                {
                    recordId: this.recordId
                }
            );

            this.locationOfInterestId = response.dto.locationOfInterestId;
            this.resources = response.dto.resources;
            this.selectOptions = response.selectOptions;
        } catch (errors) {
            this.isBusy = false;
            showToast(this.payload.parentCmp, 'Error', errors[0].message, 'error');
        }

        this.isBusy = false;
    }


    async handleRightButtonClick() {

        switch (this.currentStep) {
            case 'locationOfInterest':
                let street = this.refs.locationOfInterestCmp.locationOfInterest.animalos__Address__Street__s;

                if (!street) {
                    showToast(this.payload.parentCmp, 'Error', 'Select location of interest', 'error');
                    return;
                }

                this.locationOfInterest = this.refs.locationOfInterestCmp.locationOfInterest;
                break;
            case 'traps':
                const selectedResources = this.resources.filter(resource => resource.isSelected);

                if (selectedResources.length === 0) {
                    showToast(this.payload.parentCmp, 'Error', 'Select at least one resource', 'error');
                    return;
                }

                if (validate(this.refs.trapsTable, {}).allValid !== true) {
                    return;
                }
                this.isBusy = true;

                try {
                    const response = await execute(
                        'aos_ManageTrapsQASubmitProc',
                        {
                            recordId: this.recordId,
                            locationOfInterest: this.locationOfInterest,
                            resources: selectedResources
                        }
                    );

                    showToast(this.payload.parentCmp, 'Success', 'Job Activity successfully created', 'success');
                    window.open('/' + response.dto.jobActivityId, '_blank');

                } catch (errors) {
                    this.isBusy = false;
                    if (Array.isArray(errors)) {
                        showToast(this.payload.parentCmp, 'Error', errors[0].message, 'error');
                    } else {
                        showToast(this.payload.parentCmp, 'Error', errors.message, 'error');
                    }
                    return;
                }
                this.isBusy = false;
                break;
        }

        if (this.isLastStep) {
            this.close();
        } else {
            let currentStepIndex = this.steps.findIndex(step => step.name === this.currentStep);
            this.currentStep = this.steps[currentStepIndex + 1].name;
        }

    }


    handleLeftButtonClick() {
        if (this.isFirstStep) {
            this.close();
        } else {
            let currentStepIndex = this.steps.findIndex(step => step.name === this.currentStep);
            this.currentStep = this.steps[currentStepIndex - 1].name;
        }
    }

    handleResourceFieldChange(event) {
        let index = event.target.dataset.index,
            resource = this.resources[index];

        handleFieldChange(resource, event);

        this.resources[index] = resource;
    }

    get showLocationOfInterest() {
        return this.isBusy === false;
    }

    get noResources() {
        return !this.resources || this.resources.length === 0;
    }

    get statusOptions() {
        return this.selectOptions.statusOptions.filter(option => option.value !== 'Available');
    }

    //STEPPER
    @track currentStep = 'locationOfInterest';

    @track steps = [
        {name: 'locationOfInterest', label: 'Location of Interest'},
        {name: 'traps', label: 'Traps'}
    ];


    get leftButtonLabel() {
        return this.isFirstStep ? 'Cancel' : 'Back';
    }

    get rightButtonLabel() {
        return this.isLastStep ? 'Submit' : 'Next';
    }

    get isFirstStep() {
        return this.currentStep === this.steps[0].name;
    }

    get isLastStep() {
        return this.currentStep === this.steps[this.steps.length - 1].name;
    }

    get isLocationOfInterestStep() {
        return this.currentStep === 'locationOfInterest';
    }

    get isTrapsStep() {
        return this.currentStep === 'traps';
    }
}