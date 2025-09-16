import {api, LightningElement} from 'lwc';
import {execute, showToast} from 'c/verticUtils';

export default class ResourcesNearbyResourceDistance extends LightningElement {
    @api resourceId;
    @api jobId;
    isBusy = false;
    distance;

    async connectedCallback() {
        this.isBusy = true;
        try {
            let response = await execute('ResourcesNearbyCalcDistanceProc', {
                resourceId: this.resourceId,
                jobId: this.jobId,
            });
            this.distance = response.dto.distance;
        } catch (ex) {
            showToast(this, 'Error', Array.isArray(ex) ? ex[0].message : ex.message || ex.body.message, 'error');
        } finally {
            this.isBusy = false;
        }
    }
}


