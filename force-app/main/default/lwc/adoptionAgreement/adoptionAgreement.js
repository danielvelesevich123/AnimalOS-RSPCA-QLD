import {api, track, LightningElement} from 'lwc';
import {execute} from 'c/verticUtils';
import logo from '@salesforce/resourceUrl/RspcaLogoPNG';

export default class AdoptionAgreement extends LightningElement {
    @api meta = {};
    @api recordId;
    @track isBusy;

    adoptionAgreementSignature;
    indemnityWaiverContractSignature;
    today = new Date();
    logo = logo;
    isSubmitted = false;
    isSent = false;

    get sendButtonEnabled() {
        return this.meta.dto.isGuest === false && this.lastStep;
    }

    get hasAnyDogs() {
        return this.meta.dto?.dogs?.length > 0;
    }

    connectedCallback() {
        this.isBusy = true;
        this.recordId = new URLSearchParams(window.location.search).get('recordId');
        execute('aos_AdoptionAgreementMetaProc', {recordId: this.recordId})
            .then(response => {
                this.meta = response;
                // if (this.hasAnyDogs) {
                //     this.steps.splice(3, 0, {name: 'evaluationSummaryStep', label: 'Evaluation Summary'});
                // }
            })
            .catch(errors => {
                this.refs.toast.showToast('error', errors[0].message);
            })
            .finally(() => {
                this.isBusy = false;
            });
    }

    get showContent() {
        return this.isSubmitted === false && this.isSent === false && this.meta.dto !== undefined;
    }

    get referralName() {
        return this.meta.dto?.referral?.animalos__Contact__r?.Name;
    }

    get receiptNumber() {
        return 'ADOPT' + this.meta.dto?.referral?.aos_Referral_ID__c;
    }

    handleThirdPartMarketingChange(event) {
        this.meta.dto.referral.aos_Third_Party_Marketing_Opt_Out__c = event.target.checked;
    }

    handleRoyalCanineChange(event) {
        this.meta.dto.referral.aos_Royal_Canin_s_Healthy_Pets_Club_Opt__c = event.target.checked;
    }

    saveClick(event) {
        if (this.validateSignature(true) === false) {
            return;
        }
        this.meta.dto.referral.Id = this.recordId;
        this.isBusy = true;
        execute('aos_AdoptionAgreementSubmitProc', {
            adoptionAgreementSignature: this.adoptionAgreementSignature,
            indemnityWaiverContractSignature: this.indemnityWaiverContractSignature,
            referral: this.meta.dto.referral
        })
            .then(response => {
                this.isSubmitted = true;
            })
            .catch(errors => {
                this.refs.toast.showToast('error', errors[0].message);
            })
            .finally(() => {
                this.isBusy = false;
            });
    }

    sendClick(event) {
        this.isBusy = true;

        execute('aos_AdoptionAgreementSendEmailProc', {
            referralId: this.recordId
        })
            .then(response => {
                this.refs.toast.showToast('success', 'Email is sent successfully.');
            })
            .catch(errors => {
                this.refs.toast.showToast('error', errors[0].message);
            })
            .finally(() => {
                this.isBusy = false;
                this.isSent = true;
            });
    }

    //stepper
    @api currentStep = 'ownerDetailsStep';

    @api steps = [
        {name: 'ownerDetailsStep', label: 'Personal Information Collection Notice/ Animal Details'},
        {name: 'testOutcomesAndTreatmentsStep', label: 'Test Outcomes And Treatments'},
        {name: 'indemnityWaiverContractStep', label: 'Indemnity Waiver Contract'},
        {name: 'adoptionAgreementStep', label: 'Adoption Agreement'}
    ];

    nextClick(event) {
        let currentIndex = this.steps.findIndex(step => step.name === this.currentStep);

        if (this.validateSignature() === false) {
            return;
        }

        this.currentStep = this.steps[currentIndex + 1].name;
        this.scrollTop();
    }

    previousClick(event) {
        let currentIndex = this.steps.findIndex(step => step.name === this.currentStep);
        this.currentStep = this.steps[currentIndex - 1].name;
        this.scrollTop();
    }

    validateSignature(isSave) {
        if ((this.showAdoptionAgreementStep || this.showIndemnityWaiverContractStep)) {
            let signature = this.template.querySelector('c-capture-signature').getBase64Data();


            if (this.meta.dto.isGuest === true && (!signature || signature.length < 800)) {
                this.refs.toast.showToast('error', this.showAdoptionAgreementStep ? 'Please sign the Adoption Agreement.' : 'Please sign the Indemnity Waiver Contract.');
                return false;
            }

            if (this.showAdoptionAgreementStep) {
                this.adoptionAgreementSignature = signature;
            }

            if (this.showIndemnityWaiverContractStep) {
                this.indemnityWaiverContractSignature = signature;
            }
        }

        if (isSave === true) {
            if (!this.indemnityWaiverContractSignature || this.indemnityWaiverContractSignature.length < 800) {
                this.refs.toast.showToast('error', 'Please sign the Indemnity Waiver Contract.');
                return false;
            }

            if (!this.adoptionAgreementSignature || this.adoptionAgreementSignature.length < 800) {
                this.refs.toast.showToast('error', 'Please sign the Adoption Agreement.');
                return false;
            }
        }
        return true;
    }

    scrollTop() {
        window.scrollTo({
            left: 0,
            top: 0,
            behavior: 'smooth'
        });
    }

    selectedStepChange(event) {
        this.currentStep = event.target.value;
    }

    get lastStep() {
        return this.currentStep === 'adoptionAgreementStep';
    }

    get notLastStep() {
        return this.currentStep !== 'adoptionAgreementStep';
    }

    get notFirstStep() {
        return this.currentStep !== 'ownerDetailsStep';
    }

    get showOwnerDetailsStep() {
        return this.currentStep === 'ownerDetailsStep';
    }

    get showAdoptionAgreementStep() {
        return this.currentStep === 'adoptionAgreementStep';
    }

    get showTestOutcomesAndTreatmentsStep() {
        return this.currentStep === 'testOutcomesAndTreatmentsStep';
    }

    get showIndemnityWaiverContractStep() {
        return this.currentStep === 'indemnityWaiverContractStep';
    }

    get showEvaluationSummaryStep() {
        return this.currentStep === 'evaluationSummaryStep';
    }
}