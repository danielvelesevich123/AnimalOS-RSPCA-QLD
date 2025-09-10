import {api, wire, LightningElement} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldCardsFilters extends LightningElement {
    @api isOpen = false;
    @api isGeolocationShared;
    @api type = '';
    @api age = '';
    @api gender = '';
    @api within = '';
    @api postcode;
    @api defaultPostcode;
    @api breed= '';
    @api size= '';
    @api name;
    @api animalId;
    @api types = [];
    @api genders = [];
    @api sizes = [];
    _cards = [];

    closeDark = constants.closeDark;

    @api
    get cards() {return this._cards;}
    set cards(items) {
        if (items) {
            this._cards = items;
            this.types = [];
            this.genders = [];
            this.sizes = [];
            let _types = [];
            let _genders = [];
            let _sizes = [];

            for (let i = 0; i < items.length; i++) {
                _types.push(items[i].record.Animal_Type__c);
                _genders.push(items[i].record.Gender__c);
                if (items[i].record.Animal_Type__c == 'Dog' || items[i].record.Animal_Type__c == 'Puppy') _sizes.push(items[i].record.Size__c);

            }
            _types = [...new Set(_types)].sort();
            _genders = [...new Set(_genders)].sort();
            _sizes = [...new Set(_sizes)].sort();

            for (let i = 0; i < _types.length; i++) {
                this.types.push({label: _types[i], value: _types[i]});
            }
            for (let i = 0; i < _genders.length; i++) {
                this.genders.push({label: _genders[i], value: _genders[i]});
            }
            for (let i = 0; i < _sizes.length; i++) {
                if (_sizes[i] == 'Small') this.sizes.push({label: 'Small - Up to 10kg', value: 'Small'});
                if (_sizes[i] == 'Medium') this.sizes.push({label: 'Medium - 10 - 25kg', value: 'Medium'});
                if (_sizes[i] == 'Large') this.sizes.push({label: 'Large - 25-40kg', value: 'Large'});
                if (_sizes[i] == 'Very Large') this.sizes.push({label: 'Extra Large - 40kg +', value: 'Very Large'});
            }
        }
    }

    get breeds() {
        let _breeds = [];

        if (this._cards.length > 0 && this.type) {
            let breedValues = [];
            let _types = this.type.split('; ');
            for (let i = 0; i < this._cards.length; i++) {
                if (_types.includes(this._cards[i].record.Animal_Type__c)) {
                    breedValues.push(this._cards[i].record.Web_Display_Breed__c);
                }
            }

            breedValues = [...new Set(breedValues)].sort();
            let breedLabels = [];
            for (let i = 0; i < breedValues.length; i++) {
                let _breedTwo;
                let _breed = breedValues[i].endsWith('(Mixed)') ? breedValues[i].replace('(Mixed)', '').trim() :
                    breedValues[i];

                let mixedValues = breedValues[i].endsWith('(Mixed)') && _breed.includes('/') ? _breed.split('/') : null;
                if (mixedValues) {
                    _breed = mixedValues[0].trim();
                    if (mixedValues.length > 1) _breedTwo = mixedValues[1].trim();
                }

                if (! breedLabels.includes(_breed)) breedLabels.push(_breed);
                if (_breedTwo && ! breedLabels.includes(_breedTwo)) breedLabels.push(_breedTwo);
            }

            breedLabels.sort();
            for (let i = 0; i < breedLabels.length; i++) {
                _breeds.push({label: breedLabels[i], value: breedLabels[i]});
            }
        }

        return _breeds;
    }

    get isBreeds() {
        return this.breeds.length > 0;
    }

    get ages() {
        return [
            {label: 'Up to 4 months', value: 'Up to 4 months'},
            {label: '4 months - 1 year', value: '4 months - 1 year'},
            {label: '1 - 3 years', value: '1 - 3 years'},
            {label: '4 - 6 years', value: '4 - 6 years'},
            {label: '7 - 9 years', value: '7 - 9 years'},
            {label: '10+ years', value: '10+ years'}
        ];
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

    get mainClass() {
        return (this.isOpen ? 'cards-filters' : 'cards-filters closed');
    }
    get iconClass() {
        return this.isOpen ? 'utility:chevronup' : 'utility:chevrondown';
    }

    get isPuppyDog() {
        return this.type ? this.type.includes('Dog') || this.type.includes('Puppy') : false;
    }

    get postcodeClass() {
        return 'small postcode' + (!this.isGeolocationShared || (!this.postcode && this.within) ? ' white' : '');
    }

    handleAdvanced(evt) {
        this.isOpen = !this.isOpen;
    }

    handleTypeChange(evt) {
        this.type = evt.detail.value;
        this.sendEvent();
    }

    handleAgeChange(evt) {
        this.age = evt.detail.value;
        this.sendEvent();
    }

    handleGenderChange(evt) {
        this.gender = evt.detail.value;
        this.sendEvent();
    }

    handleWithinChange(evt) {
        let _within = '';
        if (evt.detail.value) {
            if (evt.detail.value.includes('71km+')) {_within = 'Up to 20km; 21-30km; 31-50km; 51-70km; 71km+';}
            else if (evt.detail.value.includes('51-70km')) {_within = 'Up to 20km; 21-30km; 31-50km; 51-70km';}
            else if (evt.detail.value.includes('31-50km')) {_within = 'Up to 20km; 21-30km; 31-50km';}
            else if (evt.detail.value.includes('21-30km')) {_within = 'Up to 20km; 21-30km';}
            else if (evt.detail.value.includes('Up to 20km')) {_within = 'Up to 20km';}
        }
        this.within = _within;
        this.sendEvent();
    }

    handleBreedChange(evt) {
        this.breed = evt.detail.value;
        this.sendEvent();
    }

    handleSizeChange(evt) {
        this.size = evt.detail.value;
        this.sendEvent();
    }

    handlePostcodeChange(evt) {
        this.postcode = evt.target.value;
        this.sendEvent();
    }

    handleNameChange(evt) {
        this.name = evt.target.value;
        this.sendEvent();
    }

    handleAnimalIdChange(evt) {
        this.animalId = evt.target.value;
        this.sendEvent();
    }

    sendEvent() {
        this.dispatchEvent(new CustomEvent("filter", {
            detail: {
                type : this.type,
                age : this.age,
                gender : this.gender,
                within : this.within,
                postcode : this.postcode,
                breed : this.breed,
                size : this.size,
                name : this.name,
                animalId : this.animalId
            }
        }));
    }

    handleReset(evt) {
        this.type = '';
        this.age = '';
        this.gender = '';
        this.within = '';
        this.postcode = this.defaultPostcode;
        this.breed = '';
        this.size = '';
        this.name = null;
        this.animalId = null;

        this.sendEvent();
    }

    handleNumberKeydown(evt) {
        var keyCode = evt.which || evt.keyCode || 0;
        var regexp = new RegExp(/^[0-9-]+$/);
        var regexpApostrophe = new RegExp("'");

        if (((evt.metaKey || evt.ctrlKey) && keyCode != 65 && keyCode != 67 && keyCode != 86 && keyCode != 88) ||
            (!evt.metaKey && !evt.ctrlKey && keyCode >= 48 && ! regexp.test(evt.key) && ! regexpApostrophe.test(evt.key))) {
            evt.preventDefault();
        }
    }
}