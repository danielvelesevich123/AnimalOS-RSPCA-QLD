import {LightningElement, api} from "lwc";

export default class JamScopedNotification extends LightningElement {

    @api isIconNotVisible = false;
    @api iconName = 'utility:info';
    @api iconVariant = 'info';
    @api className;
    @api theme;

    async connectedCallback() {
    }

    get notificationClasses() {
        return 'slds-m-vertical_small slds-scoped-notification slds-media slds-media_center ' + (this.theme ? 'slds-theme_' + this.theme : 'slds-scoped-notification_light') + (this.className ? ' ' + this.className : '');
    }

    get iconVisible() {
        return this.isIconNotVisible === false;
    }
}