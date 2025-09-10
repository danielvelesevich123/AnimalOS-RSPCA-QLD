import {api, LightningElement} from "lwc";
import {loadScript} from "lightning/platformResourceLoader";
import signaturePadLibUrl from "@salesforce/resourceUrl/signaturePad";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class CaptureSignature extends LightningElement {
    @api recordId;
    @api width;
    @api height;
    isBusy = false;
    signaturePad;

    connectedCallback() {
        this.isBusy = true;

        Promise.all([
            loadScript(this, signaturePadLibUrl)
        ]).then(() => {
            let canvas = this.template.querySelector('canvas');
            const ratio = Math.max(window.devicePixelRatio || 1, 1);

            canvas.width = this.width || canvas.offsetWidth * ratio;
            canvas.height = this.height || canvas.offsetHeight * ratio;
            // canvas.getContext("2d").scale(ratio, ratio);

            this.signaturePad = new SignaturePad(canvas, {
                backgroundColor: 'rgb(255,255,255,0)',
                penColor: '#010188'
            });

            this.isBusy = false;
        }).catch((ex) => {
            const toastEvt = new ShowToastEvent({
                title: 'Error',
                message: 'Script load error: ' + ex,
                variant: 'error'
            });
            this.dispatchEvent(toastEvt);
        })
    }

    @api
    getBase64Data() {
        return this.signaturePad.toDataURL('image/png').replace(/^data:image\/(png|jpg);base64,/, "");
    }

    @api
    clear() {
        this.signaturePad.clear();
    }
}