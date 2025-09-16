import {api, LightningElement} from 'lwc';

export default class AnimalsNearbyAnimalReferral extends LightningElement {
    @api animalReferral;
    @api index;

    get jobUrl() {
        return location.hostname + '/' + this.animalReferral.animalos__Job__c;
    }

    get jobCreatedDate() {
        return this.animalReferral.animalos__Job__r.CreatedDate;
    }

    get jobName() {
        return this.animalReferral.animalos__Job__r.Name;
    }

    get animalUrl() {
        return location.hostname + '/' + this.animalReferral.animalos__Animal__c;
    }

    get animalName() {
        return this.animalReferral.animalos__Animal__r.Name;
    }

    get animalType() {
        return this.animalReferral.animalos__Animal__r.animalos__Type__c;
    }

    get jobStatus() {
        return this.animalReferral.animalos__Job__r.animalos__Status__c;
    }

    get jobOwnerUrl() {
        return location.hostname + '/' + this.animalReferral.animalos__Job__r.OwnerId;
    }

    get jobOwnerName() {
        return this.animalReferral.animalos__Job__r.Owner.Name;
    }

    get jobAdvisory() {
        return this.animalReferral.animalos__Job__r.animalos__Advisory__c;
    }
}