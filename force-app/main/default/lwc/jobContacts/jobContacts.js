import {api, track, LightningElement} from 'lwc';
import {execute, showToast, isMobile} from 'c/aosUtils';
import {RefreshEvent} from "lightning/refresh";

export default class JobContacts extends LightningElement {
    @api recordId;
    @api hideAddViolenceButton = false;
    @api manageSelectedLabel;
    @api cardTitle = 'Job Contacts';
    @api view;
    @track jobContacts = [];
    @track jobContactsByJobs = [];
    @track violence = {};
    isBusy = false;
    isInspector = false;
    isJob = false;
    isMobile = isMobile();
    isContactCentreUser = false;
    showAddViolenceForm = false;
    showAddJobContactFlow = false;

    connectedCallback() {
        this.isBusy = true;
        this.refresh()
            .catch(ex => {
                showToast(this, 'Error', Array.isArray(ex) ? ex[0].message : ex.message || ex.body.message, 'error');
            })
            .finally(() => {
                this.isBusy = false;
            })
    }

    refresh() {
        return execute('aos_JobContactsMetaProc', {
            recordId: this.recordId
        })
            .then(response => {
                this.jobContacts = response.dto.jobContacts;
                this.jobContactsByJobs = response.dto.jobContactsByJobs;

                if (!this.view) {
                    if (response.dto.isContact === true) {
                        this.view = 'contact';
                    }
                    if (response.dto.isLocation === true) {
                        this.view = 'location';
                    }
                    if (response.dto.isJob === true) {
                        this.isJob = true;
                        this.view = this.isMobile === true ? 'jobMobile' : 'job';
                    }
                }

                if(this.view === 'locationsNearby' && this.isMobile === true) {
                    this.view = 'locationsNearbyMobile';
                }

                this.isContactCentreUser = response.dto.isContactCentreUser;
                this.isInspector = response.dto.isInspector;
            })
    }

    get showContent() {
        return this.isBusy === false;
    }

    get disableSelect() {
        return this.showAddViolenceForm === true || this.showAddJobContactFlow === true || this.isBusy;
    }

    get showJobContactsTable() {
        return this.jobContacts.length > 0 && this.showJobContactsByJobsTable === false;
    }

    get showJobContactsByJobsTable() {
        return this.jobContactsByJobs.length > 0 && (
            this.view === 'location' ||
            this.view === 'animalWelfareLocation' ||
            this.view === 'locationsNearby' ||
            this.view === 'animalWelfareLocationsNearby' ||
            this.view === 'locationsNearbyMobile'
        );
    }

    get hasJobContacts() {
        return this.showJobContactsTable || this.showJobContactsByJobsTable;
    }

    get hideAddViolenceForm() {
        return this.showAddViolenceForm === false;
    }

    get uniqueKey() {
        return `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
    }

    get addViolenceJobContactId() {
        return this.selectedJobContacts[0]?.Id;
    }

    handleAddCautionClick() {
        let selectedJobContacts = this.selectedJobContacts;
        if (!selectedJobContacts || selectedJobContacts.length !== 1) {
            showToast(this, 'Error', 'Select one Job Contact', 'error');
            return;
        }
        this.showAddViolenceForm = true;
    }

    get selectedJobContacts() {
        let selectedJobContacts;
        if (this.showJobContactsTable) {
            selectedJobContacts = this.jobContacts.filter(jobContact => jobContact.selected) || [];
        }

        if (this.showJobContactsByJobsTable) {
            selectedJobContacts = this.jobContactsByJobs.flatMap(array => array.filter(item => item.selected)) || [];
        }

        return selectedJobContacts;
    }

    handleManageSelectedClick() {
        let selectedJobContacts = this.selectedJobContacts;
        if (selectedJobContacts.length === 0) {
            showToast(this, 'Error', 'Select at least one Job Contact', 'error');
            return;
        }

        this.dispatchEvent(new CustomEvent('manageselected', {
            bubbles: false,
            composed: false,
            detail: {
                selectedJobContacts: selectedJobContacts
            }
        }));
    }

    handleRefreshClick(event) {
        this.isBusy = true;
        this.refresh()
            .catch(ex => {
                showToast(this, 'Error', Array.isArray(ex) ? ex[0].message : ex.message || ex.body.message, 'error');
            })
            .finally(() => {
                this.isBusy = false;
            })
    }

    handleSubmitAddViolenceForm(event) {
        this.showAddViolenceForm = false;
        this.isBusy = true;
        let interactionCaution = event.detail?.interactionCaution;

        if (interactionCaution) {
            execute('aos_DMLProc', {
                sObjectType: 'animalos__Interaction_Caution__c',
                upsert: [interactionCaution]
            })
                .then(response => {
                    this.dispatchEvent(new RefreshEvent());
                    return this.refresh();
                })
                .catch(ex => {
                    showToast(this, 'Error', Array.isArray(ex) ? ex[0].message : ex.message || ex.body.message, 'error');
                })
                .finally(() => {
                    this.isBusy = false;
                })
        }
    }

    handleCancelAddViolenceForm() {
        this.showAddViolenceForm = false;
    }

    handleAddJobContactClick(event) {
        this.showAddJobContactFlow = true;
    }

    get addJobContactFlowInputs() {
        return [
            {
                name: 'jobId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    handleFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.showAddJobContactFlow = false;
            this.refresh();
        }
    }

    handleJobContactAction(event) {
        let action = event.detail.action,
            index = event.detail.index,
            selected = event.detail.selected;

        if (action !== undefined && index !== undefined) {
            switch (action) {
                case 'select':
                    this.jobContacts[index].selected = selected;
                    break;
            }
        }
    }

    handleJobContactsByJobAction(event) {
        let action = event.detail.action,
            id = event.detail.id,
            index = event.detail.index,
            selected = event.detail.selected;

        if (action !== undefined && index !== undefined) {
            switch (action) {
                case 'select':
                    this.jobContactsByJobs[index].find(jobContact => jobContact.Id === id).selected = selected;
                    break;
            }
        }
    }

    handleSelectAllChange(event) {
        let checked = event.detail.checked === true;
        if (this.showJobContactsTable) {
            this.jobContacts = this.jobContacts.map(jobContact => {
                jobContact.selected = checked;
                return jobContact;
            });
        }
        if (this.showJobContactsByJobsTable) {
            this.jobContactsByJobs = this.jobContactsByJobs.map(jobContacts => {
                return jobContacts.map(jobContact => {
                    jobContact.selected = checked;
                    return jobContact;
                });
            });
        }
    }

    get showRefreshButton() {
        return this.hideAddViolenceForm === true && this.isMobile === false;
    }

    get showManageSelectedButton() {
        return this.manageSelectedLabel !== undefined;
    }

    get showAddJobContactButton() {
        return this.isJob === true && this.showAddViolenceForm === false;
    }

    get showAddViolenceButton() {
        return this.hideAddViolenceButton === false && this.showAddViolenceForm === false;
    }

    get isLocationsNearbyView() {
        return this.view === 'locationsNearby' || this.view === 'animalWelfareLocationsNearby' || this.view === 'locationsNearbyMobile';
    }

    get locationAdvisory() {
        return (this.jobContactsByJobs && this.jobContactsByJobs.length && this.jobContactsByJobs[0].length) ? this.jobContactsByJobs[0][0].animalos__Job__r.animalos__Location_Of_Interest__r?.animalos__Advisory__c : '';
    }
}