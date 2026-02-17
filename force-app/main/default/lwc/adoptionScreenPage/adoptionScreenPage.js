import {api, LightningElement, track} from 'lwc';
import {execute} from "c/verticBase";

export default class AdoptionScreenPage extends LightningElement {
    @api unitId;
    @api meta = {};
    @track isBusy;
    @track currentIndex = 0;

    get currentAnimal() {
        return this.meta?.dto?.animals?.[this.currentIndex];
    }

    get showContent() {
        return this.meta.dto !== undefined;
    }

    connectedCallback() {
        this.isBusy = true;

        execute('aos_AdoptionScreenMetaProc', {unitId: this.unitId})
            .then(response => {
                this.meta = response;
                this.startSlideshow();
            })
            .catch(errors => {
                console.log(errors);
                console.log(errors.length);
                console.log('error - ' + JSON.stringify(errors[0]));
            })
            .finally(() => {
                this.isBusy = false;
            });
    }

    startSlideshow() {
        const animals = this.meta?.dto?.animals;

        if (!animals || animals.length <= 1) {
            return;
        }

        setInterval(() => {
            this.currentIndex++;

            if (this.currentIndex >= this.meta.dto.animals.length){
                        this.currentIndex = 0;
                    }
        }, 20000);
    }
}