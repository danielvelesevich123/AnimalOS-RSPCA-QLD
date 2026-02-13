import {api, LightningElement } from 'lwc';

const UPCOMING_TREATMENTS = 'Upcoming Treatments';
const TREATMENTS_HISTORY = 'Treatments History';

export default class AdoptionAgreementAnimalTreatments extends LightningElement {
    @api animal;

    @api type = UPCOMING_TREATMENTS;

    get cardTitle() {
        return this.animal.animalos__Animal_Name__c + ' ' + this.type;
    }

    get animalHasPlans() {
        return this.animal.animalos__Animal_Action_Plans__r?.length > 0;
    }

    get animalHasTreatmentsHistory() {
        return this.animal.animalos__Animal_Actions__r?.length > 0;
    }

    get isTreatmentsHistory() {
        return this.type === TREATMENTS_HISTORY && this.animalHasTreatmentsHistory;
    }

    get isUpcomingTreatments() {
        return this.type === UPCOMING_TREATMENTS && this.animalHasPlans;
    }
}