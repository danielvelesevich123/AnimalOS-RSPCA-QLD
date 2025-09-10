import {api, LightningElement } from 'lwc';

export default class AdoptionAgreementAnimalDetails extends LightningElement {
    @api animal;

    get primaryBreedName() {
        return this.animal.animalos__Primary_Breed__r?.Name;
    }

    get secondaryBreedName() {
        return this.animal.animalos__Secondary_Breed__r?.Name;
    }

    get neuteredSpayed() {
        return this.animal.animalos__Neutered_Spayed__c === true ? 'Yes' : 'No';
    }
}