import {LightningElement, api} from 'lwc';

export default class AdoptionAgreementQA extends LightningElement {
    @api invoke() {
        window.open('https://' + window.location.host + '/c/AdoptionAgreementApp.app?recordId=' + window.location.pathname.split('/')[4], '_blank');
    }
}