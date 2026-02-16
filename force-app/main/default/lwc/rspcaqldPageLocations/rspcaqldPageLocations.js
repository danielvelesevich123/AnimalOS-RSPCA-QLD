import {LightningElement, wire, track, api} from 'lwc';
import {CurrentPageReference} from "lightning/navigation";
import * as constants from 'c/constants';

export default class RspcaqldPageCommonMisconceptions extends LightningElement {
    map;
    markers = [];
    locations;
    orderOption = 'name';
    orderDirection = 'asc';
    currentPage = 1;
    pageCount = 1;
    searchFilter;
    serviceFilter = '';
    withinFilter = 'Up to 20km; 21-30km; 31-50km; 51-70km; 71km+';
    postcodeFilter;
    defaultPostcode;
    coords;
    mapId;
    iframeSrc;
    iframeLoaded = false;
    isReset = false;
    viewCount = 0;
    allCount = 0;
    isFilterFound = true;
    isGeolocationShared = false;
    googleApiKey;

    closeDark = constants.closeDark;

    @wire(CurrentPageReference)
    pageReference({state}) {
        if (state && state.service) {
            this.serviceFilter = state.service == 'adoption' ? 'Adoption; Cat Adoption'
                : state.service.charAt(0).toUpperCase() + state.service.slice(1);
        }
    }

    serviceOptions = { data: [] };
    orderOptions = [
        { label: 'distance', value: 'distance' },
        { label: 'name', value: 'name' }
    ];

    get filteredCards() {
        if (this.orderOption == 'name') {
            return this.sortCards('name');
        }

        if (this.orderOption == 'distance') {
            return this.sortCards('distance');
        }

        return this.locations;
    }

    sortCards(fieldName) {
        let cards = [];
        let fieldSet = [];
        for (let i = 0; i < this.locations.length; i++) {
            fieldSet.push(this.locations[i][fieldName]);
        }

        fieldSet = fieldName == 'distance' ? [...new Set(fieldSet.sort((a,b)=>a -b))] : [...new Set(fieldSet)].sort();

        if (this.orderDirection == 'asc') {
            for (let i = 0; i < fieldSet.length; i++) {
                for (let j = 0; j < this.locations.length; j++) {
                    if (this.locations[j][fieldName] === fieldSet[i]) {
                        cards.push(this.locations[j]);
                    }
                }
            }
        } else {
            for (let i = (fieldSet.length - 1); i >= 0; i--) {
                for (let j = 0; j < this.locations.length; j++) {
                    if (this.locations[j][fieldName] === fieldSet[i]) cards.push(this.locations[j]);
                }
            }
        }

        if (this.serviceFilter) {
            let serviceFilterArray = this.serviceFilter.split('; ');
            if (serviceFilterArray.includes('Cat Adoption') || serviceFilterArray.includes('Adoption')) {
                let nonpetbarnCards = [];
                let petbarnCards = [];

                for (let i = 0; i < cards.length; i++) {
                    if (cards[i].isPetbarn) {
                        petbarnCards.push(cards[i]);
                    } else {
                        nonpetbarnCards.push(cards[i]);
                    }
                }

                return nonpetbarnCards.concat(petbarnCards);
            }
        }

        return cards;
    }

    get pages() {
        let pages = [];
        let page = [];

        if (this.locations) {
            this.markers = [];
            let _filteredCards = this.filteredCards;
            for (let i = 0; i < _filteredCards.length; i++) {
                if (this.filterCard(_filteredCards[i])) {
                    page.push(_filteredCards[i]);

                    var marker = {
                        icon: this.getLocationIcon(_filteredCards[i].record.Location_Type__c),
                        position: {
                            lat: _filteredCards[i].record.Geolocation__Latitude__s ? Number(_filteredCards[i].record.Geolocation__Latitude__s) : null,
                            lng: _filteredCards[i].record.Geolocation__Longitude__s ? Number(_filteredCards[i].record.Geolocation__Longitude__s) : null,
                            title: _filteredCards[i].record.Name,
                            description: _filteredCards[i].record.Name
                        },
                        id: _filteredCards[i].record.Id
                    };

                    this.markers.push(marker);
                }

                if (page.length > 0 && (page.length == 3 || _filteredCards.length == (i + 1))) {
                    let pageNumber = pages.length + 1;
                    pages.push({cards: page, pageNumber: pageNumber, displayed: pageNumber == this.currentPage});
                    page = [];
                }
            }

            this.sendMessageToIframe();
            setTimeout(() => this.calculateViewCount(pages, _filteredCards), 1);

            this.isReset = false;
            this.pageCount = pages.length;
        }

        return pages;
    }

    get postcodeClass() {
        return 'medium postcode' + (!this.isGeolocationShared || (!this.postcodeFilter && this.withinFilter) ? ' white' : '');
    }

    get withins() {
        return [
            {label: 'Up to 20km', value: 'Up to 20km'},
            {label: '21-30km', value: '21-30km'},
            {label: '31-50km', value: '31-50km'},
            {label: '51-70km', value: '51-70km'},
            {label: '71km+', value: '71km+'}
        ];
    }

    connectedCallback() {
        getPortalCustomSetting()
            .then(result => {
                this.iframeSrc = '../vforcesite/vertic_GoogleMaps?key=' + result.Google_Maps_Api_Key__c;
                this.googleApiKey = result.Google_Maps_Api_Key__c;

                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(position => {
                        this.isGeolocationShared = true;

                        this.coords = {
                            myLatitude: position.coords.latitude,
                            myLongitude: position.coords.longitude
                        };

                        this.initLocationAccounts();
                        this.getPostalCode();
                    }, error => {
                        this.initLocationAccounts();
                    });
                } else {
                    this.initLocationAccounts();
                }
            })
    }

    renderedCallback() {
        window.addEventListener('message', (event) => {this.handleMapMessage(event)});

        let that = this;
        var ifr = this.template.querySelector('.map-iframe');
        ifr.addEventListener("load", function() {
            that.iframeLoaded = true;
        });
    }

    calculateViewCount(pages, fCards) {
        if (pages !== undefined && pages.length > 0) {
            for (let i = 0; i <= pages.length; i++) {
                if (pages[i] && pages[i].displayed) this.viewCount = pages[i].cards.length;
            }
        } else {
            this.viewCount = 0;
        }
        this.isFilterFound = this.viewCount > 0;
        this.allCount = fCards ? fCards.length : 0;
    }

    initLocationAccounts() {
        getLocationAccounts({ location: this.coords ? JSON.stringify(this.coords) : this.coords})
            .then(result => {
                this.locations = result;
            })
            .catch(error => {
                console.log(error);
            })
    }

    sendMessageToIframe() {
        if (this.iframeLoaded) {
            var ifr = this.template.querySelector('.map-iframe');
            ifr.contentWindow.postMessage({
                locations: this.markers,
                isReset: this.isReset
            }, '*');
        } else {
            setTimeout(() => this.sendMessageToIframe(), 200);
        }
    }

    handleMapMessage(evt) {
        if (evt.data && evt.data.type == 'marker_click' && evt.data.id) {
            if (evt.data.id != this.mapId) this.mapId = evt.data.id;
        }
    }

    handlePageChange(evt) {
        this.currentPage = evt.detail.pageNumber;
        this.template.querySelector('.cards-filters').scrollIntoView({ block: 'start',  behavior: 'smooth' });
    }

    handleOrderChange(evt) {
        this.orderOption = evt.detail.value;
        this.orderDirection = 'asc';
        this.currentPage = 1;
    }

    handleOrderDirectionChange(evt) {
        this.orderDirection = evt.detail.value;
        this.currentPage = 1;
    }

    filterCard(card) {
        let isFilter = true;

        let isSearchFilter = false;
        if (this.searchFilter) {
            if (card.record.Name.toLowerCase().includes(this.searchFilter.toLowerCase()) ||
                card.locationCard.toLowerCase().includes(this.searchFilter.toLowerCase()) ||
                card.services.toLowerCase().includes(this.searchFilter.toLowerCase()) ||
                card.services.toLowerCase().replace(/é/g, 'e').includes(this.searchFilter.toLowerCase()) ||
                card.locationTypesString.toLowerCase().includes(this.searchFilter.toLowerCase()) ||
                card.locationTypesString.toLowerCase().replace(/é/g, 'e').includes(this.searchFilter.toLowerCase())
                ) isSearchFilter = true;
        } else {
            isSearchFilter = true;
        }

        let isServiceFilter = false;
        if (this.serviceFilter) {
            let serviceFilterArray = this.serviceFilter.split('; ');
            if (serviceFilterArray.includes('Cat Adoption') || serviceFilterArray.includes('Adoption')) {
                if (!serviceFilterArray.includes('Cat Adoption')) serviceFilterArray.push('Cat Adoption');
                if (!serviceFilterArray.includes('Adoption')) serviceFilterArray.push('Adoption');
                if (!serviceFilterArray.includes('Shelter')) serviceFilterArray.push('Shelter');
            }
            let cardServices = card.services.split(', ');

            for (let i = 0; i < cardServices.length; i++) {
                if (serviceFilterArray.includes(cardServices[i])) {
                    isServiceFilter = true;
                    break;
                }
            }
            if (!isServiceFilter) {
                for (let i = 0; i < card.locationTypes.length; i++) {
                    if (serviceFilterArray.includes(card.locationTypes[i].label)) {
                        isServiceFilter = true;
                        break;
                    }
                }
            }
        } else {
            isServiceFilter = true;
        }

        let isMapId = this.mapId ? this.mapId == card.record.Id : true;

        let isWithin = false;
        if (this.withinFilter && this.coords && this.postcodeFilter && this.postcodeFilter.length >= 4) {
            let withins = this.withinFilter.split('; ');
            for (let i = 0; i < withins.length; i++) {
                if (withins[i] == 'Up to 20km' && card.distance <= 20) {isWithin = true; break;}
                if (withins[i] == '21-30km' && card.distance > 20 && card.distance <= 30) {isWithin = true; break;}
                if (withins[i] == '31-50km' && card.distance > 30 && card.distance <= 50) {isWithin = true; break;}
                if (withins[i] == '51-70km' && card.distance > 50 && card.distance <= 70) {isWithin = true; break;}
                if (withins[i] == '71km+' && card.distance > 70) {isWithin = true; break;}
            }
        } else {
            isWithin = true;
            if (card.defaultDistance) card.distance = JSON.parse(JSON.stringify(card.defaultDistance));
        }

        return isSearchFilter && isServiceFilter && isMapId && isWithin;
    }

    handleSearchChange(evt) {
        this.currentPage = 1;
        this.searchFilter = evt.target.value;
        this.isReset = true;
    }

    handleServiceChange(evt) {
        this.currentPage = 1;
        this.serviceFilter = evt.target.value;
        this.isReset = true;
    }

    handleWithinChange(evt) {
        if (this.postcodeFilter) this.currentPage = 1;
        this.updateWithinFilter(evt.detail.value);
        this.isReset = true;
    }

    updateWithinFilter(value) {
        let _within = '';
        if (value) {
            if (value.includes('71km+')) {_within = 'Up to 20km; 21-30km; 31-50km; 51-70km; 71km+';}
            else if (value.includes('51-70km')) {_within = 'Up to 20km; 21-30km; 31-50km; 51-70km';}
            else if (value.includes('31-50km')) {_within = 'Up to 20km; 21-30km; 31-50km';}
            else if (value.includes('21-30km')) {_within = 'Up to 20km; 21-30km';}
            else if (value.includes('Up to 20km')) {_within = 'Up to 20km';}
        }
        this.withinFilter = _within;
    }

    handlePostcodeChange(evt) {
        if (this.withinFilter) this.currentPage = 1;
        let _postcode = evt.target.value;

        if (_postcode && _postcode.length >= 4 && _postcode != this.postcodeFilter && _postcode != this.defaultPostcode) {
            this.updateCoords(_postcode);
            this.isReset = true;
        }
        this.postcodeFilter = _postcode;
    }

    handleReset(evt) {
        this.currentPage = 1;
        this.searchFilter = '';
        this.serviceFilter = '';
        this.postcodeFilter = this.defaultPostcode;
        this.updateRecordsDistance(this.postcodeFilter);
        this.updateWithinFilter('71km+');
        this.mapId = null;
        this.isReset = true;
    }

    getLocationIcon(locationType) {
        switch (locationType) {
            case 'Café': return constants.locationCafe;
            case 'Cat Adoption': return constants.locationPetbarn;
            case 'Crematorium': return constants.locationCrematorium;
            case 'Op Shop': return constants.locationOpshop;
            case 'Pet Training': return constants.locationPetTraining;
            case 'Shelter': return constants.locationShelter;
            case 'Wildlife Hospital': return constants.locationHospital;
            default: return constants.locationAdopt;
        }
    }

    getPostalCode() {
        let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=" + this.coords.myLatitude + "," + this.coords.myLongitude + "&key=" + this.googleApiKey;

        fetch(url)
            .then((response) => {
                return response.json();
            })
            .then((jsonResponse) => {
                let results = jsonResponse.results;

                if (results) {
                    for (let j = 0; j < results.length; j++) {
                        for (let i = 0; i < results[j].address_components.length; i++) {
                            let types = results[j].address_components[i].types;
                            for (let typeIdx = 0; typeIdx < types.length; typeIdx++) {
                                if (types[typeIdx] === 'postal_code') {
                                    this.postcodeFilter = results[j].address_components[i].long_name;
                                    this.defaultPostcode = results[j].address_components[i].long_name;
                                    break;
                                }
                            }
                            if (this.postcodeFilter) {
                                break;
                            }
                        }
                        if (this.postcodeFilter) {
                            break;
                        }
                    }
                }
            })
            .catch((error) => {console.log(error);});
    }

    updateCoords(_postcode) {
        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + _postcode + " QLD Australia&key=" + this.googleApiKey;
        fetch(url)
            .then((response) => {
                return response.json();
            })
            .then((jsonResponse) => {
                let results = jsonResponse.results;
                if (results) {
                    for (let j = 0; j < results.length; j++) {
                        if (results[j].geometry && results[j].geometry.location) {
                            this.coords = {
                                myLatitude: results[j].geometry.location.lat,
                                myLongitude: results[j].geometry.location.lng
                            };
                            break;
                        }
                    }
                } else {
                    this.coords = null;
                }

                this.updateRecordsDistance(_postcode);
            })
            .catch((error) => {
                this.coords = null;
                console.log(error);
            });
    }

    updateRecordsDistance(_postcode) {
        for (let i = 0; i < this.locations.length; i++) {
            let card = this.locations[i];
            if (_postcode == this.defaultPostcode) {
                card.distance = card.defaultDistance;
            } else if (this.coords && _postcode && _postcode.length >= 4) {
                if (card.record.Geolocation__c) {
                    card.distance = this.getDistanceFromLatLonInKm(card.record.Geolocation__c.latitude, card.record.Geolocation__c.longitude, this.coords.myLatitude, this.coords.myLongitude);
                }
            }
        }
    }

    getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) {
        var R = 6371; // Radius of the earth in km
        var dLat = this.deg2rad(lat2-lat1);  // deg2rad below
        var dLon = this.deg2rad(lon2-lon1);
        var a =
            Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) *
            Math.sin(dLon/2) * Math.sin(dLon/2)
        ;
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        var d = R * c; // Distance in km
        return d;
    }

    deg2rad(deg) {
        return deg * (Math.PI/180);
    }
}