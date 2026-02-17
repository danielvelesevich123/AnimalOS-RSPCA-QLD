import {api, LightningElement} from 'lwc';
import {execute, showToast} from 'c/verticUtils';

export default class AnimalsNearby extends LightningElement {
    @api recordId;
    @api cardTitle = 'Animals Nearby';
    @api distance = '0.05';
    @api animalStatusFilter = '';
    jobs = [];
    jobStatusOptions = [];
    mapMarkers = [];
    currentJob = {};

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

    selectedMarkerValue = 'JOBMARKER';

    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
    }

    connectedCallback() {
        this.refresh();
    }

    @api
    async refresh() {
        this.isBusy = true;
        try {
            let response = await execute('aos_AnimalsNearbyMetaProc', {
                recordId: this.recordId,
                distance: this.distance,
                animalStatusFilter: this.animalStatusFilter
            });
            this.jobs = response.dto.jobs || [];
            this.jobStatusOptions = response.selectOptions.jobStatusOptions || [];
            this.currentJob = response.dto.currentJob || {};
            this.initMapMarkers();
        } catch (ex) {
            showToast(this, 'Error', Array.isArray(ex) ? ex[0].message : ex.message || ex.body.message, 'error');
        } finally {
            this.isBusy = false;
        }
    }

    get showContent() {
        return this.isBusy === false;
    }

    get showJobsTable() {
        return this.jobs && this.jobs.length > 0;
    }

    get uniqueKey() {
        return `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
    }

    get containerClass() {
        return 'slds-scrollable slds-m-top_small' + (this.showJobsTable && this.jobs.length > 2 ? ' cards-container-height' : '');
    }

    get showMap() {
        return this.isBusy === false && this.jobs !== undefined && this.jobs.length && this.jobs.length > 0 && this.mapMarkers && this.mapMarkers.length > 0;
    }

    handleDistanceChange(event) {
        this.distance = event.target.value;
        this.refresh();
    }

    handleRefreshClick(event) {
        this.refresh();
    }

    initMapMarkers() {
        //reset markers
        this.mapMarkers = [];
        //add job marker
        this.mapMarkers.push({
            location: {
                City: this.currentJob.animalos__Address__City__s,
                Country: this.currentJob.animalos__Address__CountryCode__s,
                PostalCode: this.currentJob.animalos__Address__PostalCode__s,
                State: this.currentJob.animalos__Address__StateCode__s,
                Street: this.currentJob.animalos__Address__Street__s
            },
            value: 'JOBMARKER',
            icon: 'standard:location',
            title: this.currentJob.Name,
            description: this.currentJob.animalos__Description__c,
            mapIcon: {
                path: "M-1.547 12l6.563-6.609-1.406-1.406-5.156 5.203-2.063-2.109-1.406 1.406zM0 0q2.906 0 4.945 2.039t2.039 4.945q0 1.453-0.727 3.328t-1.758 3.516-2.039 3.070-1.711 2.273l-0.75 0.797q-0.281-0.328-0.75-0.867t-1.688-2.156-2.133-3.141-1.664-3.445-0.75-3.375q0-2.906 2.039-4.945t4.945-2.039z",
                fillColor: "blue",
                fillOpacity: 0.9,
                strokeWeight: 0,
                rotation: 0,
                scale: 2,
                anchor: {x: 0, y: 20}
            }
        });

        this.jobs.forEach(job => {
            this.mapMarkers.push({
                location: {
                    City: job.animalos__Address__City__s,
                    Country: job.animalos__Address__CountryCode__s,
                    PostalCode: job.animalos__Address__PostalCode__s,
                    State: job.animalos__Address__StateCode__s,
                    Street: job.animalos__Address__Street__s
                },
                value: 'JOB' + job.Id,
                icon: 'standard:job_profile',
                title: job.Name,
                description: job.animalos__Description__c
            });
        });
    }
}