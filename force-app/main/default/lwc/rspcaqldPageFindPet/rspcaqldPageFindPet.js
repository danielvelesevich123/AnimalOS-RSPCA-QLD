import getPortalActiveAnimals from '@salesforce/apex/rspcaqldAnimalService.getPortalActiveAnimals';
import getPortalCustomSetting from '@salesforce/apex/rspcaqldUtils.getPortalCustomSetting';
import {LightningElement, wire, track, api} from 'lwc';
import {MessageContext, publish} from 'lightning/messageService';
import {CurrentPageReference} from "lightning/navigation";
import * as constants from 'c/constants';

export default class RspcaqldPageFindPet extends LightningElement {
    @api header = 'Rescue your purrfect pet';
    @api iconsString = '';
    bottomrightWedge = constants.bottomrightWedge;
    isFilterFound = true;
    isGeolocationShared = false;
    @track filters = {
        type: ''
    };
    orderOption = 'featured';
    orderDirection = 'asc';
    currentPage = 1;
    pageCount = 1;
    postalCode;
    animalCards;
    coords;
    googleApiKey;
    stateType;

    orderOptions = [
        { label: 'status date', value: 'status date'},
        { label: 'featured', value: 'featured'},
        { label: 'name', value: 'name'},
        { label: 'age', value: 'age'}
    ];

    @wire(CurrentPageReference)
    pageReference({state}) {
        if (state && state.type) {
            this.filters.type = state.type == 'smallanimal' ? 'Small Animal' : state.type.charAt(0).toUpperCase() + state.type.slice(1);
            this.stateType = this.filters.type;
        }
        if (state && state.page) {this.currentPage = state.page} else {
            this.currentPage = 1;
            this.updateUrl();
        }
    }

    @wire(MessageContext)
    messageContext;

    get headerIcons() {
        if (this.iconsString) {
            let icons = JSON.parse(this.iconsString);
            for (let i = 0; i < icons.length; i++) {
                icons[i].class = i % 2 == 0 ? 'shape-1 top' : 'shape-2 top';
            }
            return icons;
        }

        return null;
    }

    get filteredCards() {
        let cards = [];
        if (this.orderOption == 'name') {
            return this.sortCards('Animal_Name__c');
        }
        if (this.orderOption == 'featured') {
            let featured = [];
            let unfeatured = [];
            for (let i = 0; i < this.animalCards.length; i++) {
                if (this.animalCards[i].record.Featured__c) featured.push(this.animalCards[i]);
                if (!this.animalCards[i].record.Featured__c) unfeatured.push(this.animalCards[i]);
            }
            cards = this.orderDirection == 'asc' ? featured.concat(unfeatured) : unfeatured.concat(featured);
            return cards;
        }
        if (this.orderOption == 'age') {
            return this.sortCards('Age_in_Days__c');
        }
        if (this.orderOption == 'status date') {
            return this.sortCards('Status_Date__c');
        }
        return this.animalCards;
    }

    sortCards(fieldName) {
        let cards = [];
        let fieldSet = [];
        for (let i = 0; i < this.animalCards.length; i++) {
            fieldSet.push(this.animalCards[i].record[fieldName]);
        }

        fieldSet = fieldName == 'Age_in_Days__c' ? [...new Set(fieldSet.sort((a,b)=>a -b))] : [...new Set(fieldSet)].sort();

        if (this.orderDirection == 'asc') {
            for (let i = 0; i < fieldSet.length; i++) {
                for (let j = 0; j < this.animalCards.length; j++) {
                    if (this.animalCards[j].record[fieldName] === fieldSet[i]) cards.push(this.animalCards[j]);
                }
            }
        } else {
            for (let i = (fieldSet.length - 1); i >= 0; i--) {
                for (let j = 0; j < this.animalCards.length; j++) {
                    if (this.animalCards[j].record[fieldName] === fieldSet[i]) cards.push(this.animalCards[j]);
                }
            }
        }

        return cards;
    }

    get pages() {
        let pages = [];
        let _isFilterFound = true;

        if (this.animalCards) {
            let _filteredCards = this.filteredCards;
            pages = this.initPages(_filteredCards, false, 1);

            if (pages.length == 0) {
                _isFilterFound = false;
                pages = this.initPages(_filteredCards, true, 1);
                if (pages.length == 0) {
                    pages = this.initPages(_filteredCards, true, 2);
                    if (pages.length == 0) {
                        pages = this.initPages(_filteredCards, true, 3);
                    }
                }
            }
            this.pageCount = pages.length;
        }

        this.isFilterFound = _isFilterFound;

        return pages;
    }

    initPages(cards, isOther, orderValue) {
        let pages = [];
        let page = [];

        for (let i = 0; i < cards.length; i++) {
            if (this.filterCard(cards[i], isOther, orderValue)) page.push(cards[i]);

            if (page.length > 0 && (page.length == 12 || cards.length == (i + 1))) {
                let pageNumber = pages.length + 1;
                pages.push({cards: page, pageNumber: pageNumber, displayed: pageNumber == this.currentPage});
                page = [];
            }
        }

        return pages;
    }

    get allCount() {
        return this.animalCards ? this.filteredCards.length : 0;
    }

    get viewCount() {
        let _pages = this.pages;
        if (_pages && _pages.length > 0) {
            for (let i = 0; i <= _pages.length; i++) {
                if (_pages[i].displayed) return _pages[i].cards.length;
            }
        }
        return 0;
    }

    handlePageChange(evt) {
        this.currentPage = evt.detail.pageNumber;
        this.scrollToTop();
        this.updateUrl();
    }

    handleOrderChange(evt) {
        this.orderOption = evt.detail.value;
        this.orderDirection = 'asc';
        this.currentPage = 1;
        this.updateUrl();
    }

    handleOrderDirectionChange(evt) {
        this.orderDirection = evt.detail.value;
        this.currentPage = 1;
        this.updateUrl();
    }

    handleFilterChange(evt) {
        this.currentPage = 1;
        this.updateUrl();
        let _filters = evt.detail;
        if (_filters.postcode && _filters.postcode.length >= 4 && this.filters.postcode != _filters.postcode && this.postalCode != _filters.postcode) {
            this.updateCoords(_filters);
        } else {
            this.filters = _filters;
        }
    }

    filterCard(card, isOther, orderValue) {
        let isFilter = true;

        let isType = true;
        if (this.filters.type) {
            let types = this.filters.type.split('; ');
            if (! types.includes(card.record.Animal_Type__c)) {
                isFilter = false;
                isType = false;
            }
        }

        let isAge = false;
        if (this.filters.age) {
            let ages = this.filters.age.split('; ');
            for (let i = 0; i < ages.length; i++) {
                if (card.record.Age__c == 'Age Unknown') {isAge = true; break;}

                if (ages[i] == 'Up to 4 months') {
                    if (!card.record.Age_Years__c && (!card.record.Age_Months__c || card.record.Age_Months__c < 4)) {isAge = true; break;}
                }
                if (ages[i] == '4 months - 1 year') {
                    if (!card.record.Age_Years__c && card.record.Age_Months__c && card.record.Age_Months__c >= 4) {isAge = true; break;}
                }
                if (ages[i] == '1 - 3 years') {
                    if (card.record.Age_Years__c && card.record.Age_Years__c >= 1 && card.record.Age_Years__c < 4) {isAge = true; break;}
                }
                if (ages[i] == '4 - 6 years') {
                    if (card.record.Age_Years__c && card.record.Age_Years__c >= 4 && card.record.Age_Years__c < 7) {isAge = true; break;}
                }
                if (ages[i] == '7 - 9 years') {
                    if (card.record.Age_Years__c && card.record.Age_Years__c >= 7 && card.record.Age_Years__c < 10) {isAge = true; break;}
                }
                if (ages[i] == '10+ years') {
                    if (card.record.Age_Years__c && card.record.Age_Years__c >= 10) {isAge = true; break;}
                }
            }
        } else {isAge = true;}

        if (this.filters.gender) {
            let genders = this.filters.gender.split('; ');
            if (!card.record.Gender__c || !genders.includes(card.record.Gender__c)) isFilter = false;
        }

        let isBreed = false;
        let isEmptyBreed = false;
        if (this.filters.breed) {
            let breeds = this.filters.breed.split('; ');
            for (let i = 0; i < breeds.length; i++) {
                if (breeds[i] == card.record.Web_Display_Breed__c || (card.record.Web_Display_Breed__c.endsWith('(Mixed)') && card.record.Web_Display_Breed__c.includes(breeds[i]))) isBreed = true;
            }
        } else {
            isEmptyBreed = true;
            isBreed = true;
        }

        if (this.filters.size && this.filters.type && (this.filters.type.includes('Dog') || this.filters.type.includes('Puppy'))) {
            let sizes = this.filters.size.split('; ');
            if (!card.record.Size__c || !sizes.includes(card.record.Size__c)) isFilter = false;
        }

        if (this.filters.name) {
            if (!card.record.Animal_Name__c || !card.record.Animal_Name__c.toLowerCase().includes(this.filters.name.toLowerCase())) isFilter = false;
        }

        if (this.filters.animalId) {
            if (!card.record.Shelterbuddy_ID__c || !card.record.Shelterbuddy_ID__c.toLowerCase().includes(this.filters.animalId.toLowerCase())) isFilter = false;
        }

        // let isPostcode = false;
        // let isEmptyPostcode = false;
        if (this.filters.postcode) {
            // isPostcode = (card.record.Location_Postcode__c && card.record.Location_Postcode__c.toLowerCase().includes(this.filters.postcode.toLowerCase())) ||
            //              (card.record.Location_City__c && card.record.Location_City__c.toLowerCase().includes(this.filters.postcode.toLowerCase()));
            if (this.postalCode == this.filters.postcode) {
                card.distance = card.defaultDistance;
            } else if (this.coords && this.filters.postcode && this.filters.postcode.length >= 4) {
                if (card.record.Location__r && card.record.Location__r.Geolocation__c) {
                    card.distance = this.getDistanceFromLatLonInKm(card.record.Location__r.Geolocation__c.latitude, card.record.Location__r.Geolocation__c.longitude, this.coords.myLatitude, this.coords.myLongitude);
                }
            }
        }
        // else {isEmptyPostcode = true;}

        let isWithin = false;
        let isEmptyWithin= this.filters.within == null;
        if (this.filters.within && this.coords && this.filters.postcode && this.filters.postcode.length >= 4) {
            let withins = this.filters.within.split('; ');
            for (let i = 0; i < withins.length; i++) {
                if (withins[i] == 'Up to 20km' && card.distance <= 20) {isWithin = true; break;}
                if (withins[i] == '21-30km' && card.distance > 20 && card.distance <= 30) {isWithin = true; break;}
                if (withins[i] == '31-50km' && card.distance > 30 && card.distance <= 50) {isWithin = true; break;}
                if (withins[i] == '51-70km' && card.distance > 50 && card.distance <= 70) {isWithin = true; break;}
                if (withins[i] == '71km+' && card.distance > 70) {isWithin = true; break;}
            }
        } else {
            isWithin = true;
            isEmptyWithin = true;
            if (card.defaultDistance) card.distance = JSON.parse(JSON.stringify(card.defaultDistance));
        }
        // && (isEmptyPostcode || isPostcode || (!isEmptyPostcode && !isPostcode && isWithin))

        if (!isOther) {
            return isFilter && isAge && isBreed && isWithin;
        } else {
            if (orderValue == 1) {return isType && !isEmptyWithin && isWithin;}
            else if (orderValue == 2) {return isType && !isEmptyBreed && isBreed;}
            return true;
        }
    }

    scrollToTop() {
        let that = this;
        setTimeout(() => {
            that.template.querySelector(".page-find-pet-cards").scrollIntoView({ block: 'start',  behavior: 'smooth' });
        }, 100);
    }

    updateUrl() {
        let currentUrl = window.location.href.split('?')[0];
        let type = this.stateType ? '?type=' + this.stateType.toLowerCase() + '&' : '?';
        history.pushState(null, '', currentUrl + type + 'page=' + this.currentPage);
    }

    connectedCallback() {
        getPortalActiveAnimals()
            .then(result => {
                this.animalCards = result;

                getPortalCustomSetting()
                    .then(result => {
                        this.googleApiKey = result.Google_Maps_Api_Key__c;
                        this.getCurrentPosition();
                    })
            })
            .catch(error => {
                console.log(error);
            })
    }

    getCurrentPosition() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                this.isGeolocationShared = true;

                this.coords = {
                    myLatitude: position.coords.latitude,
                    myLongitude: position.coords.longitude
                };

                for (let i = 0; i < this.animalCards.length; i++) {
                    if (this.animalCards[i].record.Location__r && this.animalCards[i].record.Location__r.Geolocation__c) {
                        this.animalCards[i].distance = this.getDistanceFromLatLonInKm(this.animalCards[i].record.Location__r.Geolocation__c.latitude, this.animalCards[i].record.Location__r.Geolocation__c.longitude, this.coords.myLatitude, this.coords.myLongitude);
                        this.animalCards[i].defaultDistance = this.animalCards[i].distance;
                    }
                }

                this.getPostalCode();
            }, error => {
                console.log(error);
            });
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
                                    this.postalCode = results[j].address_components[i].long_name;
                                    this.filters.postcode = results[j].address_components[i].long_name;
                                    break;
                                }
                            }
                            if (this.postalCode) {
                                break;
                            }
                        }
                        if (this.postalCode) {
                            break;
                        }
                    }
                }
            })
            .catch((error) => {console.log(error);});
    }

    updateCoords(_filters) {
        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + _filters.postcode + " QLD Australia&key=" + this.googleApiKey;
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
                this.filters = _filters;
            })
            .catch((error) => {
                this.filters = _filters;
                this.coords = null;
                console.log(error);
            });
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