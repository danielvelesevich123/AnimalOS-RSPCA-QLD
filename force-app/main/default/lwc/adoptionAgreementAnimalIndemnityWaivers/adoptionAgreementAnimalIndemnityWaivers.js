import {api, LightningElement } from 'lwc';

export default class AdoptionAgreementAnimalIndemnityWaivers extends LightningElement {
    @api animal;

    get animalHasIndemnityWaivers() {
        return this.animal.animalos__Animal_Indemnity_Waivers__r?.length > 0;
    }

    get cardTitle() {
        return 'Indemnity Notes - ' + this.animal.animalos__Animal_Name__c + ' - ' + this.animal.Name;
    }
}