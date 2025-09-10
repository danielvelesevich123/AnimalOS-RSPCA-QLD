import {
    api,
    LightningElement
} from 'lwc';

export default class RspcaqldCheckbox extends LightningElement {
    @api label;
    @api checked = false;

    get iconClass() {
        return (this.checked ? 'utility:toggle_on' : 'utility:toggle_off');
    }

    handleToggleClick(evt) {
        this.checked = ! this.checked;
    }
}