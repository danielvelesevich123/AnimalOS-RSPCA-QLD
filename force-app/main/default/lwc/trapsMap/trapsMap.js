import {LightningElement} from 'lwc';
import {execute, showToast} from 'c/verticUtils';

export default class TrapsMap extends LightningElement {
    jobActivities = [];
    mapMarkers = [];
    isBusy = false;
    selectedMarkerValue;

    connectedCallback() {
        this.refresh();
    }

    async refresh() {
        this.isBusy = true;
        try {
            let response = await execute('TrapsMapMetaProc', {});
            this.jobActivities = response.dto.jobActivities || [];
            this.initMapMarkers();
        } catch (ex) {
            showToast(this, 'Error', Array.isArray(ex) ? ex[0].message : ex.message || ex.body.message, 'error');
        } finally {
            this.isBusy = false;
        }
    }

    get showMap() {
        return this.isBusy === false && this.jobActivities !== undefined && this.jobActivities.length && this.jobActivities.length > 0 && this.mapMarkers && this.mapMarkers.length > 0;
    }

    initMapMarkers() {
        this.mapMarkers = [];
        this.jobActivities.forEach(jobActivity => {
            this.mapMarkers.push({
                location: {
                    City: jobActivity.animalos__Address__City__s,
                    Country: jobActivity.animalos__Address__CountryCode__s,
                    PostalCode: jobActivity.animalos__Address__PostalCode__s,
                    State: jobActivity.animalos__Address__StateCode__s,
                    Street: jobActivity.animalos__Address__Street__s
                },
                value: 'JOBACTIVITY' + jobActivity.Id,
                icon: 'utility:anchor',
                title: jobActivity.Name + ' - ' + jobActivity.animalos__Job__r.Name + ' - ' + jobActivity.Days_in_Field__c,
                description: 'Job Name: ' + jobActivity.animalos__Job__r.Name + '\n' + 'Days in Field: ' + jobActivity.Days_in_Field__c
            });
        });
    }

    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
    }
}