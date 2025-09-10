import {api, LightningElement } from 'lwc';

export default class AdoptionAgreementAnimalTestOutcomes extends LightningElement {
    @api animal;

    get cardTitle() {
        return this.animal.animalos__Animal_Name__c + ' Test Outcomes';
    }

    get isCat() {
        return 'Cat' === this.animal.animalos__Type__c || 'Kitten' === this.animal.animalos__Type__c;
    }

    get isDog() {
        return 'Dog' === this.animal.animalos__Type__c || 'Puppy' === this.animal.animalos__Type__c;
    }

    get isOther() {
        return !this.isCat && !this.isDog;
    }
}