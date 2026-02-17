import {api, track, LightningElement} from 'lwc';
import {execute, showToast} from 'c/verticUtils';

export default class LocationsNearby extends LightningElement {
    @api recordId;
    @api cardTitle = 'Jobs Nearby';
    @api job = {};
    @api view = 'locationsNearby';
    @api distance = '0.05';
    @track locationsNearby = [];

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
        return execute('aos_LocationsNearbyMetaProc', {
            recordId: this.recordId,
            distance: this.distance,
            job: this.job
        })
            .then(response => {
                this.locationsNearby = response.dto.locationsNearby;
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

    get showLocationsNearby() {
        return this.locationsNearby.length > 0;
    }

    handleDistanceChange(event) {
        this.distance = event.target.value;
        this.refresh();
    }

    handleRefreshClick(event) {
        this.refresh();
    }
}