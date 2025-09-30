import {LightningElement, api} from 'lwc';
import {execute, showToast} from 'c/verticUtils';

export default class TrapsMap extends LightningElement {
    jobActivities = [];
    mapMarkers = [];
    isBusy = false;
    selectedMarkerValue;
    zoomLevel = 10;

    defaultLocation = {
        City: 'Brisbane',
        Country: 'AU',
        State: 'QLD'
    };

    mapCenter = {
        location: this.defaultLocation
    };

    connectedCallback() {
        this.refresh();
    }

    async refresh() {
        this.isBusy = true;
        try {
            let response = await execute('TrapsMapMetaProc', {});
            this.jobActivities = response.dto.jobActivities || [];
            this.initMapMarkers();
            this.mapCenter.location = this.defaultLocation;
            this.zoomLevel = 10;
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

    handleListItemClick(event) {
        const id = event.currentTarget?.dataset?.id;
        if (!id) { return; }
        this.selectedMarkerValue = 'JOBACTIVITY' + id;
        const found = this.mapMarkers.find(m => m.value === this.selectedMarkerValue);
        if (found) {
            this.mapCenter = { location: { ...found.location } };
            this.zoomLevel = 13;
        }
    }

    handleOpenRecordClick(event) {
        event.stopPropagation();
        const id = event.currentTarget?.dataset?.id;
        if (id) {
            const url = `${location.origin}/${id}`;
            window.open(url, '_blank');
        }
    }
}