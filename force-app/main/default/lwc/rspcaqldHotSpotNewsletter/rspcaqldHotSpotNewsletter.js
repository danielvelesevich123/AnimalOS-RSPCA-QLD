import {api, LightningElement} from 'lwc';

export default class RspcaqldHotSpotNewsletter extends LightningElement {
    @api value;

    handleEmailChange(event) {
        this.value = event.detail.value;
    }

    handleClick(event) {}
}