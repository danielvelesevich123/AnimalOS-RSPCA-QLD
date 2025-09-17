import {api, LightningElement} from 'lwc';

export default class AnimalsNearbyAnimalReferral extends LightningElement {
    @api animalReferral;
    @api job;
    @api index;

    get jobUrl() {
        return location.hostname + '/' + this.job.Id;
    }

    get jobCreatedDate() {
        return this.job.CreatedDate;
    }

    get jobName() {
        return this.job.Name;
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
        return this.job.animalos__Status__c;
    }

    get jobOwnerUrl() {
        return location.hostname + '/' + this.job.OwnerId;
    }

    get jobOwnerName() {
        return this.job.Owner.Name;
    }

    get jobAdvisory() {
        return this.job.animalos__Advisory__c;
    }
}