import {api, LightningElement, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import * as constants from 'c/constants';
import {publish} from "lightning/messageService";

export default class RspcaqldCardsAnimal extends NavigationMixin(LightningElement) {
    @api animalId;
    @api address;
    @api imageUrl;
    @api name;
    @api keyWords;
    @api breed;
    @api gender;
    @api ageGroup;
    @api size;
    @api isStar = false;
    @api animalType;
    @api status;
    @api isWhite = false;
    starsWhite = constants.starsWhite;
    shelterHeartBlack = constants.shelterHeartBlack;

    get iconName() {
        let icon;
        switch (this.animalType) {
            case 'Bird': icon = 'bird'; break;
            case 'Cat': icon = 'cat'; break;
            case 'Dog': icon = 'dog-leashed'; break;
            case 'Kitten': icon = 'paw'; break;
            case 'Puppy': icon = 'dog'; break;
            case 'Farmyard': icon = 'horse'; break;
            case 'Small Animal': icon = 'mouse-field'; break;
            case 'Reptile': icon = 'snake'; break;
            default: icon = 'dog';
        }

        return 'default fa-solid fa-' + icon;
    }

    get details() {
        let detailsArray = [];
        if (this.gender) detailsArray.push(this.gender);
        if (this.ageGroup) detailsArray.push(this.ageGroup);
        if (this.size) detailsArray.push(this.size);

        return detailsArray.length > 0 ? detailsArray.join(', ') : '';
    }

    get link() {return '../../find-a-pet/details?id=' + this.animalId;}
    get infoIcon() { return this.isWhite ? constants.infoWhite : constants.infoBlack;}
    get infoDna() { return this.isWhite ? constants.dnaWhite : constants.dnaBlack;}
    get locationIcon() { return this.isWhite ? constants.locationWhite : constants.locationDark;}

    get isFosterStatus() {return this.status && this.status == 'Available for Adoption - In Foster';}
}