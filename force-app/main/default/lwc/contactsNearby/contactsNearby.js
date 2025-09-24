import {api, track, LightningElement} from 'lwc';
import {execute, showToast} from 'c/verticUtils';

export default class ContactsNearby extends LightningElement {
    @api recordId;
    @api cardTitle = 'Contacts Nearby';
    @api distance = '0.05';
    jobVar;
    mapMarkers = [];
    contacts = [];
    isBusy = false;
    isSearch = false;
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
    limit = 0;
    hasMore = false;

    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
    }

    connectedCallback() {
        this.isBusy = true;
        this.search();
    }

    @api
    async search() {
        if (this.recordId) {
            try {
                let response = await execute('ContactsNearbyMetaProc', {
                    recordId: this.recordId,
                    distance: this.distance,
                    filters: this.refs?.filters?.filters
                });
                this.contacts = response.dto.contacts.records || [];
                this.limit = response.dto.contacts.limit || 0;
                this.hasMore = response.dto.contacts.hasMore || false;
                this.jobVar = response.dto.jobVar;
                this.initMapMarkers();
            } catch (ex) {
                showToast(this, 'Error', Array.isArray(ex) ? ex[0].message : ex.message || ex.body.message, 'error');
            } finally {
                this.isBusy = false;
                this.isSearch = false;
            }
        }
    }

    get searchCardTitle() {
        return 'Search Results ' + (this.hasMore === true ? ' (showing first ' + this.limit + ')' : '');
    }

    get showContent() {
        return this.isBusy === false;
    }

    get showContactsTable() {
        return this.contacts && this.contacts.length > 0;
    }

    get uniqueKey() {
        return `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
    }

    get distanceLabel() {
        return this.distanceOptions.find(option => option.value === this.distance)?.label || '';
    }

    get showMap() {
        return this.isBusy === false && this.isSubmit === false && this.contacts !== undefined && this.contacts.length && this.contacts.length > 0 && this.mapMarkers && this.mapMarkers.length > 0;
    }

    handleDistanceChange(event) {
        this.distance = event.target.value;
        this.refresh();
    }

    initMapMarkers() {
        //reset markers
        this.mapMarkers = [];
        //add job marker
        this.mapMarkers.push({
            location: {
                City: this.jobVar.animalos__Address__City__s,
                Country: this.jobVar.animalos__Address__CountryCode__s,
                PostalCode: this.jobVar.animalos__Address__PostalCode__s,
                State: this.jobVar.animalos__Address__StateCode__s,
                Street: this.jobVar.animalos__Address__Street__s
            },
            value: 'JOBMARKER',
            icon: 'standard:job_profile',
            title: this.jobVar.Name,
            description: this.jobVar.animalos__Description__c,
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

        this.contacts.forEach(contact => {
            let contactDescription = '';
            if (contact.MobilePhone) {
                contactDescription += 'Mobile: ' + contact.MobilePhone + '\n';
            }
            if (contact.Phone) {
                contactDescription += 'Phone: ' + contact.Phone + '\n';
            }
            if (contact.Email) {
                contactDescription += 'Email: ' + contact.Email + '\n';
            }
            if (contact.Account?.Name) {
                contactDescription += 'Organisation: ' + contact.Account.Name + '\n';
            }
            if (contactDescription.endsWith('\n')) {
                contactDescription = contactDescription.slice(0, -1);
            }

            this.mapMarkers.push({
                location: {
                    City: contact.MailingCity,
                    Country: contact.MailingCountry,
                    PostalCode: contact.MailingPostalCode,
                    State: contact.MailingState,
                    Street: contact.MailingStreet
                },
                value: 'CONTACT' + contact.Id,
                icon: 'standard:contact',
                title: contact.Name,
                description: contactDescription
            });
        });
    }

    handleSearchClick(event) {
        this.isSearch = true;
        this.search();
    }
}