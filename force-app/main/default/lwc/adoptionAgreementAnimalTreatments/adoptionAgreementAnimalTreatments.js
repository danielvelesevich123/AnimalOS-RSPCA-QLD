import {api, LightningElement } from 'lwc';

export default class AdoptionAgreementAnimalTreatments extends LightningElement {
    @api animal;

    get cardTitle() {
        return this.animal.animalos__Animal_Name__c + ' Treatments';
    }

    get animalHasPlans() {
        return this.animal.animalos__Animal_Action_Plans__r?.length > 0;
    }
}