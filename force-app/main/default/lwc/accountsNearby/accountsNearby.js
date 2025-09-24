import {api, LightningElement} from 'lwc';
import {execute, showToast} from 'c/verticUtils';

export default class AccountsNearby extends LightningElement {
    @api recordId;
    @api cardTitle = 'Search Accounts';
    @api distance = '0.05';
    jobVar;
    mapMarkers = [];
    accounts = [];
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
                let response = await execute('AccountsNearbyMetaProc', {
                    recordId: this.recordId,
                    distance: this.distance,
                    filters: this.refs?.filters?.filters
                });
                this.accounts = response.dto.accounts.records || [];
                this.limit = response.dto.accounts.limit || 0;
                this.hasMore = response.dto.accounts.hasMore || false;
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

    get showAccountsTable() {
        return this.accounts && this.accounts.length > 0;
    }

    get uniqueKey() {
        return `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
    }

    get distanceLabel() {
        return this.distanceOptions.find(option => option.value === this.distance)?.label || '';
    }

    get showMap() {
        return this.isBusy === false && this.isSubmit === false && this.accounts !== undefined && this.accounts.length && this.accounts.length > 0 && this.mapMarkers && this.mapMarkers.length > 0;
    }

    handleDistanceChange(event) {
        this.distance = event.target.value;
        this.isSearch = true;
        this.search();
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

        this.accounts.forEach(account => {
            let accountDescription = '';
            if (account.Phone) {
                accountDescription += 'Phone: ' + account.Phone + '\n';
            }
            if (account.Email__c) {
                accountDescription += 'Email: ' + account.Email__c + '\n';
            }
            if (accountDescription.endsWith('\n')) {
                accountDescription = accountDescription.slice(0, -1);
            }

            if(account.ShippingStreet) {
                this.mapMarkers.push({
                    location: {
                        City: account.ShippingCity,
                        Country: account.ShippingCountry,
                        PostalCode: account.ShippingPostalCode,
                        State: account.ShippingState,
                        Street: account.ShippingStreet
                    },
                    value: 'ACCOUNT1' + account.Id,
                    icon: 'standard:contact',
                    title: account.Name,
                    description: accountDescription
                });
            }

            if(account.BillingStreet) {
                this.mapMarkers.push({
                    location: {
                        City: account.BillingCity,
                        Country: account.BillingCountry,
                        PostalCode: account.BillingPostalCode,
                        State: account.BillingState,
                        Street: account.BillingStreet
                    },
                    value: 'ACCOUNT2' + account.Id,
                    icon: 'standard:contact',
                    title: account.Name,
                    description: accountDescription
                });
            }
        });
    }

    handleSearchClick(event) {
        this.isSearch = true;
        this.search();
    }
}