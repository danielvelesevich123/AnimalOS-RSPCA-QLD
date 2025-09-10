import {api, LightningElement} from 'lwc';

export default class RspcaqldProgressStep extends LightningElement {
    @api label;
    @api type;

    get progressStepClass() {
        return 'progress-step ' + (this.type ? this.type.toLowerCase() : 'incomplete');
    }
    get iconClass() {
        return (this.type && this.type == 'Complete' ? 'check_circle' : 'circle');
    }
}