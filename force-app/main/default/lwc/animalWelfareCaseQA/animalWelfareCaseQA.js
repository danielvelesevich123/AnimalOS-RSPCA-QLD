import {LightningElement, api} from 'lwc';

export default class AnimalWelfareCaseQA extends LightningElement {
    @api recordId;
    @api async invoke() {
        await Promise.resolve();
    window.open('https://' + window.location.host + '/lightning/n/Animal_Welfare_Wizard_Case_Version?c__recordId=' + this.recordId, '_blank');
    }
}