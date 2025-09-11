import {api, track, LightningElement} from 'lwc';
import {execute, showToast} from 'c/verticUtils';

export default class ResourcesNearby extends LightningElement {
    @api recordId;
    @api cardTitle = 'Rescue Resources Nearby';
    @api distance = '0.05';
    @track selectedSkills = '';
    @track resources = [];
    @track skillsOptions = [];

    isBusy = false;
    distanceOptions = [
        {label: '50 metres', value: '0.05'},
        {label: '100 metres', value: '0.1'},
        {label: '200 metres', value: '0.2'},
        {label: '500 metres', value: '0.5'},
        {label: '1 kilometre', value: '1'},
        {label: '5 kilometre', value: '5'},
        {label: '10 kilometre', value: '10'},
        {label: '20 kilometre', value: '20'},
        {label: '50 kilometre', value: '50'}
    ];

    connectedCallback() {
        this.refresh();
    }

    @api
    refresh() {
        this.isBusy = true;
        return execute('ResourcesNearbyMetaProc', {
            recordId: this.recordId,
            distance: this.distance,
            selectedSkills: this.selectedSkills
        })
            .then(response => {
                this.resources = response.dto.resources || [];
                this.skillsOptions = response.selectOptions.skillsOptions || [];
            })
            .catch(ex => {
                showToast(this, 'Error', Array.isArray(ex) ? ex[0].message : ex.message || ex.body.message, 'error');
            })
            .finally(() => {
                this.isBusy = false;
            })
    }

    get showContent() {
        return this.isBusy === false;
    }

    get showResourcesTable() {
        return this.resources && this.resources.length > 0;
    }

    get uniqueKey() {
        return `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
    }

    get distanceLabel() {
        return this.distanceOptions.find(option => option.value === this.distance)?.label || '';
    }

    handleDistanceChange(event) {
        this.distance = event.target.value;
        this.refresh();
    }

    handleSkillsChange(event) {
        this.selectedSkills = event.target.value;
        this.refresh();
    }

    handleRefreshClick(event) {
        this.refresh();
    }
}


