import {api, LightningElement } from 'lwc';

export default class AdoptionAgreementDog extends LightningElement {
    @api animal;

    get cardTitle() {
        return 'Animal Evaluation - ' + this.animal.animalos__Animal_Name__c;
    }
}