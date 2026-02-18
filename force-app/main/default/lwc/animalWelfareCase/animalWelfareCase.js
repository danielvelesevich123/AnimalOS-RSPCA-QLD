import {showToast, execute, validate} from "c/aosUtils";
import {LightningElement, track, wire} from "lwc";
import {getPicklistValues, getObjectInfo} from "lightning/uiObjectInfoApi";
import JOB_STATUS from "@salesforce/schema/animalos__Job__c.animalos__Status__c";
import JOB_PRIORITY from "@salesforce/schema/animalos__Job__c.animalos__Priority__c";
import JOB_CODES from "@salesforce/schema/animalos__Job__c.animalos__Codes__c";


export default class AnimalWelfareCase extends LightningElement {
    isBusy = false;
    isJobContactSearching = false;
    isSubmit = false;
    hideJobContactForm = false;
    hideAnimalReportForm = false;
    hideCaseForm = false;
    recordId;

    @track jobContacts = [];
    @track jobContact = {animalos__Contact__r: {}};
    @track animalReports = [];
    @track animalReport = {};
    @track job = {
        animalos__Status__c: 'New'
    };
    @track caseVar = {};
    @track selectOptions = {};

    inspectorateRecordTypeId;
    rescueRecordTypeId;
    wildlifeHubRecordTypeId;
    inspectorateStatusOptions;
    rescueStatusOptions;
    wildlifeHubStatusOptions;
    inspectoratePriorityOptions;
    rescuePriorityOptions;
    wildlifeHubPriorityOptions;
    inspectorateCodesOptions;
    rescueCodesOptions;
    wildlifeHubCodesOptions;

    @wire(getPicklistValues, {recordTypeId: "$inspectorateRecordTypeId", fieldApiName: JOB_STATUS})
    inspectorateStatusOptionsResults({error, data}) {
        if (data) {
            this.inspectorateStatusOptions = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: "$rescueRecordTypeId", fieldApiName: JOB_STATUS})
    rescueStatusOptionsResults({error, data}) {
        if (data) {
            this.rescueStatusOptions = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: "$wildlifeHubRecordTypeId", fieldApiName: JOB_STATUS})
    wildlifeHubStatusOptionsResults({error, data}) {
        if (data) {
            this.wildlifeHubStatusOptions = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: "$inspectorateRecordTypeId", fieldApiName: JOB_PRIORITY})
    inspectoratePriorityOptionsResults({error, data}) {
        if (data) {
            this.inspectoratePriorityOptions = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: "$rescueRecordTypeId", fieldApiName: JOB_PRIORITY})
    rescuePriorityOptionsResults({error, data}) {
        if (data) {
            this.rescuePriorityOptions = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: "$wildlifeHubRecordTypeId", fieldApiName: JOB_PRIORITY})
    wildlifeHubPriorityOptionsResults({error, data}) {
        if (data) {
            this.wildlifeHubPriorityOptions = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: "$inspectorateRecordTypeId", fieldApiName: JOB_CODES})
    inspectorateCodesOptionsResults({error, data}) {
        if (data) {
            this.inspectorateCodesOptions = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: "$rescueRecordTypeId", fieldApiName: JOB_CODES})
    rescueCodesOptionsResults({error, data}) {
        if (data) {
            this.rescueCodesOptions = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: "$wildlifeHubRecordTypeId", fieldApiName: JOB_CODES})
    wildlifeHubCodesOptionsResults({error, data}) {
        if (data) {
            this.wildlifeHubCodesOptions = data.values;
        }
    }

    crueltyTypeCodesMap = new Map([
        ['Abandoned or left unattended exceeding 24 hrs', ['Abandoned', 'Food & Water', 'Unattended 24hrs']],
        ['Breeder or Pet Shop Inspection', ['Breeder', 'Pet Shop Inspection']],
        ['Ill-treatment (direct physical abuse)', ['Ill Treatment']],
        ['In need of Veterinary Treatment', ['Vet Treatment']],
        ['Insufficient Food and Water', ['Food & Water']],
        ['Shelter & Living Conditions', ['Insufficient shelter']],
        ['Tied continuously or locked in a small pen/cage', ['Locked In Small Pen', 'Tied Continually']],
        ['Deceased animals', ['Dead']],
        ['Other', []],
        ['Animal Flighted', ['Flighted Bird']]
    ]);

    connectedCallback() {
        this.caseVar.Subject = 'Animal Welfare';
        this.caseVar.Type = 'Cruelty Complaint';
        this.caseVar.Priority = 'Minor';
        this.caseVar.Status = 'New';
        this.jobContact.animalos__Contact_Type__c = 'Informant';
        let searchParams = new URLSearchParams(window.location.search);
        if (searchParams) {
            this.recordId = searchParams.get('c__recordId');
            this.caseVar.Priority = searchParams.get('c__priority') || this.caseVar.Priority;
            this.caseVar.Origin = searchParams.get('c__caseOrigin');
            this.caseVar.Job_Categorisation__c = searchParams.get('c__jobCategorisation');
            this.caseVar.Reported_Animal_Type__c = searchParams.get('c__reportedAnimalType');
            this.caseVar.Phone = searchParams.get('c__phone') ? searchParams.get('c__phone') : searchParams.get('c__mobilePhone');
            this.animalReport.animalos__Cruelty_Type__c = searchParams.get('c__jobCategorisation');
            this.animalReport.animalos__Animal_Type__c = searchParams.get('c__reportedAnimalType');
            this.jobContact.animalos__Contact__r.FirstName = searchParams.get('c__firstName');
            this.jobContact.animalos__Contact__r.LastName = searchParams.get('c__lastName');
            this.jobContact.animalos__Contact__r.MailingPostalCode = searchParams.get('c__postcode');
            this.jobContact.animalos__Contact__r.MobilePhone = searchParams.get('c__mobilePhone');
            this.jobContact.animalos__Contact__r.Phone = searchParams.get('c__phone');
        }
        this.refresh(this.recordId);
    }

    refresh(recordId) {
        this.isBusy = true;
        return execute('aos_AnimalWelfareCaseMetaProc', {recordId: recordId})
            .then(response => {
                this.job = response.dto.job || this.job;
                this.caseVar = response.dto.caseVar || this.caseVar;
                this.jobContacts = response.dto.jobContacts || [];
                this.animalReports = response.dto.animalReports || [];
                this.selectOptions = response.selectOptions;
                this.currentStep = 'callerInformation';
                this.inspectorateRecordTypeId = response.dto.inspectorateRecordTypeId;
                this.rescueRecordTypeId = response.dto.rescueRecordTypeId;
                this.wildlifeHubRecordTypeId = response.dto.wildlifeHubRecordTypeId;
            })
            .catch(errors => {
                showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error');
            })
            .finally(() => {
                this.isBusy = false;
            });
    }

    handleSaveClick() {
        if (!this.animalReports?.length || this.animalReports?.length === 0) {
            showToast(this, 'Error', 'Add at least one animal report', 'error');
            return;
        }

        if (!this.jobContacts?.length || this.jobContacts?.length === 0) {
            showToast(this, 'Error', 'Add at least one job contact', 'error');
            return;
        }

        if (this.jobContacts.find(jobContact => jobContact.aos_Verbally_or_Physically_Abusive__c === 'Yes' && (!jobContact.animalos__Interaction_Cautions__r || !jobContact.animalos__Interaction_Cautions__r.records || jobContact.animalos__Interaction_Cautions__r?.records?.length === 0))) {
            showToast(this, 'Error', 'A caution must be added to the POI Job Contact, please review Job Contacts.', 'error');
            return;

        }

        let caseForm = this.template.querySelector(`[data-id="caseForm"]`);

        if (Array.isArray(caseForm)) {
            caseForm = caseForm[0];
        }

        let caseValidateResult = validate(caseForm, {});
        if (caseValidateResult.allValid !== true) {
            this.scrollTop();
            showToast(this, 'Error', 'Populate all required fields', 'error');
            return;
        }

        this.isSubmit = true;
        execute(
            'AnimalWelfareCaseSubmitProc',
            {
                job: this.job,
                case: this.caseVar,
                locationOfInterest: this.refs.locationOfInterestCmp.locationOfInterest,
                animalReports: this.animalReports,
                jobContacts: this.jobContacts
            })
            .then(response => {
                showToast(
                    this,
                    'Success',
                    '{0} successfully created/updated. {1} successfully created/updated.',
                    'success',
                    [
                        {
                            url: '/' + response.dto.job.Id,
                            label: 'Job ' + response.dto.job?.Name
                        },
                        {
                            url: '/' + response.dto.caseVar.Id,
                            label: 'Case ' + response.dto.caseVar?.CaseNumber
                        }
                    ],
                    'sticky'
                );
                // window.location.href = 'https://' + window.location.hostname + '/' + response.dto.caseVar?.Id;
            })
            .catch(errors => {
                showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error');
            })
            .finally(() => {
                this.isSubmit = false;
            });
    }

    handleAddJobContactClick() {
        let formContainer = this.template.querySelector(`[data-id="jobContactForm"]`);
        if (Array.isArray(formContainer)) formContainer = formContainer[0];

        if (validate(formContainer, {}).allValid !== true) {
            return;
        }

        this.jobContacts.push(JSON.parse(JSON.stringify(this.jobContact)));
        this.jobContact = {animalos__Contact__r: {}};
        this.setAddress();
        this.resetJobContactForm();
    }

    handleCopyJobAddressClick() {
        const locationOfInterest = this.refs.locationOfInterestCmp?.locationOfInterest;

        this.jobContact.animalos__Contact__r.MailingStreet = locationOfInterest.animalos__Address__Street__s;
        this.jobContact.animalos__Contact__r.MailingCity = locationOfInterest.animalos__Address__City__s;
        this.jobContact.animalos__Contact__r.MailingState = locationOfInterest.animalos__Address__StateCode__s;
        this.jobContact.animalos__Contact__r.MailingPostalCode = locationOfInterest.animalos__Address__PostalCode__s;
        this.jobContact.animalos__Contact__r.MailingCountry = locationOfInterest.animalos__Address__CountryCode__s;
    }

    handleAddAnimalReportClick() {
        let formContainer = this.template.querySelector(`[data-id="animalReportForm"]`);
        if (Array.isArray(formContainer)) {
            formContainer = formContainer[0];
        }

        if (validate(formContainer, {}).allValid !== true) {
            return;
        }

        this.animalReports.push(JSON.parse(JSON.stringify(this.animalReport)));
        this.setJobCodes();
        this.animalReport = {};
        this.resetAnimalReportForm();
    }

    handleJobFieldChange(event) {
        this.job = this.handleFieldChange(this.job, event);

        let path = event.target.getAttribute('data-path');

        switch (path) {
            case 'animalos__Parent_Job__c':
                let parentJobLookupField = this.template.querySelector(`[data-id="parentJobLookupField"]`);

                let currentCodes = this.job.animalos__Codes__c?.split(';') || [];
                let parentJobCodes = parentJobLookupField.selectedRecord?.record?.animalos__Codes__c?.split(';') || [];
                let codes = new Set([...currentCodes, ...parentJobCodes]);

                this.job.animalos__Codes__c = [...codes].join(';');
                this.resetCaseForm();
                break;
            case 'animalos__Priority__c':
                this.caseVar.Priority = this.job.animalos__Priority__c;
                break;
        }

    }

    handleJobRecordTypeChange(event) {
        this.job.RecordTypeId = event.target.value;

        if (this.isRescueRecordType) {
            this.animalReport.animalos__Cruelty_Type__c = null;
        } else if (this.isInspectorateRecordType) {
            this.job.aos_Complexity__c = null;
            this.animalReport.aos_Rescue_Type__c = null;
        } else {
            this.animalReport.animalos__Cruelty_Type__c = null;
            this.animalReport.aos_Rescue_Type__c = null;
        }

        if (this.animalReports.length > 0) {
            this.animalReports.forEach(report => {
                if (this.isRescueRecordType) {
                    report.animalos__Cruelty_Type__c = null;
                } else if (this.isInspectorateRecordType) {
                    report.aos_Rescue_Type__c = null;
                } else {
                    report.animalos__Cruelty_Type__c = null;
                    report.aos_Rescue_Type__c = null;
                }
            });
        }
        this.setJobCodes();

        this.resetCaseForm();
    }

    handleCaseFieldChange(event) {
        this.caseVar = this.handleFieldChange(this.caseVar, event);
    }

    handleCasePhoneChange(event) {
        //execute a proc to find an existing job contact by phone
        if (event && event.target.value) {
            this.isJobContactSearching = true;
            execute('aos_SOQLProc', {
                SOQL:
                    'SELECT Id, FirstName, LastName, Email, MobilePhone, Phone, ' +
                    'MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,' +
                    'ID_Type__c, ID_Number__c, Birthdate, ' +
                    '(SELECT AccountId FROM AccountContactRelations WHERE Account.RecordType.DeveloperName = \'Organization\') ' +
                    'FROM Contact ' +
                    'WHERE (MobilePhone = \'' + event.target.value + '\' OR Phone = \'' + event.target.value + '\')' +
                    'AND Id IN (SELECT animalos__Contact__c FROM animalos__Job_Contact__c WHERE animalos__Contact_Type__c = \'Informant\')' +
                    'LIMIT 1'
            })
                .then(response => {
                    if (response.dto.records && response.dto.records.length > 0) {
                        let existingContact = response.dto.records[0];
                        let organizationId;
                        if (existingContact.AccountContactRelations && existingContact.AccountContactRelations.length > 0) {
                            organizationId = existingContact.AccountContactRelations[0].AccountId;
                        }
                        this.jobContact.animalos__Contact__r = existingContact;
                        this.jobContact.animalos__Organization__c = organizationId;
                        this.jobContact.animalos__Contact_Type__c = 'Informant';
                    } else {
                        this.jobContact = {animalos__Contact_Type__c: 'Informant', animalos__Contact__r: {}};
                    }
                    this.resetJobContactForm();
                })
                .catch(errors => {
                    showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error');
                })
                .finally(() => {
                    this.isJobContactSearching = false;
                });
        }
        this.caseVar = this.handleFieldChange(this.caseVar, event);
    }

    handleJobContactFieldChange(event) {
        this.jobContact = this.handleFieldChange(this.jobContact, event);
    }

    handleJobContactPhoneBlur(event) {
        let path = event.target.getAttribute('data-path');
        let value = event.target.value;

        // Remove all whitespace first
        let cleanValue = value?.replace(/\s/g, '') || '';

        switch (path) {
            case 'animalos__Contact__r.MobilePhone':
                this.jobContact.animalos__Contact__r.MobilePhone = this.formatMobilePhone(cleanValue);
                break;
            case 'animalos__Contact__r.Phone':
                this.jobContact.animalos__Contact__r.Phone = this.formatLandlinePhone(cleanValue);
                break;
        }
    }

    formatMobilePhone(value) {
        if (!value) return '';

        // Handle +61433352553 format - format as +61433 352 553
        let match = value.match(/^\+614(\d{2})(\d{3})(\d+)$/);
        if (match) {
            return `+614${match[1]} ${match[2]} ${match[3]}`;
        }

        // Handle 61433352553 format (without +) - format as +61433 352 553
        match = value.match(/^614(\d{2})(\d{3})(\d+)$/);
        if (match) {
            return `+614${match[1]} ${match[2]} ${match[3]}`;
        }

        // Handle existing 0433352553 format - format as 0433 352 553
        match = value.match(/^04(\d{2})(\d{3})(\d+)$/);
        if (match) {
            return `04${match[1]} ${match[2]} ${match[3]}`;
        }
        return value;
    }

    formatLandlinePhone(value) {
        if (!value) return '';

        // Handle (07)97956021 format - format as (07) 9795 6021
        let match = value.match(/^\(07\)(\d{4})(\d{4})$/);
        if (match) {
            return `(07) ${match[1]} ${match[2]}`;
        }

        // Handle 0797956021 format - format as (07) 9795 6021
        match = value.match(/^07(\d{4})(\d{4})$/);
        if (match) {
            return `(07) ${match[1]} ${match[2]}`;
        }

        // Handle 97956021 format (8 digits) - format as 9795 6021
        match = value.match(/^(\d{4})(\d{4})$/);
        if (match) {
            return `${match[1]} ${match[2]}`;
        }

        return value;
    }

    handleJobContactTypeChange(event) {
        if (event && event.target.value && (event.target.value === 'Person Of Interest' || event.target.value === 'POI Secondary')) {
            let existingPOIs = (JSON.parse(JSON.stringify(this.jobContacts)) || []).filter(jobContact => jobContact.animalos__Contact_Type__c === 'Person Of Interest' || jobContact.animalos__Contact_Type__c === 'POI Secondary');
            this.jobContact.animalos__Contact__r.LastName = 'POI ' + (existingPOIs.length + 1) + ' ' + new Date().toISOString().split('T')[0];
        }

        this.jobContact = this.handleFieldChange(this.jobContact, event);
    }

    handleJobContactNameChange(event) {
        if (event && event.target.value) {
            if (event.target.dataset.path === 'animalos__Contact__r.FirstName') {
                this.jobContact.animalos__Contact__r.FirstName = String(event.target.value).charAt(0).toUpperCase() + String(event.target.value).slice(1);
            }
            if (event.target.dataset.path === 'animalos__Contact__r.LastName') {
                this.jobContact.animalos__Contact__r.LastName = String(event.target.value).charAt(0).toUpperCase() + String(event.target.value).slice(1);
            }
        }
        this.jobContact = this.jobContact;
    }

    resetJobContactForm() {
        this.hideJobContactForm = true;
        Promise.resolve().then(() => this.hideJobContactForm = false);
    }

    resetAnimalReportForm() {
        this.hideAnimalReportForm = true;
        Promise.resolve().then(() => this.hideAnimalReportForm = false);
    }

    handleAnimalReportFieldChange(event) {
        this.animalReport = this.handleFieldChange(this.animalReport, event);
    }

    handleFieldChange(map, event) {
        let index = event.target.getAttribute('data-index');
        let path = event.target.getAttribute('data-path');
        let pathLogic = event.target.getAttribute('data-path-logic');
        let isCheckbox = event.target.type === 'toggle' || event.target.type === 'checkbox' || event.target.type === 'checkbox-button';
        let value = isCheckbox ? event.target.checked : event.target?.selectedValues || event.target?.value || event.detail?.value;
        if (pathLogic === 'not') {
            value = !value;
        }
        path = path.replaceAll('[data-index]', '[' + index + ']');
        return this.setMapValue(map, path, value);
    }

    formatState(state) {
        switch (state) {
            case 'New South Wales' :
                return 'NSW';
            case 'South Australia' :
                return 'SA';
            case 'Tasmania' :
                return 'TAS';
            case 'Victoria' :
                return 'VIC';
            case 'Western Australia' :
                return 'WA';
            case 'Northern Territory' :
                return 'NT';
            case 'Queensland' :
                return 'QLD';
            case 'Australian Capital Territory' :
                return 'ACT';
            default :
                return state;
        }
    }

    handleJobContactAddressChange(event) {
        this.jobContact.animalos__Contact__r.MailingStreet = event.target.street;
        this.jobContact.animalos__Contact__r.MailingCity = event.target.city;
        this.jobContact.animalos__Contact__r.MailingState = this.formatState(event.target.state);
        this.jobContact.animalos__Contact__r.MailingPostalCode = event.target.postCode;
        this.jobContact.animalos__Contact__r.MailingCountry = event.target.country === 'Australia' ? 'AU' : event.target.country;
    }

    handleJobContactAction(event) {
        let action = event.detail.action,
            index = event.detail.index,
            jobId = event.detail.jobId;

        if (action) {
            switch (action) {
                case 'delete':
                    this.jobContacts.splice(index, 1);
                    break;
                case 'edit':
                    this.jobContact = this.jobContacts[index];
                    this.jobContacts.splice(index, 1);
                    break;
                case 'editJob':
                    window.location.href = 'https://' + window.location.hostname + window.location.pathname + '?c__recordId=' + jobId;
                    break;
                case 'add_violence':
                    let existingInteractionCautions = this.jobContacts[index].animalos__Interaction_Cautions__r?.records || [];
                    let newInteractionCaution = event.detail.interactionCaution;
                    existingInteractionCautions.push(newInteractionCaution);
                    this.jobContacts[index].animalos__Interaction_Cautions__r = {};
                    this.jobContacts[index].animalos__Interaction_Cautions__r.records = existingInteractionCautions;
                    break;
                case 'contact_found':
                    this.jobContacts[index].animalos__Contact__r = event.detail.contact;
            }

            //reset form and table
            this.setAddress();
            this.resetJobContactForm();
        }
    }

    handleAnimalReportAction(event) {
        let action = event.detail.action,
            index = event.detail.index;

        if (action !== undefined && index !== undefined) {
            switch (action) {
                case 'delete':
                    this.animalReports.splice(index, 1);
                    break;
                case 'edit':
                    this.animalReport = this.animalReports[index];
                    this.animalReports.splice(index, 1);
                    break;
            }
            this.setJobCodes();
            //reset form and table
            this.resetAnimalReportForm();
        }
    }

    handleAddToCurrentJob(event) {
        let selectedJobContacts = event.detail.selectedJobContacts || [];
        let existingContactIds = (this.jobContacts || []).map(jobContact => jobContact.animalos__Contact__r.Id);
        //exclude contacts that are already in the list and remove Ids for others
        selectedJobContacts = (selectedJobContacts
            .filter(jobContact => {
                let newId = existingContactIds.findIndex(existingId => existingId === jobContact.animalos__Contact__r.Id) === -1;
                if (newId) {
                    existingContactIds.push(jobContact.animalos__Contact__r.Id);
                }
                return newId;
            }) || [])
            .map(jobContact => {
                delete jobContact.Id;
                return JSON.parse(JSON.stringify(jobContact));
            });

        if (selectedJobContacts.length === 0) {
            showToast(this, 'Info', 'Selected Contacts are already added', 'info');
        } else {
            this.jobContacts = this.jobContacts.concat(selectedJobContacts);
            showToast(this, 'Success', selectedJobContacts.length + ' Contact(s) were added', 'success');
            this.setAddress();
        }
    }

    setAddress() {
        let existingPOI = (this.jobContacts || []).find(jobContact => jobContact.animalos__Contact_Type__c === 'Person Of Interest' || jobContact.animalos__Contact_Type__c === 'POI Secondary');
        let POIStreet = existingPOI?.animalos__Contact__r?.MailingStreet;
        let existingStreet = this.refs.locationOfInterestCmp.locationOfInterest.animalos__Address__Street__s;
        if (existingPOI && POIStreet && !existingStreet) {
            this.refs.locationOfInterestCmp.setAddress({
                'street': existingPOI.animalos__Contact__r.MailingStreet,
                'city': existingPOI.animalos__Contact__r.MailingCity,
                'state': this.formatState(existingPOI.animalos__Contact__r.MailingState),
                'postCode': existingPOI.animalos__Contact__r.MailingPostalCode,
                'country': existingPOI.animalos__Contact__r.MailingCountry === 'Australia' ? 'AU' : existingPOI.animalos__Contact__r.MailingCountry
            });
        }
    }

    setJobCodes() {

        let animalReports = JSON.parse(JSON.stringify(this.animalReports)) || [];
        let selectedTypes = [
            ...animalReports.map(report => report.animalos__Cruelty_Type__c),
            ...animalReports.map(report => report.aos_Rescue_Type__c)
        ],
        jobCodes = new Set(this.job.animalos__Codes__c?.split(';') || []);

        selectedTypes = selectedTypes.filter(type => type !== undefined && type !== null && type !== '');
        jobCodes = new Set([...jobCodes].filter(code => code !== undefined && code !== null && code !== ''));

        if (selectedTypes) {
            selectedTypes.forEach((selectedType => {
                if (selectedType) {
                    let type = selectedType.split(';');
                    type.forEach(typeVar => {
                        let correspondingCodes = this.crueltyTypeCodesMap.get(typeVar);
                        if (correspondingCodes) {
                            correspondingCodes.forEach(code => {
                                jobCodes.add(code);
                            });
                        }

                        let code = this.jobCodesOptions.find(option => option.value === typeVar);
                        if (code) {
                            jobCodes.add(code.value);
                        }
                    });
                }
            }));
        }

        this.job.animalos__Codes__c = [...jobCodes].join(';');
        this.resetCaseForm();
    }

    resetCaseForm() {
        this.hideCaseForm = true;
        Promise.resolve().then(() => {
            this.hideCaseForm = false;
        });
    }

    get isPOI() {
        return this.jobContact.animalos__Contact_Type__c === 'Person Of Interest' || this.jobContact.animalos__Contact_Type__c === 'POI Secondary';
    }

    get showProgressIndicator() {
        return this.isSubmit !== true;
    }

    get isButtonDisabled() {
        return this.isBusy === true || this.isSubmit === true;
    }

    get caseHasId() {
        return this.caseVar?.Id !== undefined;
    }

    get caseUrlLabel() {
        return this.caseVar?.CaseNumber + ' - Key Information';
    }

    get caseUrl() {
        return location.hostname + '/' + this.caseVar?.Id;
    }

    get showLocationOfInterest() {
        return this.isBusy === false;
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

    get jobStatusOptions() {
        return this.job.RecordTypeId
                ? (
                    this.isInspectorateRecordType
                    ? this.inspectorateStatusOptions
                    : this.isWildlifeHubRecordType
                        ? this.wildlifeHubStatusOptions
                        : this.rescueStatusOptions
                ) || this.selectOptions.animalosStatusOptions
                : this.selectOptions.animalosStatusOptions;
    }

    get jobPriorityOptions() {
        return this.job.RecordTypeId
                ? (
                    this.isInspectorateRecordType
                    ? this.inspectoratePriorityOptions : this.isWildlifeHubRecordType
                        ? this.wildlifeHubPriorityOptions
                        : this.rescuePriorityOptions
                ) || this.selectOptions.animalosPriorityOptions
                : this.selectOptions.animalosStatusOptions;
    }

    get jobCodesOptions() {
        return this.job.RecordTypeId
                ? (
                    this.isInspectorateRecordType
                    ? this.inspectorateCodesOptions
                    : this.isWildlifeHubRecordType
                        ? this.wildlifeHubCodesOptions
                        : this.rescueCodesOptions
                ) || this.selectOptions.animalosCodesOptions
                : this.selectOptions.animalosCodesOptions;
    }

    get isDomestic() {
        return this.animalReport.aos_Animal_Class__c === 'Domestic';
    }

    get showJobContactForm() {
        return this.hideJobContactForm !== true;
    }

    get isIdNumberInputDisabled() {
        return this.isJobContactSearching === true || !this.jobContact.animalos__Contact__r?.ID_Type__c;
    }

    get showAnimalReportForm() {
        return this.hideAnimalReportForm !== true;
    }

    get showCaseForm() {
        return this.hideCaseForm !== true;
    }

    get showContacts() {
        return this.jobContacts.length > 0;
    }

    get showAnimalReports() {
        return this.animalReports.length > 0;
    }

    get animalBreedFilter() {
        return this.animalReport.animalos__Animal_Type__c ? 'animalos__Type__c INCLUDES (\'' + this.animalReport.animalos__Animal_Type__c + '\')' : ''
    }

    get abandonedCrueltyType() {
        return this.animalReport.animalos__Cruelty_Type__c?.includes('Abandoned or left unattended exceeding 24 hrs');
    }

    get illTreatmentCrueltyType() {
        return this.animalReport.animalos__Cruelty_Type__c?.includes('Ill-treatment (direct physical abuse)');
    }

    get veterinaryTreatmentCrueltyType() {
        return this.animalReport.animalos__Cruelty_Type__c?.includes('In need of Veterinary Treatment');
    }

    get insufficientFoodAndWaterCrueltyType() {
        return this.animalReport.animalos__Cruelty_Type__c?.includes('Insufficient Food and Water');
    }

    get shelterConditionsCrueltyType() {
        return this.animalReport.animalos__Cruelty_Type__c?.includes('Shelter & Living Conditions');
    }

    get tiedCrueltyType() {
        return this.animalReport.animalos__Cruelty_Type__c?.includes('Tied continuously or locked in a small pen/cage');
    }

    get showPastIncidentDetails() {
        return this.animalReport.aos_Past_incidents__c === 'Yes';
    }

    get showInjuryDetails() {
        return this.animalReport.aos_Animal_is_injured__c === 'Yes';
    }

    get showOtherBehaviour() {
        return this.animalReport.aos_Energy_activity_behaviour__c === 'Other';
    }

    get showHistoryDescription() {
        return this.animalReport.aos_Has_history__c === 'Yes';
    }

    get showOtherTetherType() {
        return this.animalReport.aos_Tether_type__c === 'Other';
    }

    get otherTetherConfinementReason() {
        return this.animalReport.aos_Reason_for_tether_confinement__c === 'Other - please specify';
    }

    get showInformationOnPersonOfProperty() {
        return this.animalReport.aos_Responsible_person_of_property__c === 'Yes' || this.animalReport.aos_Responsible_person_of_property__c === 'No';
    }

    get showAnimalLocationComments() {
        return this.animalReport.aos_Animal_location__c === 'Other';
    }

    get showOtherTypeOfShelter() {
        return this.animalReport.aos_Type_of_shelter__c === 'Other';
    }

    get jobContactFormDisabled() {
        return this.isBusy === true || this.isJobContactSearching === true;
    }

    get isRescueRecordType() {
        return this.job.RecordTypeId && this.job.RecordTypeId === (this.selectOptions.recordTypeOptions || []).find(option => option.label === 'Rescue')?.value;
    }

    get isInspectorateRecordType() {
        return this.job.RecordTypeId && this.job.RecordTypeId === (this.selectOptions.recordTypeOptions || []).find(option => option.label === 'Inspectorate')?.value;
    }

    get isWildlifeHubRecordType() {
        return this.job.RecordTypeId && this.job.RecordTypeId === (this.selectOptions.recordTypeOptions || []).find(option => option.label === 'Wildlife Hub')?.value;
    }

    get isAnimalAtHeight() {
        return this.animalReport.aos_Rescue_Type__c?.includes('Animal at Height');
    }

    get isOtherCauseOfAffliction() {
        return this.animalReport.aos_Cause_of_Affliction__c === 'Other';
    }

    //STEPPER
    @track currentStep = 'callerInformation';

    @track steps = [
        {name: 'callerInformation', label: 'Caller Information'},
        {name: 'animalReports', label: 'Animal Report'},
        {name: 'jobDetails', label: 'Job Summary'}
    ];

    nextClick(event) {
        let currentIndex = this.steps.findIndex(step => step.name === this.currentStep);

        this.currentStep = this.steps[currentIndex + 1].name;
        this.scrollTop();
    }

    previousClick(event) {
        let currentIndex = this.steps.findIndex(step => step.name === this.currentStep);
        this.currentStep = this.steps[currentIndex - 1].name;
        this.scrollTop();
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
        return this.currentStep === 'jobDetails';
    }

    get notLastStep() {
        return this.currentStep !== 'jobDetails';
    }

    get notFirstStep() {
        return this.currentStep !== 'callerInformation';
    }

    get showCallerDetailsStep() {
        return this.currentStep === 'callerInformation';
    }

    get showAnimalReportsStep() {
        return this.currentStep === 'animalReports';
    }

    get showJobDetailsStep() {
        return this.currentStep === 'jobDetails';
    }
}