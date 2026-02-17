import {api, LightningElement, track} from 'lwc';
import {execute, showToast, handleFieldChange, validate} from "c/aosUtils";

export default class PartnersUserSetup extends LightningElement {

    @api
    recordId;
    @track
    isBusy = false;
    selectOptions = {};
    hideLocationVolunteerForm = false;

    contact = {};
    @track
    user = {};
    locationVolunteer = {};
    locationVolunteers = [];
    fosterLocation = {};

    doesCommunityExist;

    async connectedCallback() {
        await this.refresh();
    }

    async handleFieldChange(event) {
        let dataMap = event.target.dataset.map;
        handleFieldChange(this[dataMap], event);

        switch (dataMap) {
            case 'locationVolunteer':
                await this.handleLocationVolunteerFieldChange(event);
                break;
            case 'user':
                this.handleUserFieldChange(event);
                break;
        }
    }

    handleUserFieldChange(event) {
        let path = event.target.dataset.path;

        switch (path) {
            case 'ProfileId':
                let profile = this.selectOptions.profileOptions.find(profile => profile.value === this.user.ProfileId);
                this.user.Profile = {
                    Name: profile.label
                };
                break;
        }
    }

    async handleLocationVolunteerFieldChange(event) {
        let path = event.target.dataset.path;

        switch (path) {
            case 'site':
                this.locationVolunteer.aos_Location__c = event.detail.value;
                this.locationVolunteer.block = null;
                this.locationVolunteer.unit = null;
                await this.resetLocationVolunteerForm();
                break;
            case 'block':
                this.locationVolunteer.aos_Location__c = event.detail.value;
                this.locationVolunteer.unit = null;
                await this.resetLocationVolunteerForm();
                break;
            case 'unit':
                this.locationVolunteer.aos_Location__c = event.detail.value;
                break;
        }
    }

    async handleActivateUserClick() {
        let userForm = this.refs.userForm,
            locationVolunteerForm = this.refs.locationVolunteerForm,
            userFormValidateResult,
            locationVolunteerFormValidateResult;


        if (userForm) {
            userFormValidateResult = validate(userForm, {});
        }

        if (locationVolunteerForm && this.isFosterProfile && !this.user.Id) {
            locationVolunteerFormValidateResult = validate(locationVolunteerForm, {});
        }

        if ((userFormValidateResult && userFormValidateResult?.allValid !== true) || (locationVolunteerFormValidateResult && locationVolunteerFormValidateResult?.allValid !== true)) {
            showToast(this, 'Error', 'Populate all required fields', 'error');
            return;
        }

        this.isBusy = true;

        try {
            await execute(
                'aos_PartnersUserSetupActivateUserProc',
                {
                    recordId: this.recordId,
                    user: this.user
                }
            );

            if (this.isFosterProfile && !this.userExists) {
                await execute(
                    'aos_PartnersUserSetupAddLVProc',
                    {
                        recordId: this.recordId,
                        location: this.fosterLocation
                    }
                );
                this.fosterLocation = {};
            }

            await this.refresh();
            await this.resetLocationVolunteerForm();
            showToast(this, 'Success', 'User activated successfully', 'success');
        } catch (errors) {
            this.isBusy = false;
            showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error');
        }
        this.isBusy = false;
    }

    async handleDeactivateUserClick() {
        this.isBusy = true;

        try {
            await execute(
                'aos_PartnersUserSetupDeactivateUserProc',
                {
                    recordId: this.recordId
                }
            );

            await this.refresh();
            showToast(this, 'Success', 'User deactivated successfully', 'success');
        } catch (errors) {
            this.isBusy = false;
            showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error');
        }
        this.isBusy = false;
    }


    async refresh() {
        this.isBusy = true;
        try {
            const response = await execute(
                'aos_PartnersUserSetupMetaProc',
                {
                    recordId: this.recordId
                }
            );

            this.contact = response.dto.contact || {};
            this.user = response.dto.user || {};
            this.locationVolunteers = response.dto.locationVolunteers || [];
            this.doesCommunityExist = response.dto.doesCommunityExist || false;
            this.selectOptions = response.selectOptions || {};
            this.locationVolunteer = {
                aos_Volunteer__c: this.contact.Id,
                aos_Status__c: !this.user.Id || this.contact.IsActive ? 'Active' : 'Inactive'
            };
        } catch (errors) {
            this.isBusy = false;
            showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error');
        }
        this.isBusy = false;
    }

    async handleLocationVolunteerAction(event) {
        let action = event.detail.action,
            index = event.detail.index,
            locationVolunteer = this.locationVolunteers[index];

        locationVolunteer.aos_Status__c = action === 'activate' ? 'Active' : 'Inactive';

        this.isBusy = true;
        try {
            const response = await execute(
                'aos_DMLProc',
                {
                    sObjectType: 'aos_Location_Volunteer__c',
                    upsert: [locationVolunteer]
                });

            showToast(this, 'Success', `Location Volunteer ${action === 'activate' ? 'activated' : 'deactivated'} successfully`, 'success');
        } catch (errors) {
            this.isBusy = false;
            showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error');
        }
        this.isBusy = false;
    }

    async handleAddLocationVolunteerClick() {

        let locationVolunteerForm = this.refs.locationVolunteerForm;

        if (locationVolunteerForm) {
            let validateResult = validate(locationVolunteerForm, {});
            if (validateResult.allValid !== true) {
                showToast(this, 'Error', 'Populate all required fields', 'error');
                return;
            }
        }


        this.isBusy = true;

        try {
            this.locationVolunteer.aos_Volunteer__c = this.recordId;
            this.locationVolunteer.aos_Status__c = 'Active';

            let request,
                processor;

            if (this.isFosterProfile) {
                processor = 'aos_PartnersUserSetupAddLVProc';
                request = {
                    recordId: this.recordId,
                    location: this.fosterLocation
                }
            } else {
                processor = 'aos_DMLProc';
                request = {
                    upsert: [this.locationVolunteer],
                    sObjectType: 'aos_Location_Volunteer__c'
                };
            }

            await execute(
                processor,
                request
            );

            this.fosterLocation = {};

            showToast(this, 'Success', 'Location volunteer added successfully', 'success');
            await this.refresh();
            await this.resetLocationVolunteerForm();
        } catch (errors) {
            this.isBusy = false;
            showToast(this, 'Error', Array.isArray(errors) ? errors[0].message : errors.message, 'error');
        }

        this.isBusy = false;
    }

    async resetLocationVolunteerForm() {
        this.hideLocationVolunteerForm = true;
        await Promise.resolve();
        this.hideLocationVolunteerForm = false;
    }

    get isFosterProfile() {
        return this.user.Profile?.Name?.startsWith('Foster');
    }

    get isPartnersProfile() {
        return this.user.Profile?.Name?.startsWith('Partners');
    }

    get locationIds() {
        return this.locationVolunteers.map(locationVolunteer => locationVolunteer.aos_Location__c);
    }

    get parentBlockIds() {
        return this.locationVolunteers.map(locationVolunteer => locationVolunteer.aos_Location__r?.animalos__Parent_Block__c);
    }

    get offsiteLocationFilter() {
        return 'RecordType.DeveloperName = \'Offsite\' AND animalos__Active__c = TRUE' + (this.locationVolunteers.length > 0 ? ` AND Id NOT IN ('${this.locationIds.join('\', \'')}')` : '');
    }

    get siteLocationFilter() {
        return 'RecordType.DeveloperName = \'Site\'' + (this.locationVolunteers.length > 0 ? ` AND Id NOT IN ('${this.locationIds.join('\', \'')}')` : '');
    }

    get blockLocationFilter() {
        return `RecordType.DeveloperName = 'Block' AND animalos__Parent_Block__c = '${this.locationVolunteer.site}'` + (this.locationVolunteers.length > 0 ? ` AND Id NOT IN ('${this.locationIds.join('\', \'')}')` : '');
    }

    get unitLocationFilter() {
        return `RecordType.DeveloperName = 'Unit' AND animalos__Parent_Block__c = '${this.locationVolunteer.block}'` + (this.locationVolunteers.length > 0 ? ` AND Id NOT IN ('${this.locationIds.join('\', \'')}')` : '');
    }

    get fosterFilter() {
        return `(RecordType.DeveloperName = 'Site' OR RecordType.DeveloperName = 'Offsite')` + (this.parentBlockIds.length > 0 ? ` AND Id NOT IN ('${this.parentBlockIds.join('\', \'')}')` : '');
    }

    get isVolunteerProfile() {
        return this.user.Profile?.Name?.startsWith('Volunteer');
    }

    get showLocationVolunteers() {
        return this.userExists && this.locationVolunteers.length > 0;
    }

    get userExists() {
        return this.user.Id !== null && this.user.Id !== undefined;
    }

    get userDoesNotExist() {
        return !this.user.Id;
    }

    get isPOI() {
        return this.contact.animalos__POI_Flag__c === true;
    }

    get title() {
        return `Partners User Setup for: ${this.contact.Name}`;
    }

    get deactivateUserButtonLabel() {
        return `Deactivate ${this.user.Profile?.Name} User`;
    }

    get activateUserButtonLabel() {
        return `${this.user.Id === undefined ? 'Activate' : 'Reactivate'} User`;
    }

    get showActiveButton() {
        return (this.user.Id === undefined && !this.isPOI) || this.user.IsActive === false;
    }

    get showDeactivateButton() {
        return this.user.Id && this.user.IsActive === true;
    }

    get showLocationVolunteerForm() {
        return (this.user.IsActive === true && this.hideLocationVolunteerForm === false) || (this.isFosterProfile && this.hideLocationVolunteerForm === false && (!this.user.Id || this.user.IsActive));
    }

    get showAddLocationVolunteerButton() {
        return this.user.Id !== undefined;
    }
}