import BaseElement from "c/verticBase";
import {api} from "lwc";

export default class VerticStepper extends BaseElement {

    @api stepsList = [];
    @api progressPosition = 'footer'; // footer, header, subtitle
    @api progressIndicatorType = 'base'; // base, path, vertical
    @api hideProgressIndicator = false;
    @api hideStepLabel = false;
    @api currentStep;
    @api previousButtonLabel = 'Previous';
    @api previousButtonVariant = 'neutral';
    @api previousButtonDisabled = false;
    @api previousButtonHidden = false;
    @api nextButtonLabel = 'Next';
    @api nextButtonVariant = 'brand';
    @api nextButtonDisabled = false;
    @api nextButtonHidden = false;
    @api buttonsStickedTogether = false;
    @api selectAnyStep = false;
    stepsList_private = [];

    connectedCallback() {
        super.connectedCallback();
        this.stepsList = this.stepsList || [];
        if (this.stepsList.length > 0 && !this.currentStep) {
            this.currentStep = this.stepsList[0].name;
        }
        setTimeout(() => {
            this.stepChange(true);
        });
    }

    @api
    open() {
        this.currentStep = undefined;
        if (this.baseCmp) {
            this.baseCmp.open();
        } else {
            super.open();
        }
    }

    handleOpen(event) {
        this.connectedCallback();
        super.open(event);
    }

    @api
    close() {
        this.baseCmp.close();
    }

    handleClose(event) {
        super.close(event);
    }

    @api
    get isFirstStep() {
        return this.stepsList[0].name === this.currentStep || this.currentStep === undefined;
    }

    @api
    get isLastStep() {
        return this.stepsList[this.stepsList.length - 1].name === this.currentStep;
    }

    get leftButtonLabel() {
        return this.isFirstStep ? this.cancelButtonLabel : this.previousButtonLabel;
    }

    get leftButtonClass() {
        return 'slds-button slds-button_' + this.previousButtonVariant;
    }

    get leftButtonHidden() {
        return (this.isFirstStep && this.cancelButtonHidden) || this.previousButtonHidden;
    }

    get leftButtonDisabled() {
        return (this.isFirstStep && this.cancelButtonDisabled) || (!this.isFirstStep && this.previousButtonDisabled);
    }

    get rightButtonLabel() {
        return this.isLastStep ? this.saveButtonLabel : this.nextButtonLabel;
    }

    get rightButtonClass() {
        return 'slds-button slds-button_' + this.nextButtonVariant;
    }

    get rightButtonHidden() {
        return (this.isLastStep && this.saveButtonHidden) || this.nextButtonHidden;
    }

    get rightButtonDisabled() {
        return (this.isLastStep && this.saveButtonDisabled) || (!this.isLastStep && this.nextButtonDisabled);
    }

    get progressInHeader() {
        return this.progressPosition === 'header';
    }

    get progressAsSubtitle() {
        return this.progressPosition === 'subtitle';
    }

    @api
    get isProgressIndicatorVertical() {
        return this.progressIndicatorType === 'vertical';
    }

    @api
    get previousStep() {
        return this.previousStepDetail.name;
    }

    @api
    get nextStep() {
        return this.nextStepDetail.name;
    }

    @api
    get previousStepDetail() {
        let newStepIndex = this.stepsList.findIndex(step => this.currentStep === step.name) - 1;
        return this.isFirstStep ? this.currentStepDetail : this.stepsList[newStepIndex];
    }

    @api
    get currentStepIndex() {
        return this.stepsList.findIndex(step => this.currentStep === step.name);
    }

    @api
    get currentStepDetail() {
        let stepIndex = this.stepsList.findIndex(step => this.currentStep === step.name);
        return this.stepsList[stepIndex];
    }

    @api
    get nextStepDetail() {
        let newStepIndex = this.stepsList.findIndex(step => this.currentStep === step.name) + 1;
        return this.isLastStep ? this.currentStepDetail : this.stepsList[newStepIndex];
    }

    get progressValue() {
        return (this.stepsList.findIndex(step => step.name === this.currentStep) + 1) / this.stepsList.length * 100;
    }

    previous() {
        if (this.isFirstStep) {
            super.cancel();
        } else {
            this.dispatchEvent(new CustomEvent('previous', {
                bubbles: false,
                composed: false,
                detail: {
                    currentStep: this.currentStep,
                    previousStep: this.previousStep
                }
            }));
        }
    }

    next() {
        if (this.isLastStep) {
            super.submit();
        } else {
            this.dispatchEvent(new CustomEvent('next', {
                bubbles: false,
                composed: false,
                detail: {
                    currentStep: this.currentStep,
                    nextStep: this.nextStep
                }
            }));
        }
    }

    @api
    renderStep(step, stepsList) {
        this.hideProgressIndicator = true;
        this.stepsList = JSON.parse(JSON.stringify(stepsList || this.stepsList));
        if (step) {
            this.currentStep = step;
        } else {
            if (this.stepsList.length > 0 && !this.currentStep) {
                this.currentStep = this.stepsList[0].name;
            }
        }
        // setTimeout(() => {
        this.hideProgressIndicator = false;
        this.stepChange();
        // });
    }

    @api
    renderNextStep() {
        this.currentStep = this.nextStep;
        this.stepChange();
    }

    @api
    renderPreviousStep() {
        this.currentStep = this.previousStep;
        this.stepChange();
    }

    @api
    scrollToCurrentStep(timeout) {
        if (this.isProgressIndicatorVertical) {
            setTimeout(() => {
                let scroller = this.template.querySelector('.slds-is-active');
                if (scroller) {
                    scroller.scrollIntoView();
                }
            }, timeout);
        }
    }

    selectedStepChange(event) {
        if (this.selectAnyStep) {
            this.currentStep = event.target.value;
            this.stepChange();
        }
    }

    stepChange(isInit) {
        this.baseCmp.modalHeader = isInit ? this.modalHeader || this.currentStepDetail.title : this.currentStepDetail.title || this.modalHeader;
        this.baseCmp.modalSubtitle = isInit ? this.modalSubtitle || this.currentStepDetail.subtitle : this.currentStepDetail.subtitle || this.modalSubtitle;
        let evt = new CustomEvent('stepchanged', {
            bubbles: false,
            composed: false,
            detail: {
                currentStep: this.currentStep,
                isInit: isInit
            }
        });
        if (isInit === true) {
            setTimeout(() => {
                this.dispatchEvent(evt);
            });
        } else {
            this.dispatchEvent(evt);
        }

        let currentStepIndex = this.stepsList.findIndex(step => this.currentStep === step.name);
        this.stepsList_private = this.stepsList.map((step, index) => {
            let stepCloned = JSON.parse(JSON.stringify(step));
            stepCloned.isActive = this.currentStep === stepCloned.name;
            stepCloned.isCompleted = currentStepIndex > index;
            stepCloned.class = 'slds-progress__item';
            stepCloned.class += stepCloned.isActive ? ' slds-is-active' : '';
            stepCloned.class += stepCloned.isCompleted ? ' slds-is-completed' : '';
            stepCloned.contentClass = !stepCloned.isActive ? 'slds-hide' : '';
            return stepCloned;
        });
    }

    get progressStepClass() {
        return this.isModalActive ? 'bg-white' : '';
    }
}