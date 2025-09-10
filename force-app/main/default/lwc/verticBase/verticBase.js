import {api, LightningElement, wire} from 'lwc';
import {chunk, execute, flatten, getURlParams, showToast, validate} from 'c/verticUtils'
import {CurrentPageReference} from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import {CloseActionScreenEvent} from 'lightning/actions';

export default class BaseElement extends LightningElement {

    /**
     * ==============================================================================================================
     *                                             BASE IMPLEMENTATION
     * ==============================================================================================================
     */

        // Public attributes
    @api recordId;
    @api processor;
    @api meta;
    @api isBusy = false;
    @api errorMessages;
    @api trueValue = !false;
    @api falseValue = false;

    // Private attributes
    currentPageReference;

    connectedCallback() {
        this.initQuickAction();
        this.recordId = this.recordId || this.currentPageReference?.state?.recordId || this.currentPageReference?.state?.Id || this.currentPageReference?.state?.c__recordId || this.currentPageReference?.state?.c__Id || this.currentPageReference?.attributes?.recordId;
        if ((this.isModalActive && this.processor) || (this.modal !== true && this.processor)) {
            this.doInit().catch(errors => {
                this.clearErrors();
                showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message || errors.body.message, 'error');
            });
        } else {
            this.dispatchEvent(new CustomEvent('init', {
                bubbles: false,
                composed: false
            }));
        }
    }

    handleInit(event) {
        if (event.detail?.meta) {
            this.meta = JSON.parse(JSON.stringify(event.detail.meta));
            if (this.stepsCmp) {
                this.stepsCmp.meta = JSON.parse(JSON.stringify(this.meta));
            }
        }
    }

    @api
    setRecordId(recordId) {
        if (this.baseCmp) {
            this.baseCmp.setRecordId(recordId);
        }
        if (this.stepperCmp) {
            this.stepperCmp.setRecordId(recordId);
        }
        if (this.stepsCmp) {
            this.stepsCmp.setRecordId(recordId);
        }
        this.recordId = recordId;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.currentPageReference = currentPageReference;
        }
    }

    @api
    scrollTop(timeout) {
        setTimeout(() => {
            let scroller = this.template.querySelector('[data-id="container"]');
            if (scroller) {
                scroller.scrollIntoView();
                this.dispatchEvent(new CustomEvent('scrolltop', {
                    bubbles: false,
                    composed: false
                }));
            }
        }, timeout);
    }

    @api
    scrollDown(timeout) {
        setTimeout(() => {
            let scroller = this.template.querySelector('[data-id="container"]');
            if (scroller) {
                scroller.scroll(0, scroller.scrollHeight);
                this.dispatchEvent(new CustomEvent('scrolldown', {
                    bubbles: false,
                    composed: false
                }));
            }
        }, timeout);
    }

    @api
    scrollBy(x, y, timeout) {
        setTimeout(() => {
            let scroller = this.template.querySelector('[data-id="container"]');
            if (scroller) {
                scroller.scrollBy(x, y);
                this.dispatchEvent(new CustomEvent('scrollby', {
                    bubbles: false,
                    composed: false
                }));
            }
        }, timeout);
    }

    @api
    clearErrors() {
        this.errorMessages = null;
    }

    @api
    showErrors(errors, isScrollTop) {
        this.errorMessages = errors || [];
        if (isScrollTop === true) {
            this.scrollTop();
        }
    }

    @api
    get hasErrors() {
        return this.errorMessages?.length > 0;
    }

    execute(processor, request) {
        this.isBusy = true;
        return execute(
            processor,
            request
        ).then((meta) => {
            this.isBusy = false;
            return meta;
        }).catch((errors) => {
            this.isBusy = false;
            this.errorMessages = errors;
            throw errors;
        });
    }

    @api
    doInit(request, processor) {
        return new Promise((resolve, reject) => {
            if (processor || this.processor) {
                request = request || {};
                if (this.recordId) {
                    request.recordId = this.recordId;
                }
                this.execute(
                    processor || this.processor,
                    request
                ).then((meta) => {
                    this.meta = meta;
                    this.dispatchEvent(new CustomEvent('init', {
                        bubbles: false,
                        composed: false,
                        detail: {
                            meta: JSON.parse(JSON.stringify(this.meta))
                        }
                    }));
                    resolve(meta);
                }).catch((errors) => {
                    this.errorMessages = errors;
                    reject(errors);
                });
            } else {
                this.meta = {
                    dto: {},
                    selectOptions: {},
                    dependentOptions: {}
                };
            }
        });
    }

    @api
    validate(formId, options) {
        formId = formId || 'container';
        options = options || {};
        options.isScrollTop = options.isScrollTop !== false;

        let formContainer = this.template.querySelector(`[data-id="${formId}"]`);
        if (Array.isArray(formContainer)) formContainer = formContainer[0];

        if (formContainer == null) {
            throw 'No Form with data-id: ' + formId;
        }

        this.clearErrors();

        let validationResult = validate(formContainer, options);
        if (validationResult.allValid !== true) {
            this.showErrors(validationResult.getErrorMessages(), options.isScrollTop);
            return false;
        }

        return true;
    }

    setMapValue(map, path, value) {
        if (!path || path.length === 0) {
            return value;
        }
        if (!Array.isArray(path)) {
            path = path.split('.');
        }

        let key = path[0];
        if (key.startsWith('[') && key.endsWith(']')) {
            key = parseInt(key.substring(0, key.length - 1).substring(1));
        }

        map[key] = map[key] || {};

        path.splice(0, 1);
        map[key] = this.setMapValue(map[key], path, value);

        return map;
    }

    handleFieldChange(event) {
        event.preventDefault();
        event.stopPropagation();

        let index = event.target.getAttribute('data-index');
        let path = event.target.getAttribute('data-path');
        let pathLogic = event.target.getAttribute('data-path-logic');
        let isCheckbox = event.target.type === 'toggle' || event.target.type === 'checkbox' || event.target.type === 'checkbox-button';
        let value = isCheckbox ? event.target.checked : event.target?.selectedValues || event.target?.value || event.detail?.value;
        if (pathLogic === 'not') {
            value = !value;
        }
        path = path.replaceAll('[data-index]', '[' + index + ']');
        this.meta = this.setMapValue(this.meta, 'dto.' + path, value);
        let dependentOptionsAttribute = event.target.getAttribute('data-dependent-options');
        if (dependentOptionsAttribute) {
            let controllingFieldValue = event.target.value;
            let dependentOptions = this.meta.dependentOptions[dependentOptionsAttribute];
            this.meta.selectOptions[dependentOptionsAttribute] = dependentOptions[controllingFieldValue];
        }
    }

    get baseCmp() {
        return this.template.querySelector('c-vertic-base');
    }

    get isDesktop() {
        return FORM_FACTOR === 'Large';
    }

    get isMobile() {
        return FORM_FACTOR === 'Small';
    }

    get isTablet() {
        return FORM_FACTOR === 'Medium';
    }


    /**
     * ==============================================================================================================
     *                                         QUICK ACTION IMPLEMENTATION
     * ==============================================================================================================
     */

    @api quickAction;

    @api
    invoke() {
        this.open();
    }

    initQuickAction() {
        if (this.quickAction === true) {
            let quickActionContainer = window.document.querySelector('.modal-container.slds-modal__container');
            if (quickActionContainer && quickActionContainer.length > 0) {
                quickActionContainer = quickActionContainer[0];
            }
            let _isQuickAction = quickActionContainer != null && quickActionContainer.className === 'modal-container slds-modal__container';
            if (_isQuickAction === true) {
                quickActionContainer.style.transform = "unset";
                let closeIcon = quickActionContainer.querySelector('.closeIcon');
                if (closeIcon) closeIcon.style.display = 'none';
                let backdrop = window.document.querySelector('.forceModal > .slds-backdrop.slds-backdrop--open');
                if (backdrop) backdrop.style.display = 'none';
                try {
                    this.open();
                } catch (e) {
                }
            }
        }
    }

    /**
     * ==============================================================================================================
     *                                             MODAL IMPLEMENTATION
     * ==============================================================================================================
     */

    @api modal = false;
    @api modalOpen = false;
    @api modalHeader;
    @api modalSubtitle;
    @api modalHeadless = false;
    @api modalFootless = false;
    @api modalSize; // small, medium, large, x-large, full
    @api modalPlacement = 'left'; // left (default), right
    @api modalLevel = '0';
    @api modalStyle = 'modal'; // modal (default), panel
    @api doNotCloseOnCancel = false;
    @api cancelButtonHidden = false;
    @api cancelButtonDisabled = false;
    @api saveButtonHidden = false;
    @api saveButtonDisabled = false;
    @api cancelButtonLabel = 'Cancel';
    @api saveButtonLabel = 'Save';

    @api
    open(event) {
        if (!event && this.stepperCmp && this.stepperCmp.open) {
            this.stepperCmp.open();
        } else if (!event && this.baseCmp && this.baseCmp.open) {
            this.baseCmp.open();
        } else if (this.modalOpen !== true) {
            this.modalOpen = true;
            this.preventMainBodyScroll();
            this.connectedCallback();
            this.dispatchEvent(new CustomEvent('open', {
                bubbles: false,
                composed: false
            }));
        }
    }

    handleOpen(event) {
        this.open(event);
    }

    @api
    close(event) {
        if (!event && this.baseCmp) {
            this.baseCmp.close();
        } else if (this.modalOpen === true) {
            // this.recordId = undefined;
            this.meta = undefined;
            this.modalOpen = false;
            this.allowMainBodyScroll();
            this.dispatchEvent(new CustomEvent('close', {
                detail: {
                    quickAction: this.quickAction
                },
                bubbles: false,
                composed: false
            }));
        }
        if (this.quickAction === true || event?.detail?.quickAction === true) {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    handleClose(event) {
        this.close(event);
    }

    // Method that triggers an event to a Modal Implementation component
    cancel() {
        if (this.doNotCloseOnCancel !== true) {
            this.close();
        }
        this.dispatchEvent(new CustomEvent('cancel', {
            bubbles: false,
            composed: false
        }));
    }

    // The base implementation of the Cancel Event Handler that just throws the event (from the above method) further up
    handleCancel(event) {
        this.dispatchEvent(new CustomEvent('cancel', {
            bubbles: false,
            composed: false,
            detail: {
                meta: JSON.parse(JSON.stringify(this.meta))
            }
        }));
    }

    // Method that triggers an event to a Modal Implementation component
    submit() {
        this.dispatchEvent(new CustomEvent('submit', {
            bubbles: false,
            composed: false
        }));
    }

    // The base implementation of the Submit Event Handler that just throws the event (from the above method) further up
    handleSubmit(event) {
        this.dispatchEvent(new CustomEvent('submit', {
            bubbles: false,
            composed: false,
            detail: {
                meta: JSON.parse(JSON.stringify(this.meta))
            }
        }));
    }

    preventMainBodyScroll() {
        let body = window.document.querySelector('body');
        if (body) {
            body.style.overflow = 'hidden';
        }
    }

    allowMainBodyScroll() {
        let body = window.document.querySelector('body');
        if (body) {
            body.style.overflow = 'initial';
        }
    }

    get panelClasses() {
        return 'slds-panel slds-panel_docked slds-panel_drawer slds-is-open' + (this.modalSize ? ' slds-size_' + this.modalSize : '') + (this.modalPlacement ? ' slds-panel_docked-' + this.modalPlacement : '');
    }

    get modalClasses() {
        return 'slds-modal slds-fade-in-open' + (this.modalSize ? ' slds-modal_' + this.modalSize : '');
    }

    get containerStyles() {
        return this.isPanel ? 'height: 100%;' : '';
    }

    get modalStyles() {
        return 'z-index: ' + (9001 + parseInt(this.modalLevel));
    }

    get panelStyles() {
        return 'z-index: ' + (0 + parseInt(this.modalLevel));
    }

    get backdropStyles() {
        return 'z-index: ' + (9000 + parseInt(this.modalLevel));
    }

    get isPanel() {
        return this.modalStyle === 'panel';
    }

    get isModalActive() {
        return this.modal === true && this.modalOpen === true;
    }


    /**
     * ==============================================================================================================
     *                                             STEPPER IMPLEMENTATION
     * ==============================================================================================================
     */

    handleNext(event) {
        if (this.stepsCmp.validate()) {
            this.stepperCmp.renderNextStep();
        }
    }

    handlePrevious(event) {
        this.stepperCmp.renderPreviousStep();
    }

    handleStepChanged(event, timeout, noScroll) {
        if (this.stepsCmp) {
            this.stepsCmp.renderStepContent(event.detail.currentStep);
        }
        if (this.stepperCmp && this.stepperCmp.isProgressIndicatorVertical) {
            this.stepperCmp.scrollToCurrentStep(timeout);
        } else if (this.stepsCmp && !noScroll) {
            this.stepsCmp.scrollTop(timeout);
        }
    }

    @api
    get stepsCmp() {
        if (this.stepperCmp && this.stepperCmp.isProgressIndicatorVertical) {
            let steps = this.template.querySelectorAll('[data-steps]');
            return steps && steps.length > this.stepperCmp.currentStepIndex ? steps[this.stepperCmp.currentStepIndex] : steps[0];
        }
        return this.template.querySelector('[data-steps]');
    }

    @api
    get stepperCmp() {
        return this.template.querySelector('c-vertic-stepper');
    }

    /**
     * ==============================================================================================================
     */
}

export {BaseElement, showToast, execute, validate, flatten, chunk, getURlParams}